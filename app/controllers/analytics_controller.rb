class AnalyticsController < ApplicationController
  def show
    short_url = ShortUrl.find_by(code: params[:code])
    return render json: { error: "Not found" }, status: 404 unless short_url

    visits = short_url.visits.order(visited_at: :desc)

    render json: {
      short_url: "#{request.base_url}/#{short_url.code}",
      target_url: short_url.target_url,
      total_clicks: visits.count,
      visits: visits.map do |v|
        {
          ip_address: v.ip_address,
          country: v.country,
          visited_at: v.visited_at
        }
      end
    }
  end
end
