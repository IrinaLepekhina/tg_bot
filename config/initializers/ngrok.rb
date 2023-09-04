# config/initializers/ngrok.rb
require 'dotenv'
Dotenv.load(File.expand_path("../../.env", __dir__))

Rails.application.configure do
  config.hosts << ENV['NGROK_HOST'] if ENV['NGROK_HOST'].present?
end