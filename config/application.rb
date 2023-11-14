# config/application.rb

require_relative "boot"

require "rails/all"
require 'dotenv/load'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups(
  assets: %i[development test],
  pry:    %i[development test],
))
# load pry for production console
Bundler.require(:pry) if defined?(Rails::Console)

module TelegramBotApp
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.0

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")

    # added
    # Add additional load paths for your own custom dirs.
    config.autoload_paths << Rails.root.join('services')
    config.autoload_paths << Rails.root.join('lib')
    config.autoload_paths << Rails.root.join('transactions')
    config.autoload_paths << Rails.root.join('contracts')
  end
end
