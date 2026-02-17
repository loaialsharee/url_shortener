require "test_helper"

class TitleFetcherTest < ActiveSupport::TestCase
  test "returns Unknown Title when URL is unreachable" do
    connection = mock('connection')
    connection.stubs(:get).raises(Faraday::ConnectionFailed.new("Connection refused"))
    
    Faraday.stubs(:new).returns(connection)
    
    result = TitleFetcher.fetch("https://unreachable-site.com")
    assert_equal "Unknown Title", result
  end

  test "returns Unknown Title on timeout" do
    connection = mock('connection')
    connection.stubs(:get).raises(Faraday::TimeoutError.new("Timeout"))
    
    Faraday.stubs(:new).returns(connection)
    
    result = TitleFetcher.fetch("https://slow-site.com")
    assert_equal "Unknown Title", result
  end

  test "returns Unknown Title when response is not successful" do
    response = Struct.new(:success?, :status, :body).new(false, 404, "Not Found")
    connection = mock('connection')
    connection.stubs(:get).returns(response)
    
    Faraday.stubs(:new).returns(connection)
    
    result = TitleFetcher.fetch("https://example.com/notfound")
    assert_equal "Unknown Title", result
  end

  test "extracts title from valid HTML" do
    html = "<html><head><title>Test Page Title</title></head><body></body></html>"
    response = Struct.new(:success?, :status, :body).new(true, 200, html)
    connection = mock('connection')
    connection.stubs(:get).returns(response)
    
    Faraday.stubs(:new).returns(connection)
    
    result = TitleFetcher.fetch("https://example.com")
    assert_equal "Test Page Title", result
  end

  test "returns Unknown Title when HTML has no title tag" do
    html = "<html><head></head><body>No title here</body></html>"
    response = Struct.new(:success?, :status, :body).new(true, 200, html)
    connection = mock('connection')
    connection.stubs(:get).returns(response)
    
    Faraday.stubs(:new).returns(connection)
    
    result = TitleFetcher.fetch("https://example.com")
    assert_equal "Unknown Title", result
  end

  test "returns Unknown Title when title tag is empty" do
    html = "<html><head><title></title></head><body></body></html>"
    response = Struct.new(:success?, :status, :body).new(true, 200, html)
    connection = mock('connection')
    connection.stubs(:get).returns(response)
    
    Faraday.stubs(:new).returns(connection)
    
    result = TitleFetcher.fetch("https://example.com")
    assert_equal "Unknown Title", result
  end

  test "strips whitespace from title" do
    html = "<html><head><title>  Whitespace Title  </title></head><body></body></html>"
    response = Struct.new(:success?, :status, :body).new(true, 200, html)
    connection = mock('connection')
    connection.stubs(:get).returns(response)
    
    Faraday.stubs(:new).returns(connection)
    
    result = TitleFetcher.fetch("https://example.com")
    assert_equal "Whitespace Title", result
  end

  test "handles malformed HTML gracefully" do
    html = "<html><head><title>Broken HTML"
    response = Struct.new(:success?, :status, :body).new(true, 200, html)
    connection = mock('connection')
    connection.stubs(:get).returns(response)
    
    Faraday.stubs(:new).returns(connection)
    
    result = TitleFetcher.fetch("https://example.com")
    assert_equal "Broken HTML", result
  end

  test "handles special characters in title" do
    html = "<html><head><title>Test & Title – Special 'Chars'</title></head><body></body></html>"
    response = Struct.new(:success?, :status, :body).new(true, 200, html)
    connection = mock('connection')
    connection.stubs(:get).returns(response)
    
    Faraday.stubs(:new).returns(connection)
    
    result = TitleFetcher.fetch("https://example.com")
    assert_equal "Test & Title – Special 'Chars'", result
  end

  test "returns Unknown Title on any StandardError" do
    connection = mock('connection')
    connection.stubs(:get).raises(StandardError.new("Unexpected error"))
    
    Faraday.stubs(:new).returns(connection)
    
    result = TitleFetcher.fetch("https://example.com")
    assert_equal "Unknown Title", result
  end
end