require 'ipaddr'

class IpLookupService
  # Loopback / private ranges we should never send to an external geo API.
  PRIVATE_RANGES = [
    IPAddr.new('127.0.0.0/8'),
    IPAddr.new('10.0.0.0/8'),
    IPAddr.new('172.16.0.0/12'),
    IPAddr.new('192.168.0.0/16'),
    IPAddr.new('169.254.0.0/16'),
    IPAddr.new('::1/128'),
    IPAddr.new('fc00::/7')
  ].freeze

  CACHE_TTL = 7.days

  def self.lookup(ip)
    return nil if ip.blank? || private_ip?(ip)

    cached = Rails.cache.read(cache_key(ip))
    return cached if cached

    response = Faraday.get("http://ip-api.com/json/#{ip}")
    return nil unless response.success?

    data = JSON.parse(response.body)
    Rails.cache.write(cache_key(ip), data, :expires_in => CACHE_TTL) if data['status'] != 'fail'
    data
  rescue
    nil
  end

  def self.private_ip?(ip)
    addr = IPAddr.new(ip.to_s)
    PRIVATE_RANGES.any? { |range| range.include?(addr) }
  rescue IPAddr::InvalidAddressError
    false
  end

  def self.cache_key(ip)
    "ip_lookup/#{ip}"
  end
end
