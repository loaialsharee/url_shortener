require "test_helper"

class RedirectsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @short_url = create_short_url(
      target_url: "https://example.com",
      code: "abc123",
      title: "Example"
    )
  end

  test "redirects to target url when valid code provided" do
    GeoIpService.stubs(:lookup).returns("Malaysia")

    get "/#{@short_url.code}"

    assert_response :redirect
    assert_redirected_to @short_url.target_url
  end

  test "creates visit record with correct attributes" do
    GeoIpService.stubs(:lookup).with("127.0.0.1").returns("Malaysia")

    assert_difference "Visit.count", 1 do
      get "/#{@short_url.code}"
    end

    visit = Visit.last

    assert_equal @short_url.id, visit.short_url_id
    assert_equal "127.0.0.1", visit.ip_address
    assert_equal "Malaysia", visit.country
    assert_not_nil visit.visited_at
    assert visit.visited_at.is_a?(ActiveSupport::TimeWithZone) || visit.visited_at.is_a?(Time)
  end

  test "handles GeoIP service failure gracefully" do
    GeoIpService.stubs(:lookup).returns("Unknown")

    assert_difference "Visit.count", 1 do
      get "/#{@short_url.code}"
    end

    visit = Visit.last
    assert_equal "Unknown", visit.country
  end

  test "records multiple visits from same URL" do
    GeoIpService.stubs(:lookup).returns("Malaysia")

    assert_difference "Visit.count", 2 do
      get "/#{@short_url.code}"
      get "/#{@short_url.code}"
    end

    assert_equal 2, @short_url.visits.count
  end

  test "returns 404 for non-existent code" do
    get "/nonexistent123"

    assert_response :not_found
    assert_equal "Not found", response.body
  end

  test "returns 404 for blank code" do
    get "/"

    assert_response :not_found
  end

  test "allows redirect to external domains" do
    external_url = create_short_url(
      target_url: "https://external-site.com/page",
      code: "ext123"
    )

    GeoIpService.stubs(:lookup).returns("Malaysia")

    get "/#{external_url.code}"

    assert_redirected_to "https://external-site.com/page"
  end

  test "creates visit even if redirect target is unavailable" do
    GeoIpService.stubs(:lookup).returns("Malaysia")

    assert_difference "Visit.count", 1 do
      get "/#{@short_url.code}"
    end
  end
end
