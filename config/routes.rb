# config/routes.rb
Rails.application.routes.draw do
  telegram_webhook TelegramMuulWebhooksController, :muul

  root to: 'api/v1/welcome#index'
end
