module ControlHub

  module Input

    # Receive OSC messages and do something with them
    class OSC

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
        configure_io(input_info)
      end

      # Begin to listen for messages.  Yields to a block with a handler for when messages are received.
      def listen(&block)
        if !@server.nil?
          configure_controls(&block)
          @active = true
          @server.run
        end
      end

      protected

      # Handle a new message
      # @param [Fixnum] index The control index
      # @param [OSC::Message] message The OSC message object
      # @param [Hash] options
      # @option options [ControlHub::Scale] :scale A scale for the value
      def handle_message_received(message, &block)
        output = get_output(message)        
        bounceback(message)
        # yield to custom behavior
        yield(output) if block_given?
        output
      end

      private

      def get_output(message)
        # parse the message
        value = message.to_a[0].to_f
        output = {}
        @controls.each do |namespace, schema|
          namespace = namespace.to_sym
          output[namespace] ||= {}
          mapping = schema.find { |mapping| mapping[:osc][:address] == message.address }
          output[namespace][:index] = schema.index(mapping)
          output[namespace][:value] = get_value(mapping[:osc], value)
        end
        output
      end

      # bounce the message back to update the ui or whatever
      def bounceback(message)
        if !@client.nil?
          begin
            @client.send(message)
          rescue Exception => e # failsafe
            @debug.exception(e)
          end
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
          ip = Socket.ip_address_list.map(&:inspect_sockaddr).select { |ip| ip.match(/\b\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}\b/) }
          puts "Server ips are: #{ip}"
        end
      end

      # Configure the client connection
      def configure_client(client_config)
        @client = ::OSC::Client.new(client_config[:host], client_config[:port])
      end

      # Configure the control mapping
      def configure_controls(&block)
        if @debug
          @server.add_method(/.*/) { |msg| @debug.puts("Received: #{msg.address}") }
        end
        addresses = @controls.map do |key, mappings|
          mappings.map { |mapping| mapping[:osc][:address].dup }
        end.flatten.compact.uniq
        addresses.each do |address|
          @server.add_method(address) do |message|
            handle_message_received(message, &block)
          end
        end
      end

    end
  end
end
