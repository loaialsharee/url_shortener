require "test_helper"

class VisitTest < ActiveSupport::TestCase
  test "belongs to short_url" do
    short_url = create_short_url
    
    visit = Visit.create!(
      short_url: short_url,
      ip_address: "127.0.0.1",
      country: "Malaysia",
      visited_at: Time.current
    )
    
    assert_equal short_url.id, visit.short_url_id
    assert_equal short_url, visit.short_url
  end

  test "creates visit with all attributes" do
    short_url = create_short_url
    time = Time.current
    
    visit = Visit.create!(
      short_url: short_url,
      ip_address: "192.168.1.1",
      country: "Singapore",
      visited_at: time
    )
    
    assert_equal "192.168.1.1", visit.ip_address
    assert_equal "Singapore", visit.country
    assert_equal time.to_i, visit.visited_at.to_i
  end

  test "allows multiple visits for same short_url" do
    short_url = create_short_url
    
    visit1 = Visit.create!(
      short_url: short_url,
      ip_address: "127.0.0.1",
      country: "Malaysia",
      visited_at: 1.hour.ago
    )
    
    visit2 = Visit.create!(
      short_url: short_url,
      ip_address: "192.168.1.1",
      country: "Singapore",
      visited_at: Time.current
    )
    
    assert visit1.persisted?
    assert visit2.persisted?
    assert_equal 2, short_url.visits.count
  end

  test "allows same IP to visit multiple times" do
    short_url = create_short_url
    
    visit1 = Visit.create!(
      short_url: short_url,
      ip_address: "127.0.0.1",
      country: "Malaysia",
      visited_at: 1.hour.ago
    )
    
    visit2 = Visit.create!(
      short_url: short_url,
      ip_address: "127.0.0.1",
      country: "Malaysia",
      visited_at: Time.current
    )
    
    assert visit1.persisted?
    assert visit2.persisted?
  end

  test "stores Unknown as country when GeoIP fails" do
    short_url = create_short_url
    
    visit = Visit.create!(
      short_url: short_url,
      ip_address: "127.0.0.1",
      country: "Unknown",
      visited_at: Time.current
    )
    
    assert_equal "Unknown", visit.country
  end
end