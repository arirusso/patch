module Patch

  module IO

    module MIDI

      # MIDI Output functions
      class Output

        attr_reader :id, :device

        # @param [Fixnum] id
        # @param [String, UniMIDI::Output] device
        # @param [Hash] options
        # @option options [Debug] :log
        def initialize(id, device, options = {})
          @log = options[:log]
          @id = id
          @device = get_output(device)
        end

        # Convert Patch::Message objects to MIDI and send
        # @param [Patch::Patch] patch Context
        # @param [Array<Patch::Message>, Patch::Message] messages Message(s) to send via MIDI
        # @return [Array<MIDIMessage>]
        def puts(patch, patch_messages)
          patch_messages = [patch_messages].flatten
          messages = ::Patch::IO::MIDI::Message.to_midi_messages(patch, patch_messages)
          unless messages.empty?
            bytes = messages.map(&:to_a).flatten
            @device.puts(*bytes)
          end
          messages
        end

        private

        # Initialize the output device given a name or device object.  If the name of the device is the string "choose",
        # the user is prompted to select an availble MIDI output.
        # @param [String, UniMIDI::Output, nil] device
        # @return [UniMIDI::Output]
        def get_output(device)
          if device.kind_of?(String)
            if device == "choose"
              UniMIDI::Output.gets
            else
              UniMIDI::Output.find_by_name(device)
            end
          elsif device.respond_to?(:puts)
            device.open if device.kind_of?(UniMIDI::Output)
            device
          end
        end

      end

    end

  end

end
