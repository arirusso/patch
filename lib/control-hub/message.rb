module ControlHub

  # Handles sending and receiving messages to/from the socket
  class Message

    attr_accessor :index, :namespace, :value
    attr_reader :time

    # @param [Hash] options
    # @option options [Boolean] :debug
    # @option options [Hash] :raw_message
    def initialize(options = {})
      @debug = options[:debug]
      @message = options[:raw_message] || {}
      @index = @message[:index]
      @namespace = @message[:namespace]
      @value = @message[:value]
      @time = get_time(@message[:timestamp])
    end

    def to_json
      attrs = {
        :index => @index, 
        :schema => @schema, 
        :timestamp => timestamp, #js format
        :value => @value
      }
      @message.merge(attrs).to_json
    end

    # Get the message time as a js timestamp
    # @return [Fixnum]
    def timestamp
      @time.to_i * 1000
    end

    private

    def get_time(timestamp)
      case timestamp 
        when nil then Time.now
        when Numeric then timestamp_to_time(timestamp)
      end
    end

    # Convert a raw timestamp to a Ruby time
    # @param [String, Numeric] timestamp
    # @return [Time]
    def timestamp_to_time(timestamp)
      Time.at(timestamp.to_i / 1000)
    end

    # Generate a new timestamp in js format
    # @return [Fixnum]
    def new_timestamp
      Time.now.to_i * 1000 # javascript time int format
    end

  end

end
