FactoryBot.define do
  factory :short_url do
    target_url { "https://example.com" }
    code { "abc123" }
    title { "Example Webpage" }
  end
end
