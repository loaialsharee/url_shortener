class GeoIpService
  def self.lookup(ip)
    return "Unknown" if ip.blank? || ip == "127.0.0.1" || ip == "::1"

    response = Faraday.get("https://ipapi.co/#{ip}/country_name/")
    handleResponse(response)
  rescue
    "Unknown"
  end

  def self.handleResponse(response)
    case response.status
    when 200
      country = response.body.to_s.strip

      return "Unknown" if country.include?("Too many rapid requests")
      return "Unknown" if country.blank?

      country

    when 429
      Rails.logger.warn("GeoIpService rate limited (429)")
      "Unknown"

    else
      Rails.logger.warn("GeoIpService failed with status #{response.status}")
      "Unknown"
    end
  end
end
