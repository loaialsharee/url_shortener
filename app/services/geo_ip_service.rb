class GeoIpService
  def self.lookup(ip)
    return "Unknown" if ip.blank? || ip == "127.0.0.1" || ip == "::1"

    response = Faraday.get("https://ipapi.co/#{ip}/country_name/")
    response.body.presence || "Unknown"
  rescue
    "Unknown"
  end
end
