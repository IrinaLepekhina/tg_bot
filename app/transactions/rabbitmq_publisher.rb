# app/transactions/rabbitmq_publisher.rb

class RabbitmqPublisher
  include Dry::Transaction
  include Loggable
  
  step :get_connection
  step :get_channel_and_publish_message

  private

  def get_connection(input)
    log_info("Attempting to get RabbitMQ connection")

    connection = RabbitmqConnection.connection(connection_name: "publisher")
    if connection
      log_info("Successfully obtained RabbitMQ connection")
      Success(connection: connection, message: input[:message], exchange_name: input[:exchange_name], routing_key: input[:routing_key])
    else
      log_error("Failed to get a RabbitMQ connection")
      Failure("Failed to get a RabbitMQ connection")
    end
  end

  # Use the connection to get a channel and publish within a block
  def get_channel_and_publish_message(input)
    log_info("Attempting to get RabbitMQ channel and publish message")

    result = RabbitmqChannel.channel(input[:connection]) do |channel|
      begin
        log_info("Publishing message to RabbitMQ")

        exchange_name = input[:exchange_name]
        message       = input[:message]
        routing_key   = input[:routing_key]
        
        direct_exchange = channel.direct(exchange_name, durable: true)
        direct_exchange.publish(message, routing_key: routing_key, persistent: true)
        
        log_info("Message successfully published to RabbitMQ")
        :success
      rescue Bunny::ChannelLevelException => e
        log_exception(e)
        channel.close if channel.open?
        RabbitmqChannel.reset_channel(input[:connection])
        :channel_error
      rescue => e
        log_exception(e)
        :error
      end
    end

    case result
    when :success
      Success("Successfully published")
    when :channel_error
      Failure("Failed to publish due to a channel error")
    else
      Failure("Failed to publish due to an unexpected error")
    end
  end

  def self.publish(exchange_name, routing_key, message)
    new.call(exchange_name: exchange_name, routing_key: routing_key, message: message)
  end  
end
