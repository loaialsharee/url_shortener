class Rack::Attack
  Rack::Attack.cache.store = Rails.cache

  class Request < ::Rack::Request
    def remote_ip
      @remote_ip ||= (env['HTTP_CF_CONNECTING_IP'] || 
                      env['HTTP_X_FORWARDED_FOR']&.split(',')&.first&.strip || 
                      ip)
    end
  end

  throttle("url_creation/ip", limit: 7, period: 2.minute) do |req|
    if req.post? && req.path == "/shorten"
      ip = req.remote_ip
      
      cache_key = "rack::attack:#{Time.now.to_i / 120}:url_creation/ip:#{ip}"
      Rails.cache.read(cache_key)
      
      Rails.logger.info "[RACK ATTACK] POST /shorten from IP: #{ip}"
      
      ip 
    end
  end

  throttle("analytics/ip", limit: 30, period: 2.minute) do |req|
    if req.get? && req.path.start_with?("/analytics/")
      ip = req.remote_ip

      cache_key = "rack::attack:#{Time.now.to_i / 120}:analytics/ip:#{ip}"
      Rails.cache.read(cache_key)

      Rails.logger.info "[RACK ATTACK] GET /analytics/* from IP: #{ip}"
      
      ip
    end
  end

  self.throttled_responder = lambda do |req|
    match_data = req.env["rack.attack.match_data"]

    Rails.logger.warn "[RACK ATTACK] THROTTLED! IP: #{req.remote_ip} | Path: #{req.path}"

    retry_after = match_data[:period] - (Time.now.to_i % match_data[:period])

    [
      429,
      {
        "Content-Type" => "application/json",
        "Retry-After" => retry_after.to_s
      },
      [
        {
          error: "Too many requests! Please try again in #{retry_after} seconds."
        }.to_json
      ]
    ]
  end
end
