# config/routes.rb

require 'sidekiq/web'

Rails.application.routes.draw do
  mount Sidekiq::Web => '/sidekiq'
  telegram_webhook TelegramMuulWebhooksController, :muul

  root to: 'api/v1/welcome#index'
end
