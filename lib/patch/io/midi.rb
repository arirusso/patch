module Patch 

  module IO

    # MIDI IO
    module MIDI

      # Instantiate a MIDI device based on the given spec
      # @param [Hash] spec
      # @param [Hash] options
      # @option options [Log] :log
      # @return [MIDI::Input, MIDI::Output]
      def self.new(spec, options = {})
        klass = case spec[:direction].to_sym
                when :input then Input
                when :output then Output
                end
        klass.new(spec, :actions => options[:actions], :log => options[:log])
      end

      # Convert between MIDI message objects and Patch::Message objects
      module Message

        extend self

        # @param [::Patch::Patch] patch
        # @param [Array<::Patch::Message>, ::Patch::Message] messages
        # @return [Array<::MIDIMessage>]
        def to_midi_messages(patch, patch_messages)
          patch_messages = [patch_messages].flatten
          midi_messages = patch_messages.map do |patch_message|
            unless (action = patch.actions.at(patch_message.index)).nil?
              to_midi_message(action, patch_message)
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
            unless (action = patch.actions.at(midi_message.index)).nil?
              to_patch_message(action, patch.name, midi_message)
            end
          end
          patch_messages.compact
        end

        private

        # Convert a patch message to a MIDI message
        # @param [Hash] action An action to contextualize the conversion
        # @param [::Patch::Message] patch_message
        # @return [::MIDIMessage::ControlChange, nil]
        def to_midi_message(action, patch_message)
          if !action[:midi].nil?
            channel = action[:midi][:channel] || 0
            to = action[:midi][:scale]
            to ||= 0..127
            from = action[:default][:scale] unless action[:default].nil?
            from ||= to
            value = get_value(patch_message.value, from, to)
            MIDIMessage::ControlChange.new(channel, patch_message.index, value)
          end
        end

        # Convert a MIDI message to a patch message
        # @param [Hash] action An action to contextualize the conversion
        # @param [Symbol] patch_name A patch name
        # @param [::MIDIMessage::ControlChange] midi_message
        # @return [::Patch::Message, nil]
        def to_patch_message(action, patch_name, midi_message)
          if !action[:midi].nil? && (action[:midi][:channel].nil? || action[:midi][:channel] == midi_message.channel)
            from = action[:midi][:scale]
            from ||= 0..127
            to = action[:default][:scale] unless action[:default].nil?
            to ||= from
            value = get_value(midi_message.value, from, to)
            properties = {
              :index => midi_message.index, 
              :patch_name => patch_name,
              :value => value
            }
            ::Patch::Message.new(properties)
          end
        end

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

      # MIDI Input functions
      class Input

        attr_reader :device, :id, :listener

        # @param [Hash] spec A hash describing the input
        # @param [Hash] options
        # @option options [Log] :log 
        # @option options [Fixnum] :id An ID for this device
        def initialize(spec, options = {})
          @log = options[:log]
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
        # @option options [Debug] :log
        # @option options [Fixnum] :id An ID for this device
        def initialize(spec, options = {})
          @log = options[:log]
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
