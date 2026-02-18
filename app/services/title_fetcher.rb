class TitleFetcher
  def self.fetch(url)
    Rails.logger.info("Fetching title for: #{url}")

    connection = Faraday.new do |faraday|
      faraday.response :follow_redirects, limit: 5
      faraday.adapter Faraday.default_adapter
    end

    response = connection.get(url) do |req|
      req.headers["User-Agent"] = "UrlShortener/1.0"
      req.options.timeout = 5
      req.options.open_timeout = 5
    end

    Rails.logger.info("Response status: #{response.status}")

    unless response.success?
      Rails.logger.warn("Request failed with status: #{response.status}")
      return "Unknown Title"
    end

    doc = Nokogiri::HTML(response.body)
    title = doc.at_css("title")&.text&.strip

    Rails.logger.info("Extracted title: #{title.inspect}")

    title.present? ? title : "Unknown Title"
  rescue StandardError => e
    Rails.logger.error("Title fetch failed for #{url}: #{e.class} - #{e.message}")
    "Unknown Title"
  end
end
