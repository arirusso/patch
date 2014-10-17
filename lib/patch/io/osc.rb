module Patch

  module IO

    # Receive OSC messages and do something with them
    module OSC

      extend self

      # Instantiate an OSC server and/or client using the given spec
      # @param [Hash] spec
      # @param [Hash] options
      # @option options [Action::Container] :actions
      # @option options [Log] :log
      # @return [::Patch::IO::OSC::Server]
      def new(spec, options = {})
        if spec[:server].nil?
          Client.new(spec[:client], :log => options[:log]) if !spec[:client].nil?
        else
          Server.new(spec, :actions => options[:actions], :log => options[:log])   
        end
      end

      # Convert between OSC message and Patch::Message objects
      module Message

        extend self

        # Convert a message object to an OSC message given the context of the given patch
        # @param [::Patch::Patch] patch
        # @param [::Patch::Message] message
        # @return [Array<::OSC::Message>]
        def to_osc_messages(patch, patch_message)
          messages = []
          action = patch.actions.at(patch_message.index)
          if !action.nil? && !action[:osc].nil?
            address = action[:osc][:address]
            to = action[:osc][:scale]
            to ||= 0..1.0
            from = action[:default][:scale] unless action[:default].nil?
            from ||= to
            value = get_value(patch_message.value, from, to)
            messages << ::OSC::Message.new(address, value)
          end
          messages
        end

        # Convert the given OSC message to Patch::Message objects using the context of the given patch
        # @param [::Patch::Patch] patch
        # @param [MIDIMessage] midi_message
        # @return [Array<::Patch::Message>]
        def to_patch_messages(patch, raw_osc)
          messages = []
          action = patch.actions.find_all_by_type(:osc).find { |action| action[:osc][:address] == raw_osc.address }
          if !action.nil?
            index = patch.actions.index(action)
            from = action[:osc][:scale]
            from ||= 0..1.0
            to = action[:default][:scale] unless action[:default].nil?
            to ||= from
            value = get_value(raw_osc.to_a[0].to_f, from, to)
            properties = {
              :index => index,
              :patch_name => patch.name, 
              :value => value
            }
            messages << ::Patch::Message.new(properties)
          end
          messages
        end

        private

        # Translate a value
        # @param [Fixnum] value
        # @param [Range] from
        # @param [Range] to
        # @return [Fixnum]
        def get_value(value, from, to)
          if from == to
            value
          else
            Scale.transform(value).from(from).to(to)
          end
        end

      end

      # OSC server
      class Server

        attr_reader :id

        # @param [Hash] spec
        # @param [Hash] options
        # @option options [Log] :log
        def initialize(spec, options = {})
          @log = options[:log]
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
        # @param [::Patch::Patch] patch The patch to use for context 
        # @param [Proc] callback A callback to fire when messages are received
        # @return [Boolean] Whether any actions were configured
        def listen(patch, &callback)
          actions = patch.actions.find_all_by_type(:osc)
          addresses = actions.map { |action| action[:osc][:address].dup }.compact.uniq
          result = addresses.map do |address|
            @server.add_method(address) do |message|
              handle_message_received(patch, message, &callback)
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
            Thread.main.raise(exception)
            false
          end
        end

        # Configure the echo client
        # @param [Hash] spec
        # @param [Hash] options
        # @option options [Action::Container] :actions
        # @return [::Patch::IO::OSC::Client]
        def configure_echo(spec, options = {})
          @client = Client.new(spec, :actions => options[:actions], :log => @log)
        end

      end

      # OSC Client
      class Client

        # @param [Hash] spec
        # @param [Hash] options
        # @option options [Log] :log
        def initialize(spec, options = {})
          @log = options[:log]
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
