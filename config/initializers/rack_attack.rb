class Rack::Attack
  BLOCKED_RANGES = %w(
    51.222.253 85.208.96 195.191.219 91.242.162
    193.169 45.155 89.104 193.27 185.191
  )

  ALLOWED_CRAWLERS = {
    'google' => {
      ips: ['66.249'],
      agent: /Googlebot/i
    },
    'bing' => {
      ips: ['114.119', '40.74', '157.55.39', '199.30.228', '207.46.13'],
      agent: /Bingbot/i
    },
    'apple' => {
      ips: ['17'],
      agent: /Applebot/i
    },
    'linkedin' => {
      ips: ['52.142'],
      agent: /LinkedInBot/i
    },
    'gpt' => {
      ips: ['20.74'],
      agent: /GPTBot/i
    }
  }

  # Block malicious IPs
  blocklist('block bad ips') do |req|
    BLOCKED_RANGES.any? { |range| req.ip.start_with?(range) }
  end

  # Allow legitimate crawlers
  ALLOWED_CRAWLERS.each do |name, config|
    safelist("allow #{name}") do |req|
      config[:ips].any? { |ip| req.ip.start_with?(ip) } &&
        req.user_agent =~ config[:agent]
    end
  end

  # Rate limiting
  throttle('req/ip', limit: 1000, period: 5.minutes) do |req|
    req.ip unless req.path.start_with?('/assets/')
  end
end
