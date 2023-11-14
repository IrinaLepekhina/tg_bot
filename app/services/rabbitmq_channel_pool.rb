# app/services/rabbitmq_channel_pool.rb

class RabbitmqChannelPool
  include Loggable

  MAX_RETRIES     = 3 # maximum number of retries for popping a channel
  RETRY_WAIT_TIME = 1 # seconds to wait before retry

  def initialize(connection, max_pool_size = ENV.fetch('RABBITMQ_CHANNEL_POOL_SIZE', 10).to_i)
    log_info("Initializing RabbitMQ Channel Pool with max size #{max_pool_size}.")
    @connection = connection
    @pool = SizedQueue.new(max_pool_size)
    populate_channel_pool(max_pool_size)
  end

  def with_channel(return_to_pool: true, &block)
    retries = 0
    channel = nil
  
    begin
      log_info("Attempting to retrieve a channel from the pool.")
      channel = @pool.pop(true)
      log_info("Channel #{channel.object_id} retrieved from the pool.")
      
      yield channel if block_given?
    rescue ThreadError
      if retries < MAX_RETRIES
        retries += 1
        log_error("ThreadError: Timed out waiting for an available channel from the pool. Retrying... (Attempt #{retries} of #{MAX_RETRIES})")
        sleep RETRY_WAIT_TIME
        retry
      else
        log_error("ThreadError: Timed out waiting for an available channel from the pool after #{MAX_RETRIES} attempts.")
        return nil
      end
    ensure
      # Only return the channel to the pool if no block is given or return_to_pool is true
      if channel && return_to_pool
        log_info("Returning channel #{channel.object_id} to the pool.")
        @pool.push(channel)
      elsif channel
        log_info("Keeping channel #{channel.object_id} open.")
      end
    end
  end

  def shutdown
    log_info("Shutting down RabbitMQ Channel Pool.")
    until @pool.empty?
      channel = @pool.pop
      if channel.open?
        log_info("Closing channel #{channel.object_id}.")
        channel.close
      end
    end
    log_info("RabbitMQ Channel Pool shut down successfully.")
  end

  private

  def populate_channel_pool(size)
    size.times do |i|
      log_info("Creating channel #{i + 1} of #{size}.")
      if (channel = create_channel)
        @pool.push(channel)
        log_info("Channel #{channel.object_id} created and added to the pool.")
      else
        log_error("Failed to create channel #{i + 1}/#{size}.")
      end
    end
  end

  def create_channel
    log_info("Attempting to create a new RabbitMQ channel.")
    channel = @connection.create_channel
    log_info("@connection: #{@connection.inspect}")
    log_info("channel: #{channel.inspect}")
    log_info("New RabbitMQ channel created: #{channel.object_id}.")
    channel
  rescue Bunny::Exception => e
    log_error("Bunny::Exception: Failed to create a RabbitMQ channel: #{e.message}.")
    nil
  end
end