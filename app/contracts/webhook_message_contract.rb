# app/contracts/webhook_message_contract.rb

module Contracts

  WebhookMessageContract = Dry::Validation::Contract.build do
    include Loggable

    params do
      required(:conversation_id).filled(:integer)
      required(:content).filled(:string)
      required(:bot_id).filled(:string)
      required(:date).filled(:integer)
    end

    def call(input)
      log_info("Inside contract validation")
      
      result = super(input)
    end
  end
end