module Patch

  module IO

    module OSC

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
          unless action.nil? || action[:osc].nil?
            address = action[:osc][:address]
            to = action[:osc][:scale]
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
          unless (action = Action.find_by_address(patch.actions, raw_osc.address)).nil?
            index = patch.actions.index(action)
            from = action[:osc][:scale]
            to = action[:default][:scale] unless action[:default].nil?
            to ||= from
            values = raw_osc.to_a.map { |value| get_value(value.to_f, from, to) }
            properties = {
              :index => index,
              :patch_name => patch.name,
              :value => values[0]
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

    end

  end

end
