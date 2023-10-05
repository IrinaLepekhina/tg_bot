# app/jobs/process_user_message_job.rb

class ProcessUserMessageJob < ApplicationJob
  include Loggable
  include ExceptionHandler

  queue_as :default

  BASE_URL =  ENV['WEB_URL']

  def perform(**args)
    conversation_id = args[:conversation_id]
    content         = args[:content]
    bot_id          = args[:bot_id]
    
    log_info("Starting ProcessUserMessageJob", conversation_id: conversation_id)
    
    request_wrapper = RequestWrapper.new
    create_or_find_conversation(conversation_id, request_wrapper)
    
    api_request = { conversation_id: conversation_id, content: content }
    api_response = send_request_to_api(api_request, request_wrapper)
    
    unless api_response&.status == 201
      raise ExceptionHandler::APIResponseError, "API Response received with status: #{api_response.status}, body: #{api_response.body}"
    end

    parsed_data = JSON.parse(api_response.body)
    telegram_response = translate_to_telegram_response(parsed_data)
    send_telegram_message(conversation_id, telegram_response, bot_id)
    log_info("Finished ProcessUserMessageJob", conversation_id: conversation_id)

  rescue Faraday::ConnectionFailed, Faraday::TimeoutError => e
    log_error("Connection or timeout error occurred: #{e.message}", conversation_id: conversation_id)
    send_error_message_to_telegram(conversation_id, bot_id)

  rescue JSON::ParserError
    log_error("JSON parsing error", conversation_id: conversation_id)
    send_error_message_to_telegram(conversation_id, bot_id)

  rescue ArgumentError => e
    log_error("Argument error: #{e.message}", conversation_id: conversation_id)
    if e.message.include?("Invalid bot_id")
      send_error_message_to_telegram(conversation_id, bot_id, "Invalid bot ID.")
    else
      send_error_message_to_telegram(conversation_id, bot_id)
    end

  rescue ExceptionHandler::APIResponseError => e
    log_error("API Response error: #{e.message}", conversation_id: conversation_id)
    send_error_message_to_telegram(conversation_id, bot_id)
  
  rescue StandardError => e
    log_error("An unexpected error occurred: #{e.message}", conversation_id: conversation_id)
    send_error_message_to_telegram(conversation_id, bot_id)
  end

  def create_or_find_conversation(conversation_id, request_wrapper)
    url = "#{BASE_URL}/conversations"
    response = request_wrapper.post(url, { conversation_id: conversation_id }.to_json)
  end
  
  def send_request_to_api(api_request, request_wrapper)
    conversation_id = api_request[:conversation_id]
    content = api_request[:content]

    unless conversation_id && content
      log_error("Missing data in api_request", api_request: api_request)
      return
    end

    url = "#{BASE_URL}/conversations/#{conversation_id}/chat_entries"

    log_info("Sending API request", url: url, request_body: api_request[:content])

    response = request_wrapper.post(url, { chat_entry: { content: api_request[:content] } }.to_json)

    log_info("API Response received", status: response.status, body: response.body)
    response
  end

  def translate_to_telegram_response(api_response)
    api_response['ai_response_content']
  end

  def send_telegram_message(conversation_id, telegram_response, bot_id)
    unless ['muul'].include?(bot_id)
      raise ArgumentError, "Invalid bot_id: #{bot_id}. Expected 'muul'."
    end

    bot = Telegram.bots[bot_id.to_sym]
    
    if bot.nil?
      log_error("Bot not found for bot_id: #{bot_id}", conversation_id: conversation_id)
      return
    end
  
    return if telegram_response.nil?

    bot.send_message(chat_id: conversation_id, text: telegram_response)
  end

  def send_error_message_to_telegram(conversation_id, bot_id, custom_message = nil)
    error_message = custom_message || "Sorry, we encountered an unexpected error processing your message. Please try again later."
  
    bot = Telegram.bots[bot_id.to_sym]
  
    if bot.nil?
      raise ArgumentError, "Invalid bot_id: #{bot_id}"
    end
  
    bot.send_message(chat_id: conversation_id, text: error_message)
  end
end
