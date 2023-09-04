require 'rails_helper'

RSpec.describe ProcessUserMessageJob, type: :job do
  let(:conversation_id) { 123 }
  let(:content) { "test message" }
  let(:bot_id) { "muul" }
  let(:request_wrapper) { instance_double(RequestWrapper) }
  let(:api_response) { double(body: { ai_response_content: "Some response" }.to_json, status: 201) }

  before do
    allow(RequestWrapper).to  receive(:new).and_return(request_wrapper)
    allow(request_wrapper).to receive(:post).and_return(api_response)
    allow(Telegram.bots[bot_id.to_sym]).to receive(:send_message)
  end

  subject { described_class.perform_now(conversation_id: conversation_id, content: content, bot_id: bot_id) }

  shared_examples 'logs and notifies' do |log_msg, error_msg|
    it 'logs the error' do
      expect_any_instance_of(ProcessUserMessageJob).to receive(:log_error).with(log_msg, conversation_id: conversation_id)
      subject
    end

    it 'sends an error message to Telegram' do
      expect(Telegram.bots[bot_id.to_sym]).to receive(:send_message).with(chat_id: conversation_id, text: error_msg)
      subject
    end
  end

  context 'when performing the job' do
    it 'sends a request to the API to create or find conversation' do
      expect(request_wrapper).to receive(:post).with("#{ProcessUserMessageJob::BASE_URL}/conversations", { conversation_id: conversation_id }.to_json)
      subject
    end
  
    it 'sends a chat entry request to the API' do
      expect(request_wrapper).to receive(:post).with("#{ProcessUserMessageJob::BASE_URL}/conversations/#{conversation_id}/chat_entries", { chat_entry: { content: content } }.to_json)
      subject
    end
  
    it 'sends the correct message to Telegram' do
      subject
      expect(Telegram.bots[bot_id.to_sym]).to have_received(:send_message).with(chat_id: conversation_id, text: "Some response")
    end
  end 

  context 'when handling error scenarios' do
    context 'when passed an invalid bot_id' do
      let(:bot_id) { "invalid_bot" }
      it 'raises an ArgumentError' do
        expect { subject }.to raise_error(ArgumentError, /Invalid bot_id/)
      end
    end
  
    context 'when API response has missing fields' do
      let(:api_response) { double(body: { some_other_field: "Some response" }.to_json, status: 201) }
      it 'does not send a message to Telegram' do
        subject
        expect(Telegram.bots[bot_id.to_sym]).not_to have_received(:send_message)
      end
    end
    
    context 'when there is an exception in create_or_find_conversation' do
      before do
        allow(request_wrapper).to receive(:post).and_raise(StandardError, 'Some error')
      end
      include_examples 'logs and notifies', "An unexpected error occurred: Some error", "Sorry, we encountered an unexpected error processing your message. Please try again later."
    end
    
    context 'when there is a connection error' do
      before do
        allow(request_wrapper).to receive(:post).and_raise(Faraday::ConnectionFailed.new('Connection error'))
      end
      include_examples 'logs and notifies', "Connection or timeout error occurred: Connection error", "Sorry, we encountered an unexpected error processing your message. Please try again later."
    end
  
    context 'when there is a JSON parsing error' do
      before do
        allow(JSON).to receive(:parse).and_raise(JSON::ParserError)
      end
      include_examples 'logs and notifies', "JSON parsing error", "Sorry, we encountered an unexpected error processing your message. Please try again later."
    end

    context 'when API response status is not 201' do
      let(:api_response) { double(body: { error: "Bad Request" }.to_json, status: 400) }
      
      include_examples 'logs and notifies', "API Response error: API Response received with status: 400, body: {\"error\":\"Bad Request\"}", "Sorry, we encountered an unexpected error processing your message. Please try again later."
    end
  end
end
