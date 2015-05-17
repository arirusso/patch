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
          unless (action = get_osc_action(patch.actions, patch_message)).nil?
            messages << get_osc_message(action, patch_message)
          end
          messages
        end

        # Convert the given OSC message to Patch::Message objects using the context of the given patch
        # @param [::Patch::Patch] patch
        # @param [Object] raw_osc
        # @return [Array<::Patch::Message>]
        def to_patch_messages(patch, raw_osc)
          messages = []
          unless (action = Action.find_by_address(patch.actions, raw_osc.address)).nil?
            messages << get_patch_message(patch, action, raw_osc)
          end
          messages
        end

        private

        # @param [::Patch::Patch] patch
        # @param [Hash] action
        # @param [Object] raw_osc
        # @return [::Patch::Message]
        def get_patch_message(patch, action, raw_osc)
          index = patch.actions.index(action)
          values = get_patch_values_from_action(raw_osc, action)
          properties = {
            :index => index,
            :patch_name => patch.name,
            :value => values[0]
          }
          ::Patch::Message.new(properties)
        end

        # @param [Hash] action
        # @param [::Patch::Message] patch_message
        # @return [::OSC::Message]
        def get_osc_message(action, patch_message)
          address = action[:osc][:address]
          value = get_osc_value_from_action(patch_message.value, action)
          ::OSC::Message.new(address, value)
        end

        # @param [Object] raw_osc
        # @param [Hash] action
        # @return [Array<Object>]
        def get_patch_values_from_action(raw_osc, action)
          from = action[:osc][:scale]
          to = action[:default][:scale] unless action[:default].nil?
          to ||= from
          raw_osc.to_a.map { |value| get_value(value.to_f, from, to) }
        end

        # @param [Object] value
        # @param [Hash] action
        # @return [Object]
        def get_osc_value_from_action(value, action)
          to = action[:osc][:scale]
          from = action[:default][:scale] unless action[:default].nil?
          from ||= to
          get_value(value, from, to)
        end

        # @param [Array<Hash>] actions
        # @param [::Patch::Message] patch_message
        # @return [Hash]
        def get_osc_action(actions, patch_message)
          action = actions.at(patch_message.index)
          action unless action.nil? || action[:osc].nil?
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
