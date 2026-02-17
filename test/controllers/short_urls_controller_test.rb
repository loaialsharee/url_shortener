require "test_helper"

class ShortUrlsControllerTest < ActionDispatch::IntegrationTest
  test "creates short URL successfully with normalized URL" do
    TitleFetcher.stubs(:fetch).with("https://example.com").returns("Example Title")
    
    assert_difference "ShortUrl.count", 1 do
      post "/shorten", params: { target_url: "example.com" }
    end
    
    assert_response :success
    
    json = json_response
    
    assert_not_nil json["code"]
    assert_match %r{/[a-zA-Z0-9]{6}}, json["short_url"]
    assert_equal "https://example.com", json["target_url"]
    assert_equal "Example Title", json["title"]
  end

  test "normalizes URL without protocol to HTTPS" do
    TitleFetcher.stubs(:fetch).returns("Example Title")
    
    post "/shorten", params: { target_url: "example.com" }
    
    created_url = ShortUrl.last
    assert_equal "https://example.com", created_url.target_url
  end

  test "preserves HTTP protocol when provided" do
    TitleFetcher.stubs(:fetch).returns("Example Title")
    
    post "/shorten", params: { target_url: "http://example.com" }
    
    created_url = ShortUrl.last
    assert_equal "http://example.com", created_url.target_url
  end

  test "generates unique code for each URL" do
    TitleFetcher.stubs(:fetch).returns("Example Title")
    
    post "/shorten", params: { target_url: "example.com" }
    code1 = json_response["code"]
    
    post "/shorten", params: { target_url: "example.com" }
    code2 = json_response["code"]
    
    assert_not_equal code1, code2
  end

  test "generates code with correct length" do
    TitleFetcher.stubs(:fetch).returns("Example Title")
    
    post "/shorten", params: { target_url: "example.com" }
    
    code = json_response["code"]
    assert_equal 6, code.length
  end

  test "rejects invalid URL without domain" do
    assert_no_difference "ShortUrl.count" do
      post "/shorten", params: { target_url: "invalid-url" }
    end
    
    assert_response :unprocessable_entity
    assert_equal "Invalid URL", json_response["error"]
  end

  test "rejects blank URL" do
    assert_no_difference "ShortUrl.count" do
      post "/shorten", params: { target_url: "" }
    end
    
    assert_response :unprocessable_entity
    assert_equal "Invalid URL", json_response["error"]
  end

  test "rejects URL with spaces only" do
    assert_no_difference "ShortUrl.count" do
      post "/shorten", params: { target_url: "   " }
    end
    
    assert_response :unprocessable_entity
    assert_equal "Invalid URL", json_response["error"]
  end

  test "accepts URL with subdomain" do
    TitleFetcher.stubs(:fetch).returns("Example Title")
    
    assert_difference "ShortUrl.count", 1 do
      post "/shorten", params: { target_url: "subdomain.example.com" }
    end
    
    assert_response :success
  end

  test "accepts URL with path and query params" do
    TitleFetcher.stubs(:fetch).returns("Example Title")
    
    assert_difference "ShortUrl.count", 1 do
      post "/shorten", params: { target_url: "example.com/path?param=value" }
    end
    
    created_url = ShortUrl.last
    assert_equal "https://example.com/path?param=value", created_url.target_url
  end

  test "strips whitespace from URL" do
    TitleFetcher.stubs(:fetch).returns("Example Title")
    
    post "/shorten", params: { target_url: "  example.com  " }
    
    created_url = ShortUrl.last
    assert_equal "https://example.com", created_url.target_url
  end

  test "handles title fetcher failure gracefully" do
    TitleFetcher.stubs(:fetch).returns("Unknown Title")
    
    assert_difference "ShortUrl.count", 1 do
      post "/shorten", params: { target_url: "example.com" }
    end
    
    assert_response :success
    
    created_url = ShortUrl.last
    assert_equal "https://example.com", created_url.target_url
    assert_equal "Unknown Title", created_url.title
  end

  test "uses fetched title from TitleFetcher" do
    TitleFetcher.stubs(:fetch).with("https://github.com").returns("GitHub: Where the world builds software")
    
    post "/shorten", params: { target_url: "github.com" }
    
    created_url = ShortUrl.last
    assert_equal "GitHub: Where the world builds software", created_url.title
  end

  test "returns complete response JSON structure" do
    TitleFetcher.stubs(:fetch).returns("Example Title")
    
    post "/shorten", params: { target_url: "example.com" }
    
    json = json_response
    
    assert_includes json.keys, "code"
    assert_includes json.keys, "short_url"
    assert_includes json.keys, "target_url"
    assert_includes json.keys, "title"
  end

  test "short_url field contains full URL with base" do
    TitleFetcher.stubs(:fetch).returns("Example Title")
    
    post "/shorten", params: { target_url: "example.com" }
    
    json = json_response
    
    assert_match %r{^http://}, json["short_url"]
    assert_includes json["short_url"], json["code"]
  end
end