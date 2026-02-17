require "test_helper"

class ShortUrlTest < ActiveSupport::TestCase
  test "validates presence of target_url" do
    short_url = ShortUrl.new(code: "abc123", title: "Test")
    
    assert_not short_url.valid?
    assert_includes short_url.errors[:target_url], "can't be blank"
  end

  test "validates presence of code" do
    short_url = ShortUrl.new(target_url: "https://example.com", title: "Test")
    
    assert_not short_url.valid?
    assert_includes short_url.errors[:code], "can't be blank"
  end

  test "validates uniqueness of code" do
    ShortUrl.create!(
      target_url: "https://example.com",
      code: "abc123",
      title: "Test"
    )
    
    duplicate = ShortUrl.new(
      target_url: "https://other.com",
      code: "abc123",
      title: "Test"
    )
    
    assert_not duplicate.valid?
    assert_includes duplicate.errors[:code], "has already been taken"
  end

  test "validates maximum length of code" do
    short_url = ShortUrl.new(
      target_url: "https://example.com",
      code: "a" * 16, 
      title: "Test"
    )
    
    assert_not short_url.valid?
    assert_includes short_url.errors[:code], "is too long (maximum is 15 characters)"
  end

  test "accepts code at maximum length" do
    short_url = ShortUrl.new(
      target_url: "https://example.com",
      code: "a" * 15,  
      title: "Test"
    )
    
    assert short_url.valid?
  end

  test "creates valid short url with all required fields" do
    short_url = ShortUrl.new(
      target_url: "https://example.com",
      code: "abc123",
      title: "Example"
    )
    
    assert short_url.valid?
    assert short_url.save
  end

  test "has many visits" do
    short_url = create_short_url
    
    Visit.create!(
      short_url: short_url,
      ip_address: "127.0.0.1",
      country: "Malaysia",
      visited_at: Time.current
    )
    
    Visit.create!(
      short_url: short_url,
      ip_address: "192.168.1.1",
      country: "Singapore",
      visited_at: Time.current
    )
    
    assert_equal 2, short_url.visits.count
  end

  test "destroys associated visits when destroyed" do
    short_url = create_short_url
    
    3.times do
      Visit.create!(
        short_url: short_url,
        ip_address: "127.0.0.1",
        country: "Malaysia",
        visited_at: Time.current
      )
    end
    
    assert_difference "Visit.count", -3 do
      short_url.destroy
    end
  end

  test "allows same target_url with different codes" do
    ShortUrl.create!(
      target_url: "https://example.com",
      code: "abc123",
      title: "Test"
    )
    
    duplicate_url = ShortUrl.new(
      target_url: "https://example.com",
      code: "xyz789",
      title: "Test"
    )
    
    assert duplicate_url.valid?
  end
end