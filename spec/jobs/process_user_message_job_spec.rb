require 'rails_helper'

RSpec.describe ProcessWebhookMessageJob, type: :job do
  include ActiveJob::TestHelper

  let(:args) do
    { 
      conversation_id: '123',
      content: 'Hello!',
      bot_id: 'bot',
      date: Time.current.to_s
    }
  end

  let(:publisher_instance) { instance_double(RabbitmqPublisher) }
  let(:success_result)     { Dry::Monads::Success('Success message') }
  let(:error_result) { Dry::Monads::Failure('An error occurred') }

  before do
    allow(RabbitmqPublisher).to receive(:new).and_return(publisher_instance)
  end
  
  after do
    clear_enqueued_jobs
    clear_performed_jobs
  end
  
  describe '#perform' do
  context 'when publishing succeeds' do
    it 'successfully publishes a message to RabbitMQ' do
      allow(publisher_instance).to receive(:call).and_return(success_result)

        expect { ProcessWebhookMessageJob.perform_later(args) }
          .to have_enqueued_job.with(args)
          .on_queue('default')

        perform_enqueued_jobs
        expect(publisher_instance).to have_received(:call)
      end
    end

    context 'when an error occurs while publishing to RabbitMQ' do
      let(:error_message) { "An error occurred" }
      before { allow(publisher_instance).to receive(:call).and_return(error_result) }

      it 'sends an error message to Telegram' do
        allow(publisher_instance).to receive(:call).and_return(Dry::Monads::Failure(error_message))

        job = ProcessWebhookMessageJob.new
        expect(job).to receive(:send_error_message_to_telegram).with(args[:conversation_id], args[:bot_id])

        job.perform(args)
      end
    end

    context 'when an exception is raised' do
      let(:exception) { StandardError.new("Some exception") }

      before { allow(publisher_instance).to receive(:call).and_raise(exception) }

      it 'sends an error message to Telegram when an exception is raised' do
        allow(publisher_instance).to receive(:call).and_raise(StandardError)
        expect_any_instance_of(ProcessWebhookMessageJob).to receive(:send_error_message_to_telegram)
          .with(args[:conversation_id], args[:bot_id])
  
        perform_enqueued_jobs do
          ProcessWebhookMessageJob.perform_later(args)
        end
      end
    end
  end
end
