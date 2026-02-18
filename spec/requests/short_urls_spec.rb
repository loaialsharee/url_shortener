require "rails_helper"

RSpec.describe "ShortUrls API", type: :request do
  it "creates a short URL" do
    allow(TitleFetcher).to receive(:fetch).and_return("Example Webpage")

    post "/shorten", params: { target_url: "https://example.com" }

    expect(response).to have_http_status(:success)
    json = JSON.parse(response.body)

    expect(json["short_url"]).to be_present
    expect(json["title"]).to eq("Example Webpage")
  end
end
