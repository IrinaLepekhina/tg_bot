require 'rails_helper'

RSpec.describe WebhookMessageTransaction do
  let(:transaction)   { described_class.new }
  let(:valid_input)   { build(:transaction_input) }
  let(:invalid_input) { build(:transaction_input, content: nil) }

  describe '#validate_message' do
    context 'when the input is valid' do
      before do
        allow(transaction).to receive(:log_info)
      end

      it 'passes validation and logs success' do
        expect(transaction).to receive(:log_info).with("Starting validation for message").ordered
        expect(transaction).to receive(:log_info).with("Validation successful for message").ordered

        result = transaction.call(valid_input)

        expect(result).to be_success
      end
    end

    context 'when the input is invalid' do
      before do
        allow(transaction).to receive(:log_error)
      end

      it 'fails validation, logs failure, and contains error messages' do
        expect(transaction).to receive(:log_error).with(
          "Validation failed for message",
          hash_including(:conversation_id, :errors)
        )

        result = transaction.call(invalid_input)

        expect(result).to be_failure
        expect(result.failure).to have_key(:content)
        expect(result.failure[:content]).to include("must be filled")
      end
    end
  end

  describe '#process_message' do
    subject(:process_call) { transaction.call(valid_input) }
		
    context 'when the job execution is successful' do

      before do
        allow(ProcessWebhookMessageJob).to receive(:perform_later).and_return(true)
      end
			
      it 'enqueues the job and returns success' do
        expect(ProcessWebhookMessageJob).to receive(:perform_later).with(valid_input)

        expect(process_call).to be_success
        expect(process_call.success).to eq("Message processed successfully")
      end
    end

    context 'when there is an error executing the job' do
      let(:error_message) { "Some error" }

      before do
        allow(ProcessWebhookMessageJob).to receive(:perform_later).and_raise(StandardError, error_message)
      end

      it 'returns a failure with the error message' do
        expect(process_call).to be_failure
        expect(process_call.failure).to eq(error_message)
      end
    end
  end
end
