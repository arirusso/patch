module Patch

  module IO

    # Receive OSC messages and do something with them
    module OSC

      extend self

      # Instantiate an OSC server using the given spec
      # @param [Hash] spec
      # @param [Hash] options
      # @option options [Action] :action
      # @option options [Debug] :debug
      # @return [::Patch::IO::OSC::Server]
      def new(spec, options = {})
        Server.new(spec, :action => options[:action], :debug => options[:debug])
      end

      # Convert between OSC message and Patch::Message objects
      module Message

        extend self

        # Convert a message object to an OSC message given the context of the given patch
        # @param [::Patch::Patch] patch
        # @param [::Patch::Message] message
        # @return [Array<::OSC::Message>]
        def to_osc_messages(patch, message)
          action = patch.action.at(message.index)
          address = action[:osc][:address]
          ::OSC::Message.new(address, message.value)
        end

        # Convert the given OSC message to Patch::Message objects using the context of the given patch
        # @param [::Patch::Patch] patch
        # @param [MIDIMessage] midi_message
        # @return [Array<::Patch::Message>]
        def to_patch_messages(patch, raw_osc)
          # parse the message
          value = raw_osc.to_a[0].to_f
          osc_actions = patch.action.find_all_by_type(:osc)
          messages = osc_actions.map do |mapping|
            mapping = patch.action.find { |mapping| mapping[:osc][:address] == raw_osc.address }
            index = patch.action.index(mapping)
            patch_message(patch.name, mapping[:osc], index, value) unless mapping.nil?
          end
          messages.compact
        end

        private

        # Instantiate a new Patch::Message using the given patch context and OSC message
        # @param [Symbol, String] patch_name
        # @param [Hash] context
        # @param [Fixnum] index
        # @param [Fixnum] value
        # @return [::Patch::Message]
        def patch_message(patch_name, context, index, value)
          message = ::Patch::Message.new
          message.index = index
          message.patch_name = patch_name.to_sym
          message.value = get_value(context, value, :destination => :hub)
          message
        end

        # Translate an OSC value for use by Patch::Message
        # @param [Hash] context
        # @param [Fixnum] value
        # @param [Hash] options
        # @option options [Symbol] :destination (default: :hub)
        # @return [Fixnum]
        def get_value(context, value, options = {})
          scale = context[:scale]
          if scale.nil?
            value
          else
            get_scaled_value(scale, value, options)
          end
        end

        # Scale a value
        # @param [Scale] scale
        # @param [Fixnum] value
        # @param [Hash] options
        # @option options [Symbol] :destination (default: :hub)
        # @return [Fixnum]
        def get_scaled_value(scale, value, options = {})
          destination = options[:destination] || :hub
          direction = [:osc, :hub]
          direction.reverse! if destination != :hub
          Scale.transform(value).from(scale[direction.first]).to(scale[direction.last]) 
        end

      end

      # OSC server
      class Server

        attr_reader :id
        attr_writer :action

        # @param [Hash] spec
        # @param [Hash] options
        # @option options [Debug] :debug
        def initialize(spec, options = {})
          @debug = options[:debug]
          @server = nil
          @active = false
          @id = spec[:id]
          configure_server(spec[:server])
          configure_echo(spec[:client], options) if !spec[:client].nil?
        end

        # Start the server
        # @return [Boolean] Whether the server was started
        def start
          @active = true
          @server.run
          true
        end

        # Listen for messages
        # @return [Boolean] Whether any actions were configured
        def listen(patch, &block)
          actions = patch.action.find_all_by_type(:osc)
          address_collection = actions.map do |mapping|
            mapping[:osc][:address].dup
          end
          addresses = address_collection.flatten.compact.uniq
          result = addresses.map do |address|
            @server.add_method(address) do |message|
              handle_message_received(patch, message, &block)
            end
            true
          end
          result.any?
        end

        protected

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

        # Configure the underlying server
        # @param [Hash] spec
        # @return [::OSC::Server]
        def configure_server(spec)
          @server = ::OSC::EMServer.new(spec[:port])
          if @debug
            @server.add_method(/.*/) { |msg| @debug.puts("Received: #{msg.address}") }
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
            @debug.exception(exception) if @debug
            Thread.main.raise(exception)
            false
          end
        end

        # Configure the echo client
        # @param [Hash] spec
        # @param [Hash] options
        # @option options [Action] :action
        # @option options [Debug] :debug
        # @return [::Patch::IO::OSC::Client]
        def configure_echo(spec, options = {})
          @client = Client.new(spec, :action => options[:action], :debug => @debug)
        end

      end

      # OSC Client
      class Client

        # @param [Hash] spec
        # @param [Hash] options
        # @option options [Debug] :debug
        def initialize(spec, options = {})
          @debug = options[:debug]
          @client = ::OSC::Client.new(spec[:host], spec[:port])
        end

        # Convert message objects to OSC and send
        # @param [::Patch::Patch] patch
        # @param [Array<Patch::Message, ::OSC::Message>, ::OSC::Message, Patch::Message] messages Message(s) to send
        # @return [Array<::OSC::Message>]]
        def puts(patch, messages)
          messages = [messages].flatten
          osc_messages = messages.map do |message| 
            message = ::Patch::IO::OSC::Message.to_osc_messages(patch, message) unless message.kind_of?(::OSC::Message)
            message
          end
          osc_messages.each { |osc_message| @client.send(osc_message) } 
          osc_messages
        end

      end
    end
  end
end
