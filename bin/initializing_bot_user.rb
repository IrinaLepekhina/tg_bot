#!/usr/bin/env ruby
# bin/initializing_bot_user.rb

require_relative '../config/environment'

auth_service = BotAuthService.new
if auth_service.initialize_bot
  puts "Bot user initialized successfully."
else
  puts "Failed to initialize bot user."
end