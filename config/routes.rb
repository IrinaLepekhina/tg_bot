# config/routes.rb
Rails.application.routes.draw do
  telegram_webhook TelegramMuulWebhooksController, :muul
end
