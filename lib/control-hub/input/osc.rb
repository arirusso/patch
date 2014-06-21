module ControlHub

  module Input

    # Receive OSC messages and do something with them
    class OSC

      # @param [ControlHub::Config] config
      # @param [Hash] options
      # @option options [Boolean] :debug
      def initialize(config, options = {})
        @controls = config.osc_controls
        @client = nil
        @server = nil
        @debug = options[:debug]
        @active = false
        configure_io(config.io[:osc])
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
        # parse the message
        value = message.to_a[0].to_f
        # format the output
        hash = {}
        @controls.each do |key, schema|
          key = key.to_sym
          hash[key] ||= {}
          mapping = schema.find { |mapping| mapping[:osc][:address] == message.address }
          hash[key][:index] = schema.index(mapping)
          hash[key][:value] = process_value(value, mapping)
        end
        # bounce the message back to update the ui or whatever
        if !@client.nil?
          begin
            @client.send(message)
          rescue Exception => e # failsafe
            @debug.exception(e)
          end
        end
        # yield to custom behavior
        yield(hash) if block_given?
        hash
      end

      private

      def process_value(value, mapping)
        scale = mapping[:osc][:scale]
        if scale.nil?
          value
        else
          Scale.transform(value).from(scale[:from]).to(scale[:to]) 
        end
      end

      # Configure the client and server connections
      def configure_io(config, options = {})
        configure_server(config[:server]) if !config[:server].nil?
        configure_client(config[:client]) if !config[:client].nil?
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
