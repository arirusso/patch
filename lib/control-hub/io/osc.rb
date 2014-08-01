module ControlHub

  module IO

    # Receive OSC messages and do something with them
    class OSC

      attr_reader :ips

      # @param [Hash] input_info
      # @param [Hash] controls
      # @param [Hash] options
      # @option options [Hash] :contol
      # @option options [Boolean] :debug
      def initialize(input_info, options = {})
        @controls = options[:control]
        @debug = options[:debug]
        @client = nil
        @server = nil
        @active = false
        @ips = []
        configure_io(input_info)
      end

      # Start the server and client
      # @return [Boolean] Whether the server was started
      def start
        if !@server.nil? && !@controls.nil?
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
          configure_controls(&block)
        else
          false
        end
      end

      # Convert message objects to OSC messages and send
      # @param [Array<ControlHub::Message>, ControlHub::Message] messages Message(s) to send
      # @return [Boolean]
      def out(messages)
        # todo
      end

      protected

      # Handle a new message
      # @param [Fixnum] index The control index
      # @param [OSC::Message] message The OSC message object
      # @param [Hash] options
      # @option options [ControlHub::Scale] :scale A scale for the value
      # @return [Array<Hub::Message>]
      def handle_message_received(raw_input, &block)
        messages = get_hub_messages(raw_input)        
        echo(raw_input)
        # yield to custom behavior
        yield(messages) if block_given?
        messages
      end

      private

      # Output a raw osc message
      # @param [OSC::Message] osc_message
      def osc_out(osc_message)
        @client.send(osc_message)
      end

      def get_hub_messages(raw_message)
        # parse the message
        value = raw_message.to_a[0].to_f
        messages = []
        @controls.each do |namespace, schema|
          mapping = schema.find { |mapping| mapping[:osc][:address] == raw_message.address }
          message = ControlHub::Message.new
          message.index = schema.index(mapping)
          message.namespace = namespace.to_sym
          message.value = get_value(mapping[:osc], value)
          messages << message
        end
        messages
      end

      # Bounce the message back to update the ui or whatever
      # @param [OSC::Message] osc_message
      # @return [Boolean] Whether the echo was successful
      def echo(osc_message)
        if !@client.nil?
          begin
            osc_out(osc_message)
            true
          rescue Exception => exception # failsafe
            @debug.exception(exception)
            false
          end
        else
          false
        end
      end

      def get_value(mapping, value)
        scale = mapping[:scale]
        if scale.nil?
          value
        else
          Scale.transform(value).from(scale[:from]).to(scale[:to]) 
        end
      end

      # Configure the client and server connections
      def configure_io(input_info)
        configure_server(input_info[:server]) if !input_info[:server].nil?
        configure_client(input_info[:client]) if !input_info[:client].nil?
      end

      # Configure the server connection
      def configure_server(server_config)
        if (@server = ::OSC::EMServer.new(server_config[:port]))
          @ips = Socket.ip_address_list.map(&:inspect_sockaddr).select { |ip| ip.match(/\b\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}\b/) }
          puts "Server ips are: #{@ips}"
        end
      end

      # Configure the client connection
      def configure_client(client_config)
        @client = ::OSC::Client.new(client_config[:host], client_config[:port])
      end

      # Configure the control mapping
      # @return [Boolean] Whether any controls were configured
      def configure_controls(&block)
        if @debug
          @server.add_method(/.*/) { |msg| @debug.puts("Received: #{msg.address}") }
        end
        addresses = @controls.map do |key, mappings|
          mappings.map { |mapping| mapping[:osc][:address].dup }
        end.flatten.compact.uniq
        result = addresses.each do |address|
          @server.add_method(address) do |message|
            handle_message_received(message, &block)
          end
          true
        end
        result.any?
      end

    end
  end
end
