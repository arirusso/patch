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

        # Filter the given actions only to return MIDI actions
        # @param [Array<Hash>] actions
        # @return [Array<Hash>]
        def midi_actions(actions)
          actions.select { |action| midi?(action) }
        end

        # Find an action in the given patch for the given cc index
        # @param [Array<Hash>] actions
        # @param [Fixnum] index
        # @return [Hash]
        def find_by_index(actions, index)
          midi_actions(actions).find do |action|
            action[:midi][:index] == index
          end
        end

      end

    end

  end

end
