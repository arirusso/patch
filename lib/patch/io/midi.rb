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
        klass.new(spec, :action => options[:action], :debug => options[:debug])
      end

      # Convert between MIDI message objects and Patch::Message objects
      module Message
 
        extend self

        def to_midi_messages(patch, message)
          #todo
          []
        end

        # Convert the given MIDI message to Patch::Message objects using the context of the given patch
        # @param [::Patch::Patch] patch
        # @param [MIDIMessage] midi_message
        # @return [Array<::Patch::Message>]
        def to_patch_messages(patch, midi_message)
          index = midi_message.index - 1
          patch.action.find_all_by_type(:midi).map do |mapping| 
            message = ::Patch::Message.new
            message.index = index
            message.patch_name = patch.name
            message.value = get_value(mapping[:midi], midi_message)
            message
          end
        end

        private

        # Get the message value given the MIDI message and patch context
        # @param [Hash] context
        # @param [MIDIMessage] midi_message
        # @return [Fixnum]
        def get_value(context, midi_message)
          if !context[:scale].nil?
            Scale.transform(midi_message.value).from(0..127).to(context[:scale])
          else
            midi_message.value
          end
        end

      end

      # MIDI Input functions
      class Input

        attr_reader :id, :input, :listener

        # @param [Hash] spec A hash describing the input
        # @param [Hash] options
        # @option options [Debug] :debug A destination for debug messages
        # @option options [Fixnum] :id An ID for this device
        def initialize(spec, options = {})
          @debug = options[:debug]
          @id = spec[:id]
          @input = get_input(spec)
          @listener = MIDIEye::Listener.new(@input) unless @input.nil?
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
          messages = ::Patch::IO::MIDI::Message.to_patch_messages(patch, event[:message])
          yield(messages) if block_given?
          messages
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

        # @param [Hash] spec
        # @param [Hash] options
        # @option options [Debug] :debug A destination for debug messages
        # @option options [Fixnum] :id An ID for this device
        def initialize(spec, options = {})
          @debug = options[:debug]
          @id = spec[:id]
          @output = get_output(spec)
        end

        # Convert Patch::Message objects to MIDI and send
        # @param [Array<Patch::Message>, Patch::Message] messages Message(s) to send via MIDI
        # @return [Array<MIDIMessage>]
        def puts(patch, patch_messages)
          patch_messages = [patch_messages].flatten
          messages = ::Patch::IO::MIDI::Message.to_midi_messages(patch, patch_messages)
          @output.puts(messages) unless messages.empty?
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
