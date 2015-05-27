module Patch

  module IO

    module Websocket

      class Socket

        def self.start(config)
          socket = new
          socket.start(config)
          socket
        end

        def initialize
          @onmessage = []
        end

        def puts(data)
          @socket.send(data)
        end

        # @return [Boolean]
        def disable
          @socket.onmessage = nil
          @onmessage.clear
          true
        end

        # @param [Proc] callback callback to fire when events are received
        # @return [Boolean]
        def on_message(&callback)
          if @socket.nil?
            @onmessage << callback
          else
            @socket.onmessage { |data| yield(data) }
          end
          true
        end

        # Start the websocket
        # @param [Hash] config
        # @return [Boolean]
        def start(config, &block)
          EM::WebSocket.run(config) do |websocket|
            ::Thread.current.abort_on_exception = true
            begin
              enable(websocket)
            rescue Exception => exception
              ::Thread.main.raise(exception)
            end
          end
          true
        end

        # Is the socket active?
        # @return [Boolean]
        def active?
          !@socket.nil?
        end

        private

        # If callbacks were added before the socket was active, assign them to the socket event handler
        def configure_message_callbacks
          @onmessage.each do |callback|
            on_message(&callback)
          end
          @onmessage.clear
        end

        # Enable this node after initializing an EM::Websocket
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

          configure_message_callbacks unless @onmessage.empty?

          true
        end

      end

    end

  end

end
