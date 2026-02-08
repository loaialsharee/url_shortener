class RedirectsController < ApplicationController
  def show
    short_url = ShortUrl.find_by(code: params[:code])

    return render plain: "Not found", status: :not_found unless short_url

    redirect_to short_url.target_url, allow_other_host: true
  end
end