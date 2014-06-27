module ControlHub

  module Output

    class Websocket

      def initialize(output_info, options = {})
        @config = output_info
        @socket = nil
        @debug = options[:debug]
      end

      # Handle an inputted message
      # @param [String] raw_message A raw inputted JSON message
      # @return [Message]
      def handle_input(raw_message, &block)
        message_hash = JSON.parse(raw_message, :symbolize_names => true)
        message = Message.new(:raw_message => message_hash)
        @debug.puts("Recieved message: #{message_hash.to_json}") if @debug
        yield(message) if block_given?
        message
      end

      # Send a message over the socket
      # @param [Message] message A message to send
      # @return [String, nil] If a message was sent, its JSON string; otherwise nil
      def out(message)
        if !@socket.nil?
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

      def start
        Thread.abort_on_exception = true
        EM::WebSocket.run(@config) { |ws| enable(ws) }
      end

      private

      # Enable this server after initializing an EM::Websocket
      def enable(ws)
        @socket = ws
        configure
      end

      def configure
        @socket.onopen do |handshake|
          puts "Connection open"
        end

        @socket.onclose do 
          puts "Connection closed"
        end

        @socket.onmessage do |raw_message|
          handle_input(raw_message)
        end
      end

    end
  end
end
