class ShortUrlsController < ApplicationController
    def create
        url = params[:target_url]

        unless valid_url?(url)
            return render json: { error: 'Invalid URL' }, status: :unprocessable_entity
        end

        code = generate_unique_code

        short_url = ShortUrl.create!(
            target_url: url,
            code: code,
            title: fetch_title(url)
        )

        render json: {
            short_url: "#{request.base_url}/#{short_url.code}",
            target_url: short_url.target_url,
            title: short_url.title
        }   , status: :ok
end

private

    def generate_unique_code
        loop do
            code = ShortUrlGenerator.generate
            break code unless ShortUrl.exists?(code: code)
        end
    end

    def valid_url?(url)
        url =~ URI::DEFAULT_PARSER.make_regexp(%w[http https])
    end

    def fetch_title(url)
        "Unknown Title" 
    end
end
