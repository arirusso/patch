module Patch

  module IO

    # Websocket IO
    class Websocket

      ::Patch::IO::Module.add(self)

      class << self
        # Key that will be used by Patch to identify the module
        def key
          :websocket
        end
      end

      attr_reader :id

      # Construct a websocket from a node config
      # @param [Hash] config
      # @param [Hash] options
      # @param [Hash]
      # @option properties [Log] :log
      def self.new_from_config(config, options = {})
        new(config[:id], config[:host], config[:port], options)
      end

      # @param [Fixnum] id
      # @param [String] host
      # @param [Fixnum] port
      # @param [Hash]
      # @option properties [Log] :log
      def initialize(id, host, port, options = {})
        @config = {
          :host => host,
          :port => port
        }
        @id = id
        @log = options[:log]
        @socket = nil
      end

      # Send a message over the socket
      # @param [Array<::Patch::Message>] messages A message or messages to send
      # @return [String, nil] If a message was sent, its JSON string; otherwise nil
      def puts(messages)
        if running?
          unless (messages = [messages].flatten.compact).empty?
            json = messages.to_json
            @log.puts("Sending messages: #{json}") if @log
            begin
              @socket.send(json)
            rescue Exception => exception # failsafe
              @log.exception(exception) if @log
              Thread.main.raise(exception)
            end
            json
          end
        else
          @log.puts("Warning: No connection") if @log
          nil
        end
      end

      # Start the websocket
      # @return [Boolean]
      def start
        Thread.abort_on_exception = true
        EM::WebSocket.run(@config) do |websocket|
          begin
            enable(websocket)
          rescue Exception => exception
            Thread.main.raise(exception)
          end
        end
        true
      end

      # Is the server active?
      # @return [Boolean]
      def running?
        !@socket.nil?
      end

      private

      # Handle a received message
      # @param [String] json_message A raw inputted JSON message
      # @param [Proc] callback A callback to fire with the received message
      # @return [Message]
      def handle_input(json_message, &callback)
        message_hash = JSON.parse(json_message, :symbolize_names => true)
        message = Message.new(message_hash)
        @log.puts("Recieved message: #{message_hash.to_json}") if @log
        yield(message) if block_given?
        message
      end

      # Enable this server after initializing an EM::Websocket
      # @param [EM::Websocket] websocket
      # @return [Boolean]
      def enable(websocket)
        @socket = websocket
        configure
        true
      end

      # Configure the server actions
      # @return [Boolean]
      def configure
        @socket.onopen do |handshake|
          puts "Connection open"
        end

        @socket.onclose do
          puts "Connection closed"
        end

        @socket.onmessage do |data|
          handle_input(data, &block)
        end
        true
      end

    end
  end
end
