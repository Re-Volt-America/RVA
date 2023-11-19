# frozen_string_literal: true

Github.configure do |config|
  config.stack = proc do |builder|
    builder.use Faraday::HttpCache, :store => Rails.cache, :serializer => Marshal
    builder.adapter Faraday.default_adapter
  end
end
