module Patch

  module IO

    module OSC

      # OSC server
      class Server

        attr_reader :id

        # @param [Fixnum] id
        # @param [Fixnum] port
        # @param [Hash] options
        # @option options [Hash] :echo
        # @option options [Log] :log
        def initialize(id, port, options = {})
          @log = options[:log]
          @server = nil
          @active = false
          @id = id
          @is_failsafe = true

          configure(port, options)
        end

        # Is the server active?
        # @return [Boolean]
        def active?
          @active
        end

        # Start the server
        # @return [Boolean] Whether the server was started
        def start
          @active = true
          @connection = @server.run
          true
        end

        # Stop the server
        # @return [Boolean]
        def stop
          @active = false
          true
        end

        # Disable the message handlers
        # @return [Boolean]
        def disable(patch)
          addresses = get_addresses(patch)
          addresses.select { |address| @server.remove_method(address) }.any?
        end

        # Listen for messages
        # @param [::Patch::Patch] patch The patch to use for context
        # @param [Proc] callback A callback to fire when messages are received
        # @return [Boolean] Whether any actions were configured
        def listen(patch, &callback)
          addresses = get_addresses(patch)
          addresses.select { |address| listen_for(address, patch, &callback) }.any?
        end

        protected

        # @param [::Patch::Patch] patch The patch to use for context
        # @return [Array<String, Regexp>]
        def get_addresses(patch)
          actions = ::Patch::IO::OSC::Action.osc_actions(patch.actions)
          actions.map { |action| action[:osc][:address] }.compact.uniq
        end

        # Handle a new message
        # @param [::Patch::Patch] patch A patch for context
        # @param [OSC::Message] message The OSC message object
        # @param [Proc] callback A callback to fire when a message or messages is received
        # @return [Array<Patch::Message>]
        def handle_message_received(patch, raw_osc, &callback)
          messages = ::Patch::IO::OSC::Message.to_patch_messages(patch, raw_osc)
          echo(patch, raw_osc) if echo?
          # yield to custom behavior
          yield(messages) if block_given?
          messages
        end

        private

        # @param [Fixnum] port
        # @param [Hash] options
        # @option options [Hash] :echo
        # @return [Boolean]
        def configure(port, options = {})
          configure_server(port)
          unless options[:echo].nil?
            configure_echo(options[:echo][:host], options[:echo][:port])
          end
          true
        end

        # Listen for messages on the given address
        # @param [::Patch::Patch] patch The patch to use for context
        # @param [Proc] callback A callback to fire when messages are received
        # @return [Boolean] Whether an action was configured
        def listen_for(address, patch, &callback)
          @server.add_method(address) do |message|
            handle_message_received(patch, message, &callback)
          end
          true
        end

        # Configure the underlying server
        # @param [Fixnum] port
        # @return [::OSC::Server]
        def configure_server(port)
          @server = ::OSC::EMServer.new(port)
          if @log
            @server.add_method(/.*/) { |message| @log.puts("Received: #{message.address}") }
          end
          @server
        end

        # Will received messages be echoed back to the client?
        # @return [Boolean]
        def echo?
          !@client.nil?
        end

        # Echo a message back to the client to update the UI or whatever
        # @param [::Patch::Patch] patch
        # @param [OSC::Message] osc_message
        # @return [Boolean] Whether the echo occurred
        def echo(patch, osc_message)
          begin
            @client.puts(patch, osc_message)
            true
          rescue Exception => exception # failsafe
            @log.exception(exception) if @log
            ::Thread.main.raise(exception) unless @is_failsafe
            false
          end
        end

        # Configure the echo client
        # @param [String] host
        # @param [Fixnum] echo
        # @param [Hash] options
        # @param [Log] :log
        # @return [::Patch::IO::OSC::Client]
        def configure_echo(host, port, options = {})
          @client = Client.new(host, port, :log => options.fetch(:log, @log))
        end

      end

    end

  end

end
