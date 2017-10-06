require 'spec_helper'

describe '#publish(channel, message)' do
  before { @mock = @redises.mock }

  it 'should have no subscriber' do
    @mock.publish("events", "foo").should == 0
  end

  it 'should have one subscriber' do
    @mock.subscribe("events") do |on|
    end

    @mock.publish("events", "foo").should == 1
  end

  it 'should receive messages' do
    received = 0

    @mock.subscribe("events") do |on|
      on.message do |chan, msg|
        received += 1
      end
    end

    @mock.publish("events", "one")
    @mock.publish("events", "two")

    received.should == 2
  end

  it 'should publish to the right channel' do
    channel = nil

    @mock.subscribe('a') do |on|
      on.message do |chan, |
        channel = chan
      end
    end

    @mock.publish('a', 'foo')

    channel.should == 'a'
  end

  it 'should publish to different channels' do
    received_a = 0
    received_b = 0

    @mock.subscribe('a') do |on|
      on.message do |chan, |
        received_a += 1
      end
    end
    @mock.subscribe('b') do |on|
      on.message do |chan, _|
        received_b += 1
      end
    end

    @mock.publish('a', 0)
    @mock.publish('a', 0)
    @mock.publish('b', 0)

    received_a.should == 2
    received_b.should == 1
  end
end