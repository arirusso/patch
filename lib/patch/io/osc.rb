module Patch

  module IO

    # Receive OSC messages and do something with them
    module OSC

      extend self

      def new(spec, options = {})
        Server.new(spec, :action => options[:action], :debug => options[:debug])
      end

      module Message

        extend self

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

        def patch_message(name, osc_spec, index, value)
          message = ::Patch::Message.new
          message.index = index
          message.patch_name = name.to_sym
          message.value = get_value(osc_spec, value, :destination => :hub)
          message
        end

        def get_value(mapping, value, options = {})
          scale = mapping[:scale]
          if scale.nil?
            value
          else
            get_scaled_value(scale, value, options)
          end
        end

        def get_scaled_value(scale, value, options = {})
          destination = options[:destination] || :hub
          direction = [:osc, :hub]
          direction.reverse! if destination != :hub
          Scale.transform(value).from(scale[direction.first]).to(scale[direction.last]) 
        end

      end

      class Server

        attr_reader :id
        attr_writer :action

        # @param [Hash] io_info
        # @param [Hash] controls
        # @param [Hash] options
        # @option options [Boolean] :debug
        def initialize(spec, options = {})
          @debug = options[:debug]
          @server = nil
          @active = false
          @id = spec[:id]
          configure_server(spec[:server])
          configure_echo(spec[:client], options) if !spec[:client].nil?
        end

        # Start the server and client
        # @return [Boolean] Whether the server was started
        def start
          @active = true
          @server.run
          true
        end

        # Listen for action
        # @return [Boolean] Whether any controls were configured
        def listen(patch, &block)
          address_collection = patch.action.map do |mappings|
            mappings.map { |mapping| mapping[:osc][:address].dup }
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
        # @param [Fixnum] index The control index
        # @param [OSC::Message] message The OSC message object
        # @param [Hash] options
        # @option options [::Scale] :scale A scale for the value
        # @return [Array<Patch::Message>]
        def handle_message_received(patch, raw_osc, &block)
          messages = ::Patch::IO::OSC::Message.to_patch_messages(patch, raw_osc)        
          echo(raw_osc) if echo?
          # yield to custom behavior
          yield(messages) if block_given?
          messages
        end

        private

        def configure_server(server_spec)
          @server = ::OSC::EMServer.new(server_spec[:port])
          if @debug
            @server.add_method(/.*/) { |msg| @debug.puts("Received: #{msg.address}") }
          end
        end

        def echo?
          !@client.nil?
        end

        # Bounce the message back to update the ui or whatever
        # @param [OSC::Message] osc_message
        # @return [Boolean] Whether the echo was successful
        def echo(osc_message)
          begin
            @client.out(osc_message)
            true
          rescue Exception => exception # failsafe
            @debug.exception(exception) if @debug
            Thread.main.raise(exception)
            false
          end
        end

        def configure_echo(client_info, options = {})
          @client = Client.new(client_info, :action => options[:action], :debug => @debug)
        end

      end

      class Client

        # @param [Hash] client_info
        # @param [Hash] controls
        # @param [Hash] options
        # @option options [Hash] :contol
        # @option options [Boolean] :debug
        def initialize(client_info, options = {})
          @action = options[:action]
          @debug = options[:debug]
          @client = ::OSC::Client.new(client_info[:host], client_info[:port])
        end

        # Convert message objects to OSC messages and send
        # @param [Array<Patch::Message>, Patch::Message] messages Message(s) to send
        # @return [Boolean]
        def out(messages)
          messages = [messages].flatten
          osc_messages = messages.map do |message| 
            message = get_osc_messages(message) unless message.kind_of?(::OSC::Message)
            message
          end
          osc_messages.each { |osc_message| osc_out(osc_message) } 
        end

        private

        # Convert a message object to an OSC message for output
        def get_osc_messages(message)
          @action.map do |namespace, schema|
            mapping = schema.at(message.index)
            address = mapping[:osc][:address]
            ::OSC::Message.new(address, message.value)
          end
        end

        # Output a raw osc message
        # @param [OSC::Message] osc_message
        def osc_out(osc_message)
          @client.send(osc_message)
        end

      end
    end
  end
end
