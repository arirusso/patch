module Patch

  module IO

    module MIDI

      # MIDI Input functions
      class Input

        attr_reader :device, :id, :listener

        # @param [Fixnum] id
        # @param [String, UniMIDI::Input] device
        # @param [Hash] options
        # @option options [Log] :log
        def initialize(id, device, options = {})
          @log = options[:log]
          @id = id
          @device = get_input(device)
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

        # Is the input active?
        # @return [Boolean]
        def active?
          @listener.running?
        end

        # Stop the MIDI listener
        # @return [Boolean]
        def stop
          if !@listener.nil?
            @listener.stop
            true
          else
            false
          end
        end

        # Clear message handlers
        # @return [Boolean]
        def disable(patch)
          @listener.event.clear
          true
        end

        # Specify a mpatch context and handler callback to use when messages are received
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

        # Initialize the input device using the given string or input.  If the device is the string "choose",
        # the user is prompted to select an available MIDI input.
        # @param [String, UniMIDI::Input, nil] device
        # @return [UniMIDI::Input, nil]
        def get_input(device)
          if device.kind_of?(String)
            if device == "choose"
              UniMIDI::Input.gets
            else
              UniMIDI::Input.find_by_name(device)
            end
          elsif device.respond_to?(:gets)
            device.open if device.kind_of?(UniMIDI::Input)
            device
          end
        end

      end

    end

  end

end
