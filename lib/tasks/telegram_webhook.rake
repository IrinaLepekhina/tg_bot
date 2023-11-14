# lib/tasks/telegram_webhook.rake

require 'erb'
require 'faraday'
require 'telegram/bot'
require 'yaml'

namespace :telegram do
  desc "Set Telegram webhook for the bot"
  task set_webhook: :environment do
    APP_ROOT = Rails.root.to_s

    erb_content = ERB.new(File.read("#{APP_ROOT}/config/secrets.yml")).result
    secrets = YAML.safe_load(erb_content)

    rails_env = ENV['RAILS_ENV'] || 'development'

    telegram_config = if rails_env == 'development'
                        secrets['development']['telegram']['bots']
                      elsif rails_env == 'production'
                        secrets['production']['telegram']['bots']
                      else
                        raise "Unknown environment: #{rails_env}"
                      end

    host = ENV['DEFAULT_HOST']
    abort("HOST not set #{ENV['DEFAULT_HOST']}") if host.nil? || host.empty?
    url = "https://#{host}"

    telegram_conn = Faraday.new

    telegram_config.each do |bot_name, bot_config|
      token = bot_config['token']
      webhook_token = bot_config['webhook_token']
      next if token.nil? || token.empty?

      webhook_url = "#{url}/telegram/#{webhook_token}"
      puts "Attempting to set webhook for bot #{bot_name}"

      response = telegram_conn.get("https://api.telegram.org/bot#{token}/setWebhook", url: webhook_url)

      puts "Webhook set for bot #{bot_name} to: #{url}"
      puts response.body
    end
  end
end
