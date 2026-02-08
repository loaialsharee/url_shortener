class ShortUrlsController < ApplicationController
    def create
        url = normalize_url(params[:target_url])

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
        }, status: :ok
    end

    private

    def generate_unique_code
        loop do
            code = ShortUrlGenerator.generate
            break code unless ShortUrl.exists?(code: code)
        end
    end

    def normalize_url(url)
        return nil if url.blank?
        
        url = url.strip
        url.match?(/\A https?:\/\//ix) ? url : "https://#{url}"
    end

    def valid_url?(url)
        return false if url.blank?
        
        begin
            uri = URI.parse(url)
            
            (uri.is_a?(URI::HTTP) || uri.is_a?(URI::HTTPS)) && 
            !uri.host.nil? && 
            uri.host.include?('.')
        rescue URI::InvalidURIError
            false
        end
    end

    def fetch_title(url)
        "Unknown Title" 
    end
end