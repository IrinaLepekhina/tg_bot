# app/transactions/webhook_message_transaction.rb

require_relative '../contracts/webhook_message_contract'

class WebhookMessageTransaction
  include Dry::Transaction
  include Loggable

  step :validate_message
  step :process_message

  private

  def validate_message(input)
    input = input.with_indifferent_access
    log_info("Starting validation for message")
    result = ::Contracts::WebhookMessageContract.call(input)
  
    if result.success?
      log_info("Validation successful for message")
      Success(input)
    else
      log_error("Validation failed for message", conversation_id: input[:conversation_id], errors: result.errors.to_h)
      Failure(result.errors.to_h)
    end
  end

  def process_message(input)
    input = input.with_indifferent_access

    log_info("Starting processing for message")

    ProcessWebhookMessageJob.perform_later(input)
    log_info("Processing scheduled successfully for message")

    Success("Message processed successfully")
  rescue => e
    log_error("Processing failed for message", conversation_id: input[:conversation_id], error: e.message)
    Failure(e.message)
  end
end