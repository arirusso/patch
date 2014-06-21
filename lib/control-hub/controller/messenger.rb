module ControlHub

  module Controller

    # Handles sending and receiving messages to/from the socket
    class Messenger

      # @param [EventMachine::WebSocket] socket
      # @param [Hash] options
      # @option options [Boolean] :debug
      def initialize(socket, options = {})
        @socket = socket
        @debug = options[:debug]
      end

      # Handle an inputted message
      # @param [String] raw_message A raw inputted JSON message
      # @return [Hash]
      def in(raw_message, &block)
        hash = JSON.parse(raw_message, :symbolize_names => true)
        hash[:timestamp] = timestamp_to_time(hash[:timestamp]) if !hash[:timestamp].nil?
        yield(hash) if block_given?
        hash
      end

      # Send a message over the socket
      # @param [Hash] message A message to send
      # @return [String, nil] If a message was sent, its JSON string; otherwise nil
      def out(message)
        if !@socket.nil?
          message[:timestamp] ||= new_timestamp
          json = message.to_json
          @debug.puts("Sending message: #{json}") if @debug
          begin
            @socket.send(json)
          rescue Exception => e # failsafe
            @debug.exception(e)
          end
          json
        else
          @debug.puts("Warning: No connection") if @debug
          nil
        end
      end

      private

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
end
