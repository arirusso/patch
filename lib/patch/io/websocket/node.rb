module Patch

  module IO

    module Websocket

      class Node

        attr_reader :id

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
                @socket.puts(json)
              rescue Exception => exception # failsafe
                @log.exception(exception) if @log
                ::Thread.main.raise(exception)
              end
              json
            end
          else
            @log.puts("Warning: No connection") if @log
            nil
          end
        end

        # Disable the message listener
        # @return [Boolean]
        def disable(patch)
          @socket.disable
        end

        # Listen for messages with the given patch context
        # @param [Patch] patch
        # @param [Proc] callback callback to fire when events are received
        # @return [Boolean]
        def listen(patch, &callback)
          ensure_socket.on_message do |data|
            handle_input(patch, data, &callback)
          end
          true
        end

        # Start the websocket
        # @return [Boolean]
        def socket
          ensure_socket
        end
        alias_method :start, :socket

        # Is the server active?
        # @return [Boolean]
        def active?
          !@socket.nil? && @socket.active?
        end
        alias_method :running?, :active?

        private

        def ensure_socket
          @socket ||= ::Patch::IO::Websocket::Socket.start(@config)
        end

        # Handle a received message
        # @param [String] json_message A raw inputted JSON message
        # @param [Proc] callback A callback to fire with the received message
        # @return [Message]
        def handle_input(patch, json_message, &callback)
          message_hash = JSON.parse(json_message, :symbolize_names => true)
          message = Message.new(message_hash)
          @log.puts("Recieved message: #{message_hash.to_json}") if @log
          yield(message) if block_given?
          message
        end

      end

    end

  end

end
