class ShortUrlCreator
  Result = Struct.new(:success?, :short_url, :error, keyword_init: true) do
    def failure? = !success?
  end

  def self.call(target_url)
    new(target_url).call
  end

  def initialize(target_url)
    @raw_url = target_url
  end

  def call
    url = normalize(@raw_url)

    return failure("Invalid URL") unless valid?(url)

    short_url = ShortUrl.create!(
      target_url: url,
      code: generate_unique_code,
      title: fetch_title(url)
    )

    success(short_url)

  rescue ActiveRecord::RecordInvalid => e
    failure(e.message)
  end

  private

  def normalize(url)
    return nil if url.blank?

    url = url.strip
    url.match?(/\Ahttps?:\/\//i) ? url : "https://#{url}"
  end

  def valid?(url)
    return false if url.blank?

    uri = URI.parse(url)
    (uri.is_a?(URI::HTTP) || uri.is_a?(URI::HTTPS)) &&
      uri.host.present? &&
      uri.host.include?(".")
  rescue URI::InvalidURIError
    false
  end

  def generate_unique_code
    loop do
      code = ShortUrlGenerator.generate
      break code unless ShortUrl.exists?(code: code)
    end
  end

  def fetch_title(url)
    TitleFetcher.fetch(url)
  end

  def success(short_url)
    Result.new(success?: true, short_url: short_url, error: nil)
  end

  def failure(error)
    Result.new(success?: false, short_url: nil, error: error)
  end
end