require "rails_helper"

RSpec.describe "Redirects", type: :request do
  it "redirects and logs a visit" do
    short_url = create(:short_url, code: "abc123")

    expect {
      get "/abc123"
    }.to change { Visit.count }.by(1)

    expect(response).to redirect_to(short_url.target_url)
  end
end
