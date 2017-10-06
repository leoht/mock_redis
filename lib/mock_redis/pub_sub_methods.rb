class MockRedis
  module PubSubMethods
    class Channel
      attr_accessor :name, :messages, :subscribers, :message_block

      def initialize(name)
        @name = name
        @messages = []
        @subscribers = []
      end

      def subscribe
        yield(@name, self)
      end

      def message(&block)
        @message_block = block
      end
    end

    def publish(channel, message)
      @channels ||= {}
      @channels[channel] ||= Channel.new(channel)
      chan = @channels[channel]
      chan.messages << message
      if chan.message_block != nil
        chan.message_block.call(channel, message)
      end

      chan.subscribers.count
    end

    def subscribe(*subscribed_channels, &block)
      @channels ||= {}
      subscribed_channels.each do |chan|
        @channels[chan] ||= Channel.new(chan)
        @channels[chan].subscribers << block

        yield(@channels[chan])
      end
    end
  end
end