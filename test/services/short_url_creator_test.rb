require "test_helper"

class ShortUrlCreatorTest < ActiveSupport::TestCase
  test "returns success result for valid URL" do
    TitleFetcher.stubs(:fetch).returns("Example")

    result = ShortUrlCreator.call("https://example.com")

    assert result.success?
    assert result.failure? == false
    assert_nil result.error
  end

  test "creates short url record in database" do
    TitleFetcher.stubs(:fetch).returns("Example")

    assert_difference "ShortUrl.count", 1 do
      ShortUrlCreator.call("https://example.com")
    end
  end

  test "normalizes URL without protocol" do
    TitleFetcher.stubs(:fetch).returns("Example")

    result = ShortUrlCreator.call("example.com")

    assert result.success?
    assert_equal "https://example.com", result.short_url.target_url
  end

  test "preserves existing HTTPS protocol" do
    TitleFetcher.stubs(:fetch).returns("Example")

    result = ShortUrlCreator.call("https://example.com")

    assert_equal "https://example.com", result.short_url.target_url
  end

  test "preserves existing HTTP protocol" do
    TitleFetcher.stubs(:fetch).returns("Example")

    result = ShortUrlCreator.call("http://example.com")

    assert_equal "http://example.com", result.short_url.target_url
  end

  test "strips whitespace from URL" do
    TitleFetcher.stubs(:fetch).returns("Example")

    result = ShortUrlCreator.call("  example.com  ")

    assert result.success?
    assert_equal "https://example.com", result.short_url.target_url
  end

  test "fetches and stores title" do
    TitleFetcher.stubs(:fetch).with("https://example.com").returns("Example Domain")

    result = ShortUrlCreator.call("example.com")

    assert_equal "Example Domain", result.short_url.title
  end

  test "generates a code for the short URL" do
    TitleFetcher.stubs(:fetch).returns("Example")

    result = ShortUrlCreator.call("example.com")

    assert_not_nil result.short_url.code
    assert result.short_url.code.length <= 15
  end

  test "generates unique codes for different URLs" do
    TitleFetcher.stubs(:fetch).returns("Example")

    result1 = ShortUrlCreator.call("example.com")
    result2 = ShortUrlCreator.call("example.com")

    assert_not_equal result1.short_url.code, result2.short_url.code
  end

  test "returns failure for invalid URL" do
    result = ShortUrlCreator.call("not-a-url")

    assert result.failure?
    assert result.success? == false
    assert_equal "Invalid URL", result.error
    assert_nil result.short_url
  end

  test "returns failure for blank URL" do
    result = ShortUrlCreator.call("")

    assert result.failure?
    assert_equal "Invalid URL", result.error
  end

  test "returns failure for nil URL" do
    result = ShortUrlCreator.call(nil)

    assert result.failure?
    assert_equal "Invalid URL", result.error
  end

  test "returns failure for URL with no domain extension" do
    result = ShortUrlCreator.call("notadomain")

    assert result.failure?
    assert_equal "Invalid URL", result.error
  end

  test "does not create record for invalid URL" do
    assert_no_difference "ShortUrl.count" do
      ShortUrlCreator.call("invalid-url")
    end
  end

  test "stores Unknown Title when TitleFetcher fails" do
    TitleFetcher.stubs(:fetch).returns("Unknown Title")

    result = ShortUrlCreator.call("example.com")

    assert result.success?
    assert_equal "Unknown Title", result.short_url.title
  end
end
