class IpLookupService
  def self.lookup(ip)
    return nil if ip.blank?

    response = Faraday.get("http://ip-api.com/json/#{ip}")
    return nil unless response.success?

    JSON.parse(response.body)
  rescue
    nil
  end
end
