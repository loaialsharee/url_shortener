class RedirectsController < ApplicationController
  def show
    short_url = ShortUrl.find_by(code: params[:code])

    return render plain: "Not found", status: :not_found unless short_url

    Visit.create!(
      short_url: short_url,
      ip_address: request.remote_ip,
      country: GeoIpService.lookup(request.remote_ip),
      visited_at: Time.current
    )

    redirect_to short_url.target_url, allow_other_host: true
  end
end