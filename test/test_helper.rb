ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"
require "mocha/minitest"
require "json"

module ActiveSupport
  class TestCase
    parallelize(workers: :number_of_processors)
    fixtures :all

    def json_response
      ::JSON.parse(response.body)
    end

    def create_short_url(attributes = {})
      pid = Process.pid.to_s[-4..]
      random = SecureRandom.hex(3)
      default_code = "t#{pid}_#{random}"

      ShortUrl.create!({
        target_url: "https://example.com",
        code: default_code,
        title: "Example Page"
      }.merge(attributes))
    end
  end
end

module ActionDispatch
  class IntegrationTest
  end
end
