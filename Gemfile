# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

gem 'dotenv-rails'
gem "telegram-bot", "~> 0.15.5"
gem 'faraday'
# gem 'attr_encrypted'

# Use JavaScript with ESM import maps [https://github.com/rails/importmap-rails]
gem "importmap-rails"

# Use Kredis to get higher-level data types in Redis [https://github.com/rails/kredis]
# gem "kredis"

gem 'rails', '~> 7.0.4'
gem 'sprockets-rails'
gem 'puma', '~> 5.0'
gem 'jsbundling-rails'
gem 'turbo-rails'
gem 'stimulus-rails'
gem 'cssbundling-rails'
gem 'jbuilder'
gem 'bootsnap', require: false

gem 'bcrypt'
gem 'jwt'

gem 'haml'
gem 'haml-rails'

gem 'active_model_serializers'
gem 'kaminari'
gem 'rouge'
gem 'nokogiri'

gem 'redis'
gem 'openai'
gem 'ruby-openai'
gem 'enumerize' 
gem 'redi_search' 

# good gems:
# gem letter_opener
# gem email-spec
# gem 'rack-attack'
# gem 'redcarpet', github: "vmg/redcarpet", branch: "master"
# gem 'carrierwave' # uploader

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem 'debug', platforms: %i[mri mingw x64_mingw]
  gem 'factory_bot_rails'
  gem 'rspec-rails'
  gem "rspec-its"

  gem 'rails-controller-testing'
  gem 'shoulda-matchers'

  gem 'spring'
  gem 'spring-commands-cucumber'
  gem 'spring-commands-rspec'

  gem 'rubocop', require: false
  gem 'rubocop-performance'
  gem 'rubocop-rails'
  gem 'rubocop-rspec', require: false
end

group :development do
  gem 'web-console'
  gem 'listen'
  gem 'spring-watcher-listen'

  gem 'guard-rspec', require: false

  gem 'yard'
end

group :test do
  gem 'capybara'
  gem 'database_cleaner'
  gem 'selenium-webdriver'
  gem 'webdrivers'
  gem 'faker'
  gem 'webmock'
end

group :pry do
  gem "awesome_print"
  gem "pry"
  gem "pry-byebug"
  gem "pry-doc"
  gem "pry-rails"
end

group :production do
  gem 'pg'
end