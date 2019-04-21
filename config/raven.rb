require 'bundler'
Bundler.require

Raven.configure do |config|
  config.dsn = ENV['SENTRY_DSN']
end
