# app/services/redis_storage_service.rb

class RedisStorageService
  include Loggable

  def initialize(language_service = nil)
    begin
      @redis = Redis.new(host: "redis", port: 6379)
      log_info("Successfully initialized Redis connection", host: "redis", port: 6379)
    rescue => e
      log_exception(e)
      raise e
    end
  end

  def client
    @redis
  end
end