require 'spec_helper'

RSpec.describe RabbitmqPublisher do
  let(:connection) { instance_double('RabbitmqConnection') }
  let(:channel)    { instance_double('Channel') }

  describe '#get_connection' do
    let(:input) { { message: 'test message', exchange_name: 'test_exchange', routing_key: 'test.key' } }

    context 'when connection is successful' do
      before do
        allow(RabbitmqConnection).to receive(:connection).and_return(connection)
      end

      it 'successfully gets a RabbitMQ connection' do
        result = RabbitmqPublisher.new.send(:get_connection, input)
        expect(result).to be_success
        expect(result.value![:connection]).to eq(connection)
      end
    end

    context 'when connection fails' do
      before do
        allow(RabbitmqConnection).to receive(:connection).and_return(nil)
      end

      it 'fails to get a RabbitMQ connection' do
        result = RabbitmqPublisher.new.send(:get_connection, input)
        expect(result).to be_failure
      end
    end
  end

  describe '#get_channel_and_publish_message' do
    let(:input) { { connection: connection, message: 'test message', exchange_name: 'test_exchange', routing_key: 'test.key' } }

    context 'when message is successfully published' do
      before do
        allow(RabbitmqChannel).to receive(:channel).and_yield(channel)
        allow(channel).to receive(:direct).and_return(double(publish: true))
      end
    
      it 'publishes a message successfully' do
        result = RabbitmqPublisher.new.send(:get_channel_and_publish_message, input)
        expect(result).to be_success
      end
    end

    context 'when a Bunny::ChannelLevelException is raised' do
      before do
        allow(RabbitmqChannel).to receive(:channel).and_yield(channel)
        allow(channel).to receive(:direct).and_raise(Bunny::ChannelLevelException.new(nil, nil, nil))
        allow(channel).to receive(:open?).and_return(true) # Allow and set return value for :open?
        allow(channel).to receive(:close)
        allow(RabbitmqChannel).to receive(:reset_channel)
      end

      it 'handles channel level exceptions' do
        result = RabbitmqPublisher.new.send(:get_channel_and_publish_message, input)
        expect(result).to be_failure
        expect(result.failure).to eq("Failed to publish due to a channel error")
      end
    end
  end

  describe '.publish' do
    let(:exchange_name)      { 'test_exchange' }
    let(:routing_key)        { 'test.key' }
    let(:message)            { 'test message' }
    let(:publisher_instance) { instance_double("RabbitmqPublisher") }

    it 'calls the transaction steps to publish a message' do
      allow(RabbitmqPublisher).to receive(:new).and_return(publisher_instance)
      allow(publisher_instance).to receive(:call).and_return(Dry::Monads::Result::Success.new("Successfully published"))

      result = RabbitmqPublisher.publish(exchange_name, routing_key, message)
      expect(result).to be_success
      expect(result.value!).to eq("Successfully published")
    end
  end
end