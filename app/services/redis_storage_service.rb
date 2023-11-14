# app/services/redis_storage_service.rb
class RedisStorageService
  include Loggable
  def initialize
    begin
      @redis = Redis.new(host: "#{ENV['REDIS_HOST']}", port: "#{ENV['REDIS_PORT']}".to_i)
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