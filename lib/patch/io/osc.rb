module Patch

  module IO

    # Receive OSC messages and do something with them
    module OSC

      def self.new(spec, options = {})
        Server.new(spec, :action => options[:action], :debug => options[:debug])
      end

      class Server

        attr_reader :id, :ips
        attr_writer :action

        # @param [Hash] io_info
        # @param [Hash] controls
        # @param [Hash] options
        # @option options [Hash] :contol
        # @option options [Boolean] :debug
        def initialize(spec, options = {})
          @action = options[:action]
          @debug = options[:debug]
          @server = nil
          @active = false
          @ips = []
          @id = spec[:id]
          configure_io(spec, options)
        end

        # Start the server and client
        # @return [Boolean] Whether the server was started
        def start
          if !@server.nil? && !@action.nil?
            @active = true
            @server.run
            true
          else
            false
          end
        end

        # Specify a handler callback for when input messages are received.
        # @return [Boolean] Whether adding the callback was successful
        def listen(&block)
          if !@server.nil?
            configure_actions(&block)
          else
            false
          end
        end

        protected

        # Handle a new message
        # @param [Fixnum] index The control index
        # @param [OSC::Message] message The OSC message object
        # @param [Hash] options
        # @option options [::Scale] :scale A scale for the value
        # @return [Array<Patch::Message>]
        def handle_message_received(raw_input, &block)
          messages = get_hub_messages(raw_input)        
          echo(raw_input) if echo?
          # yield to custom behavior
          yield(messages) if block_given?
          messages
        end

        private

        def echo?
          !@client.nil?
        end

        def get_hub_messages(raw_message)
          # parse the message
          value = raw_message.to_a[0].to_f
          @action.map do |namespace, schema|
            mapping = schema.find { |mapping| mapping[:osc][:address] == raw_message.address }
            unless mapping.nil?
              message = Patch::Message.new
              message.index = schema.index(mapping)
              message.namespace = namespace.to_sym
              message.value = get_value(mapping[:osc], value, :destination => :hub)
              message
            end
          end
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
            p exception
            Thread.main.raise(exception)
            false
          end
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

        # Configure the client and server connections
        def configure_io(spec, options = {})
          configure_echo(spec[:client], options) if !spec[:client].nil?
          configure_server(spec[:server])
        end

        def configure_echo(client_info, options = {})
          @client = Client.new(client_info, :action => options[:action], :debug => @debug)
        end

        # Configure the server connection
        def configure_server(server_config)
          if (@server = ::OSC::EMServer.new(server_config[:port]))
            @ips = Socket.ip_address_list.map(&:inspect_sockaddr).select { |ip| ip.match(/\b\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}\b/) }
            puts "Server ips are: #{@ips}"
          end
        end

        # Configure the control mapping
        # @return [Boolean] Whether any controls were configured
        def configure_actions(&block)
          if @debug
            @server.add_method(/.*/) { |msg| @debug.puts("Received: #{msg.address}") }
          end
          if @action.nil?
            false
          else
            address_collection = @action.map do |key, mappings|
              mappings.map { |mapping| mapping[:osc][:address].dup }
            end
            addresses = address_collection.flatten.compact.uniq
            result = addresses.map do |address|
              @server.add_method(address) do |message|
                handle_message_received(message, &block)
              end
              true
            end
            result.any?
          end
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
