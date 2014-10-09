module ControlHub

  module IO

    class Websocket

      attr_reader :id

      def initialize(socket_info, options = {})
        @config = socket_info
        @id = socket_info[:id]
        @socket = nil
        @debug = options[:debug]
      end

      # Send a message over the socket
      # @param [Array<Message>] messages A message or messages to send
      # @return [String, nil] If a message was sent, its JSON string; otherwise nil
      def out(messages)
        messages = Array(messages)
        if !@socket.nil?
          json = messages.to_json
          @debug.puts("Sending messages: #{json}") if @debug
          begin
            @socket.send(json)
          rescue Exception => exception # failsafe
            @debug.exception(exception)
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

      def listen(&block)
        @socket.onmessage do |raw_message|
          handle_input(raw_message, &block)
        end
      end

      private

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
      end

    end
  end
end
