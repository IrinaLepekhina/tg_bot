# app/services/rabbitmq_connection.rb

class RabbitmqConnection
  extend Loggable   # For class methods

  @connection = nil
  @mutex = Mutex.new

  def self.connection(connection_name: "DefaultConnection")
    @mutex.synchronize do
      return @connection if @connection && @connection.open?
      establish_connection(connection_name: connection_name)
    end
  end

  def self.create_channel
    log_info("Attempting to create new channel")
    @connection.create_channel if @connection && @connection.open?
  end

  private_class_method def self.establish_connection(connection_name:)
    log_info("Attempting to establish RabbitMQ connection with name: #{connection_name}")
    
    connection = Bunny.new(
      hostname: RabbitmqSettings[:hostname],
      port:     RabbitmqSettings[:port],
      vhost:    RabbitmqSettings[:vhost],
      user:     RabbitmqSettings[:username],
      password: RabbitmqSettings[:password],
      heartbeat: 10,
      automatic_recovery: true,
      recovery_interval: 5,
      connection_name: connection_name
    )
    
    begin
      connection.start
      @connection = connection
    rescue => e
      log_exception(e)
      nil
    end
  end

  def self.close_connection(connection)
    @mutex.synchronize do
      if connection && connection.open?
        log_info("Closing RabbitMQ connection")
        connection.close
      end
    end
  end
end