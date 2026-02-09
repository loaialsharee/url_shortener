FactoryBot.define do
  factory :visit do
    association :short_url
    ip_address { "1.2.3.4" }
    country { "SG" }
  end
end
