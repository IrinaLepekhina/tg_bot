# app/services/redis_storage_service.rb

class RedisStorageService
  include Loggable

  def initialize(language_service = nil)
    begin
      @redis = Redis.new(host: "#{ENV['REDIS_HOST_BOT']}", port: "#{ENV['REDIS_PORT_BOT']}".to_i)
      log_info("Successfully initialized Redis connection")
    rescue => e
      log_exception(e)
      raise e
    end
  end

  def client
    @redis
  end
end