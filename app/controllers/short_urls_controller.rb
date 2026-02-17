class ShortUrlsController < ApplicationController
  def create
    result = ShortUrlCreator.call(params[:target_url])

    if result.success?
      render json: serialize(result.short_url), status: :ok
    else
      render json: { error: result.error }, status: :unprocessable_entity
    end
  end

  private

  def serialize(short_url)
    {
      code: short_url.code,
      short_url: "#{request.base_url}/#{short_url.code}",
      target_url: short_url.target_url,
      title: short_url.title
    }
  end
end