require "test_helper"

class GeoIpServiceTest < ActiveSupport::TestCase
  test "returns Unknown for localhost IPv4" do
    assert_equal "Unknown", GeoIpService.lookup("127.0.0.1")
  end

  test "returns Unknown for localhost IPv6" do
    assert_equal "Unknown", GeoIpService.lookup("::1")
  end

  test "returns Unknown for blank IP" do
    assert_equal "Unknown", GeoIpService.lookup("")
  end

  test "returns Unknown for nil IP" do
    assert_equal "Unknown", GeoIpService.lookup(nil)
  end

  test "handles API rate limiting (429 status)" do
    response = Struct.new(:status, :body).new(429, "Rate limited")
    
    result = GeoIpService.handleResponse(response)
    assert_equal "Unknown", result
  end

  test "handles successful response with country name" do
    response = Struct.new(:status, :body).new(200, "Malaysia")
    
    result = GeoIpService.handleResponse(response)
    assert_equal "Malaysia", result
  end

  test "handles rate limit message in response body" do
    response = Struct.new(:status, :body).new(200, "Too many rapid requests")
    
    result = GeoIpService.handleResponse(response)
    assert_equal "Unknown", result
  end

  test "handles blank response body" do
    response = Struct.new(:status, :body).new(200, "")
    
    result = GeoIpService.handleResponse(response)
    assert_equal "Unknown", result
  end

  test "handles non-200 status codes" do
    response = Struct.new(:status, :body).new(500, "Internal Server Error")
    
    result = GeoIpService.handleResponse(response)
    assert_equal "Unknown", result
  end

  test "strips whitespace from country name" do
    response = Struct.new(:status, :body).new(200, "  Malaysia  ")
    
    result = GeoIpService.handleResponse(response)
    assert_equal "Malaysia", result
  end
end