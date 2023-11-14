# tg_bot/spec/services/rabbitmq_connection_spec.rb

require 'rails_helper'

RSpec.describe RabbitmqConnection do
  describe '.connection' do

    context 'when simulating network failures' do
      let(:bunny_instance) { Bunny.new }

      before(:each) do
        # Reset connection before each test
        RabbitmqConnection.instance_variable_set(:@connection, nil)
      end
      
      before do
        allow(Bunny).to receive(:new).and_return(bunny_instance)
        allow(bunny_instance).to receive(:start).and_raise(RuntimeError.new("Network failure"))
      end
      
      it 'logs the exception and returns nil' do
        expect(RabbitmqConnection).to receive(:log_exception).with(instance_of(RuntimeError))
        expect(described_class.connection).to be_nil
      end
    end
    
    context 'when called multiple times' do
      it 'returns the same connection if it is open' do
        first_connection = described_class.connection
        expect(described_class.connection).to be(first_connection)
      end
    end

    context 'with multiple threads' do
      it 'does not create multiple connections' do
        threads = []
        connections = []

        10.times do
          threads << Thread.new do
            connections << described_class.connection
          end
        end

        threads.each(&:join)

        expect(connections.uniq.count).to eq(1)
      end
    end

    context 'when rapidly starting and stopping connections' do
      it 'handles the rapid changes without errors' do
        threads = []
        
        10.times do
          threads << Thread.new do
            connection = described_class.connection
            described_class.close_connection(connection)
          end
        end

        expect { threads.each(&:join) }.not_to raise_error
      end
    end

    context 'under high load' do
      it 'maintains stable behavior' do
        threads = []
        100.times do
          threads << Thread.new do
            described_class.connection
          end
        end

        expect { threads.each(&:join) }.not_to raise_error
      end
    end
  end
end 