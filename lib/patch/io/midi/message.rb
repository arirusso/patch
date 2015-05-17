module Patch

  module IO

    module MIDI

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
              to_midi_message(action, patch_message) unless action[:midi].nil?
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
            unless (action = Action.find_by_index(patch.actions, midi_message.index)).nil?
              index = patch.actions.index(action)
              to_patch_message(action, index, patch.name, midi_message)
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
            index = action[:midi][:index] || patch_message.index
            channel = action[:midi][:channel] || 0
            to = action[:midi][:scale]
            to ||= 0..127
            from = action[:default][:scale] unless action[:default].nil?
            from ||= to
            value = get_value(patch_message.value, from, to)
            MIDIMessage::ControlChange.new(channel, index, value)
          end
        end

        # Convert a MIDI message to a patch message
        # @param [Hash] action An action to contextualize the conversion
        # @param [Fixnum] index The index of the message
        # @param [Symbol] patch_name A patch name
        # @param [::MIDIMessage::ControlChange] midi_message
        # @return [::Patch::Message, nil]
        def to_patch_message(action, index, patch_name, midi_message)
          if action[:midi][:channel].nil? || action[:midi][:channel] == midi_message.channel
            from = action[:midi][:scale]
            from ||= 0..127
            to = action[:default][:scale] unless action[:default].nil?
            to ||= from
            value = get_value(midi_message.value, from, to)
            properties = {
              :index => index,
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

    end

  end

end
