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

telegram_config = secrets['development']['telegram']['bots'] # Adjust this if your environment is different

puts telegram_config

host = ENV['NGROK_HOST']

if host.nil? || host.empty?
  abort("HOST not set")
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
