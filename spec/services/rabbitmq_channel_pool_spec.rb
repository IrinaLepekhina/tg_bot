require 'rails_helper'

RSpec.describe RabbitmqChannelPool do
  let(:connection)   { class_double('RabbitmqConnection') }
  let(:pool_size)    { 5 }
  let(:channel_pool) { RabbitmqChannelPool.new(connection, pool_size) }
  let(:channel)      { instance_double('Bunny::Channel', open?: true) }

  before do
    allow(connection).to receive(:create_channel).and_return(channel)
  end

  context 'when initializing' do
    it 'initializes with the correct number of channels' do
      expect(channel_pool.instance_variable_get(:@pool).size).to eq(pool_size)
    end
  end

  context 'when retrieving and returning a channel' do
    it 'correctly retrieves and returns a channel' do
      retrieved_channel = nil
      expect {
        retrieved_channel = channel_pool.with_channel { |ch| ch }
      }.not_to change { channel_pool.instance_variable_get(:@pool).size }

      expect(retrieved_channel).to eq(channel)
    end
  end

  context 'when handling concurrent channel retrieval and return' do
    let(:high_pool_size) { 10 }
    let(:high_load_channel_pool) { RabbitmqChannelPool.new(connection, high_pool_size) }

    it 'handles concurrent channel retrieval and return' do
      threads = 100.times.map do
        Thread.new { high_load_channel_pool.with_channel { |ch| ch } }
      end

      threads.each(&:join)
      # No assertion needed; success is no deadlocks or other concurrency issues
    end
  end
end
