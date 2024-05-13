Sidekiq.configure_server do |config|
  # We define the hostname here as 'redis' because we are running redis in a docker container
  # and the name of the service is 'redis'
  config.redis = { url: 'redis://redis:6379/0' }
end

Sidekiq.configure_client do |config|
  config.redis = { url: 'redis://redis:6379/0' }
end

