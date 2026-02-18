require "rails_helper"

RSpec.describe "Analytics", type: :request do
  it "returns usage report" do
    short_url = create(:short_url, code: "abc123")
    create_list(:visit, 3, short_url: short_url)

    get "/analytics/abc123"

    json = JSON.parse(response.body)
    expect(json["total_clicks"]).to eq(3)
  end
end
