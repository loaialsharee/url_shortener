require "test_helper"

class AnalyticsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @short_url = create_short_url(
      target_url: "https://example.com",
      code: "abc123",
      title: "Example"
    )
  end

  test "returns analytics with total clicks" do
    create_visit(@short_url)

    get "/analytics/#{@short_url.code}"

    assert_response :success

    json = json_response

    assert_equal 1, json["total_clicks"]
    assert_equal "https://example.com", json["target_url"]
    assert_match %r{/abc123}, json["short_url"]
    assert_equal 1, json["visits"].length
  end

  test "returns zero clicks for URL with no visits" do
    get "/analytics/#{@short_url.code}"

    assert_response :success

    json = json_response

    assert_equal 0, json["total_clicks"]
  end

  test "counts multiple visits correctly" do
    3.times { create_visit(@short_url) }

    get "/analytics/#{@short_url.code}"

    json = json_response
    assert_equal 3, json["total_clicks"]
  end

  test "returns 404 for non-existent code" do
    get "/analytics/nonexistent123"

    assert_response :not_found
  end

  test "only counts visits for specific short URL" do
    other_url = create_short_url(code: "other123")

    create_visit(@short_url)
    create_visit(@short_url)
    create_visit(other_url)

    get "/analytics/#{@short_url.code}"

    json = json_response
    assert_equal 2, json["total_clicks"]
  end

  test "returns analytics with country breakdown" do
    create_visit(@short_url, country: "Malaysia")
    create_visit(@short_url, country: "Malaysia")
    create_visit(@short_url, country: "Singapore")

    get "/analytics/#{@short_url.code}"

    json = json_response

    assert_equal 3, json["total_clicks"]
    assert_equal 3, json["visits"].length

    countries = json["visits"].map { |v| v["country"] }
    assert_equal 2, countries.count("Malaysia")
    assert_equal 1, countries.count("Singapore")
  end

  test "returns analytics with time-based data" do
    create_visit(@short_url, visited_at: 2.days.ago)
    create_visit(@short_url, visited_at: 1.day.ago)
    create_visit(@short_url, visited_at: Time.current)

    get "/analytics/#{@short_url.code}"

    json = json_response

    assert_equal 3, json["total_clicks"]
    assert_equal 3, json["visits"].length

    timestamps = json["visits"].map { |v| Time.parse(v["visited_at"]) }
    assert_equal timestamps, timestamps.sort.reverse
  end

  test "includes short url metadata in response" do
    get "/analytics/#{@short_url.code}"

    assert_response :success

    json = json_response

    assert_equal 0, json["total_clicks"]
    assert_equal "https://example.com", json["target_url"]
    assert_includes json["short_url"], "abc123"
    assert_equal [], json["visits"]
  end

  private

  def create_visit(short_url, attributes = {})
    Visit.create!({
      short_url: short_url,
      ip_address: "127.0.0.1",
      country: "Unknown",
      visited_at: Time.current
    }.merge(attributes))
  end
end
