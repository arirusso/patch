module Patch

  module IO

    module MIDI

      # Find and identify MIDI Actions
      module Action

        extend self

        # Is the given action MIDI?
        # @param [Hash] action
        # @return [Boolean]
        def midi?(action)
          !action[:midi].nil? && !action[:midi][:index].nil?
        end

        # Find an action in the given patch for the given index
        # @param [Array<Hash>] actions
        # @param [Fixnum] index
        # @return [Hash]
        def find_by_index(actions, index)
          midi_actions = actions.select { |action| midi?(action) }
          action = midi_actions.find { |action| action[:midi][:index] == index }
          action ||= actions.at(index)
          action
        end

      end

    end

  end

end
