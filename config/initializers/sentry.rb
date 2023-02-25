Sentry.init do |config|
  return

  config.dsn = 'https://965601ed7d9b4e7f83ef49c4255b88c3@o4504597756903424.ingest.sentry.io/4504730242777088'
  config.breadcrumbs_logger = [:active_support_logger, :http_logger]

  # Set traces_sample_rate to 1.0 to capture 100%
  # of transactions for performance monitoring.
  # We recommend adjusting this value in production.
  config.traces_sample_rate = 1.0
  # or
  config.traces_sampler = lambda do |context|
    true
  end
end
