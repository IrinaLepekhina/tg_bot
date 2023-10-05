#!/usr/bin/env ruby
# bin/set_telegram_webhook.rb
require 'erb'

require 'faraday'
require 'telegram/bot'
require 'yaml'

APP_ROOT = File.expand_path("..", __dir__)

# Load the secrets configuration
erb_content = ERB.new(File.read("#{APP_ROOT}/config/secrets.yml")).result
secrets = YAML.safe_load(erb_content)

# Determine the environment (development or production)
rails_env = ENV['RAILS_ENV'] || 'development'

telegram_config = if rails_env == 'development'
  secrets['development']['telegram']['bots']
elsif rails_env == 'production'
  secrets['production']['telegram']['bots']
else
  raise "Unknown environment: #{rails_env}"
end

puts telegram_config

host = ENV['DEFAULT_HOST']

if host.nil? || host.empty?
  abort("HOST not set #{ENV['DEFAULT_HOST']}")
end

url = "https://#{host}"

telegram_conn = Faraday.new

telegram_config.each do |bot_name, bot_config, webhook_token|
  token = bot_config['token']
  webhook_token = bot_config['webhook_token']
  next if token.nil? || token.empty?

  webhook_url = "#{url}/telegram/#{webhook_token}"

  response = telegram_conn.get("https://api.telegram.org/bot#{token}/setWebhook", url: webhook_url)

  puts "Webhook set for bot #{bot_name} to: #{url}"
  puts response.body
end
