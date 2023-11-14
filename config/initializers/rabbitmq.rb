# tg_bot/config/initializers/rabbitmq.rb

# Load and parse the RabbitMQ configuration file
rabbitmq_config_path = Rails.root.join('config', 'rabbitmq.yml')
rabbitmq_config = YAML.safe_load(ERB.new(File.read(rabbitmq_config_path)).result)[Rails.env].symbolize_keys

# Create a global settings object for RabbitMQ configurations
RabbitmqSettings = ActiveSupport::InheritableOptions.new(rabbitmq_config)
