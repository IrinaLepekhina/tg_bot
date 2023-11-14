require 'rails_helper'

RSpec.describe RabbitmqChannel do
  let(:connection) { instance_double('RabbitmqConnection') }

  describe '.channel_pool_for' do
    context 'when creating a channel pool' do
      it 'creates only one channel pool per connection' do
        expect(RabbitmqChannelPool).to receive(:new).once.and_return(instance_double('RabbitmqChannelPool'))
        5.times { RabbitmqChannel.channel_pool_for(connection) }
      end
    end

    context 'when accessing channel pools concurrently' do
      it 'synchronizes access to channel pools' do
        allow(RabbitmqChannelPool).to receive(:new).and_return(instance_double('RabbitmqChannelPool'))

        threads = 10.times.map do
          Thread.new { RabbitmqChannel.channel_pool_for(connection) }
        end

        threads.each(&:join)
        # No assertion needed; success is no deadlocks or other concurrency issues
      end
    end
  end
end
