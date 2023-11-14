# lib/tasks/initialize_bot.rake

namespace :bot do
    desc "Initialize bot user"
    task initialize_user: :environment do
      auth_service = BotAuthService.new
      if auth_service.initialize_bot
        puts "Bot user initialized successfully."
      else
        puts "Failed to initialize bot user."
      end
    end
  end