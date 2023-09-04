# config/initializers/loggable.rb

module Loggable
  def log_info(message, context = {})
    log_data = { message: message }.merge(context)
    Rails.logger.info(log_data.to_json)
  end
  
  def log_error(message, context = {})
    log_data = { message: message }.merge(context)
    Rails.logger.error(log_data.to_json)
  end
  
  def log_exception(e)
    log_error("Exception encountered: #{e.message}", backtrace: e.backtrace[0..10])
  end
end
