require "rails_helper"

RSpec.describe TitleFetcher do
  it "returns title for valid HTML" do
    stub_request(:get, "https://example.com")
      .to_return(body: "<html><title>Example Webpage</title></html>", status: 200)

    title = described_class.fetch("https://example.com")
    expect(title).to eq("Example Webpage")
  end
end
