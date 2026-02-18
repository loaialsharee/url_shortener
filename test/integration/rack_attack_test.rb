require "test_helper"

class RackAttackTest < ActionDispatch::IntegrationTest
  def setup
    Rack::Attack.cache.store = ActiveSupport::Cache::MemoryStore.new
    Rack::Attack.enabled = true
  end

  def teardown
    Rack::Attack.cache.store.clear
    Rack::Attack.enabled = false
  end

  def make_request(ip: "1.2.3.4", url: "https://example.com")
    post "/shorten",
      params: { target_url: url },
      headers: { 
        "HTTP_X_FORWARDED_FOR" => ip,
        "REMOTE_ADDR" => ip
      }
  end

  test "allows URL creation within rate limit" do
    TitleFetcher.stubs(:fetch).returns("Example")
    make_request
    assert_response :ok
  end

  test "throttles URL creation after 7 requests per minute" do
    TitleFetcher.stubs(:fetch).returns("Example")

    7.times do |i|
      make_request(url: "https://example#{i}.com")
      assert_response :ok, "Request #{i+1} should succeed"
    end

    make_request    
    assert_response 429, "Request 8 should be throttled"
    assert_not_nil response.headers["Retry-After"], "Retry-After header missing"
    assert_includes json_response["error"], "Too many requests"
  end

  test "rate limit is per IP - different IPs are independent" do
    TitleFetcher.stubs(:fetch).returns("Example")

    7.times do |i|
      make_request(ip: "1.2.3.4", url: "https://example#{i}.com")
    end

    make_request(ip: "5.6.7.8")
    assert_response :ok
  end

  test "throttled response includes correct headers" do
    TitleFetcher.stubs(:fetch).returns("Example")

    8.times do |i|
      make_request(url: "https://example#{i}.com")
    end

    assert_response 429
    assert_includes response.content_type, "application/json"
    assert_not_nil response.headers["Retry-After"]
  end

  test "throttled response body is valid JSON" do
    TitleFetcher.stubs(:fetch).returns("Example")

    8.times do |i|
      make_request(url: "https://example#{i}.com")
    end

    assert_response 429
    assert_nothing_raised { json_response }
    assert json_response.key?("error")
  end

  test "throttles analytics after 30 requests per minute" do
    short_url = create_short_url

    30.times do
      get "/analytics/#{short_url.code}",
        headers: { 
          "HTTP_X_FORWARDED_FOR" => "1.2.3.4",
          "REMOTE_ADDR" => "1.2.3.4"
        }
      assert_response :ok
    end

    get "/analytics/#{short_url.code}",
      headers: { 
        "HTTP_X_FORWARDED_FOR" => "1.2.3.4",
        "REMOTE_ADDR" => "1.2.3.4"
      }

    assert_response 429
  end
end