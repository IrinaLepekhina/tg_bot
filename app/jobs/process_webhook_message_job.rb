# app/jobs/process_webhook_message_job.rb

class ProcessWebhookMessageJob < ApplicationJob
  include Loggable

  queue_as :default

  DEFAULT_ERROR_MESSAGE = 'Sorry, we encountered an unexpected error processing your message. Please try again later.'.freeze

  def perform(args)
    log_info("Starting ProcessWebhookMessageJob")

    publish_to_rabbitmq(args)

    log_info("Message sent to AI", conversation_id: args[:conversation_id])
  rescue StandardError => error
    handle_error(error, args)
  end

  private
  def publish_to_rabbitmq(args)
    result = RabbitmqPublisher.new.call(
      message: construct_message_from(args), 
      exchange_name:  ENV['PUBLISHING_EXCHANGE_NAME'],
      routing_key:    ENV['PUBLISHING_ROUTING_KEY']
      )
      
    if result.success?
      log_info(result.success, conversation_id: args[:conversation_id])
    else
      error_message = result.failure.respond_to?(:message) ? result.failure.message : result.failure
      log_error("An error occurred: #{error_message}", conversation_id: args[:conversation_id])
      send_error_message_to_telegram(args[:conversation_id], args[:bot_id])
    end
  end
  
  def construct_message_from(args)
    args.slice(:conversation_id, :content, :bot_id, :date).to_json
  end

  def handle_error(error, args)
    log_error("An error occurred: #{error.message}", conversation_id: args[:conversation_id])
    send_error_message_to_telegram(args[:conversation_id], args[:bot_id])
  end

  def send_error_message_to_telegram(conversation_id, bot_id, custom_message = DEFAULT_ERROR_MESSAGE)
    bot = Telegram.bots[bot_id.to_sym]
    bot&.send_message(chat_id: conversation_id, text: custom_message)
  end
end