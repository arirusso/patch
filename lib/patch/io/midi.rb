module Patch 

  module IO

    # MIDI IO
    module MIDI

      # Instantiate a MIDI device based on the given spec
      # @param [Hash] spec
      # @return [MIDI::Input, MIDI::Output]
      def self.new(spec, options = {})
        klass = case spec[:direction].to_sym
                when :input then Input
                when :output then Output
                end
        klass.new(spec, :actions => options[:actions], :debug => options[:debug])
      end

      # Convert between MIDI message objects and Patch::Message objects
      module Message

        extend self

        # @param [::Patch::Patch] patch
        # @param [Array<::Patch::Message>, ::Patch::Message] messages
        # @return [Array<::MIDIMessage>]
        def to_midi_messages(patch, messages)
          messages = [messages].flatten
          midi_messages = messages.map do |message|
            action = patch.actions.at(message.index)
            if !action.nil? && !action[:midi].nil? && (action[:channel].nil? || action[:channel] == message.channel)
              channel = action[:channel] || 0
              index = message.index
              value = get_value(action, message.value, :direction => :midi)
              MIDIMessage::ControlChange.new(channel, index, value)
            end
          end
          midi_messages.compact
        end

        # Convert the given MIDI message to Patch::Message objects using the context of the given patch
        # @param [::Patch::Patch] patch
        # @param [Array<MIDIMessage>, MIDIMessage] midi_messages
        # @return [Array<::Patch::Message>]
        def to_patch_messages(patch, midi_messages)
          midi_messages = [midi_messages].flatten
          patch_messages = midi_messages.map do |midi_message|
            index = midi_message.index
            action = patch.actions.at(index)
            if !action.nil? && !action[:midi].nil? && (action[:midi][:channel].nil? || action[:midi][:channel] == midi_message.channel)
              value = get_value(action[:midi], midi_message.value)
              properties = {
                :index => index, 
                :midi_channel => midi_message.channel,
                :patch_name => patch.name,
                :value => value
              }
              ::Patch::Message.new(properties)
            end
          end
          patch_messages.compact
        end

        private

        # Get the message value given the value and patch context
        # @param [Hash] context
        # @param [Numeric] value
        # @param [Hash] options
        # @option options [Symbol] :direction (default: :hub)
        # @return [Fixnum]
        def get_value(context, value, options = {})
          if !context[:scale].nil?
            scale = Scale.transform(value)
            if options[:direction] == :midi
              scale.from(context[:scale]).to(0..127)
            else
              scale.from(0..127).to(context[:scale])
            end
          else
            value
          end
        end

      end

      # MIDI Input functions
      class Input

        attr_reader :device, :id, :listener

        # @param [Hash] spec A hash describing the input
        # @param [Hash] options
        # @option options [Debug] :debug A destination for debug messages
        # @option options [Fixnum] :id An ID for this device
        def initialize(spec, options = {})
          @debug = options[:debug]
          @id = spec[:id]
          @device = get_input(spec)
          @listener = MIDIEye::Listener.new(@device) unless @device.nil?
        end

        # Start listening for MIDI messages
        # @return [Boolean] Whether the listener was started
        def start
          if !@listener.nil?
            @listener.run(:background => true)
            true
          else
            false
          end
        end

        # Specify a patch context and handler callback to use when messages are received
        # @param [::Patch::Patch] patch
        # @param [Proc] callback
        # @return [Boolean] Whether adding the callback was successful
        def listen(patch, &callback)
          if !@listener.nil?
            @listener.listen_for(:class => [MIDIMessage::ControlChange]) do |event|
              handle_event_received(patch, event, &callback)
            end
            true
          else
            false
          end
        end

        private

        # Handle receiving new MIDI messages from the input
        # @param [::Patch::Patch] patch
        # @param [Hash] event
        # @param [Proc] callback
        # @return [Array<::Patch::Message>]
        def handle_event_received(patch, event, &callback)
          messages = event[:message]
          patch_messages = ::Patch::IO::MIDI::Message.to_patch_messages(patch, messages)
          yield(patch_messages) if block_given?
          patch_messages
        end

        # Initialize the input device specified in the spec.  If the name of the device is "choose" the user is prompted
        # to select an available input.
        # @param [Hash] spec
        # @return [UniMIDI::Input]
        def get_input(spec)
          case spec[:name]
          when "choose" then UniMIDI::Input.gets
          when nil then nil
          else UniMIDI::Input.find_by_name(spec[:name])
          end
        end

      end

      # MIDI Output functions
      class Output

        attr_reader :id, :device

        # @param [Hash] spec
        # @param [Hash] options
        # @option options [Debug] :debug A destination for debug messages
        # @option options [Fixnum] :id An ID for this device
        def initialize(spec, options = {})
          @debug = options[:debug]
          @id = spec[:id]
          @device = get_output(spec)
        end

        # Convert Patch::Message objects to MIDI and send
        # @param [Array<Patch::Message>, Patch::Message] messages Message(s) to send via MIDI
        # @return [Array<MIDIMessage>]
        def puts(patch, patch_messages)
          patch_messages = [patch_messages].flatten
          messages = ::Patch::IO::MIDI::Message.to_midi_messages(patch, patch_messages)
          @device.puts(messages) unless messages.empty?
          messages
        end

        private

        # Initialize the output device specified in the spec.  If the name of the device is "choose" the user is prompted
        # to select an available output.
        # @param [Hash] spec
        # @return [UniMIDI::Output]
        def get_output(output_info)
          case output_info[:name]
          when "choose" then UniMIDI::Output.gets
          when nil then nil
          else UniMIDI::Output.find_by_name(output_info[:name])
          end
        end

      end

    end

  end
end
