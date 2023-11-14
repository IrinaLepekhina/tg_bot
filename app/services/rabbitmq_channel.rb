# app/services/rabbitmq_channel.rb

class RabbitmqChannel
  extend Loggable   # For class methods

  # A hash that maps connections to their respective channel pools
  # shared across all instances
  @channel_pools = {}
  @pools_mutex = Mutex.new

  # Retrieves or creates a channel pool for the given connection
  def self.channel_pool_for(connection)
    # Ensure that only one thread at a time can modify the @channel_pools hash
    @pools_mutex.synchronize do
      @channel_pools[connection] ||= RabbitmqChannelPool.new(connection)
    end
  end

  # This method optionally accepts a return_to_pool flag and a block.
  # If the flag is not provided, the RabbitmqChannelPool's default behavior is used.
  def self.channel(connection, return_to_pool: nil, &block)
    log_info("Attempting to get RabbitMQ channel from pool for connection.")
    pool = channel_pool_for(connection)

    # Check if return_to_pool is explicitly provided, otherwise let the pool decide.
    return_to_pool_flag = return_to_pool.nil? ? {} : { return_to_pool: return_to_pool }

    if block_given?
      # If a block is given, pass the block and the flag to with_channel.
      pool.with_channel(**return_to_pool_flag, &block)
    else
      # If no block is given, fetch a channel and return it,
      # respecting the pool's default return_to_pool behavior.
      pool.with_channel(**return_to_pool_flag) { |ch| ch }
    end
  end
   
  def self.reset_channel(connection)
    log_info("Resetting RabbitMQ channel for connection.")
    @pools_mutex.synchronize do
      # Closing all channels in the pool for the connection
      if @channel_pools[connection]
        @channel_pools[connection].shutdown
        log_info("All channels in pool for connection have been closed.")
      end
      # Removing the pool from the hash
      @channel_pools.delete(connection)
      log_info("Channel pool for connection has been deleted.")
    end
  end
end