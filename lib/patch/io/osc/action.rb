module Patch

  module IO

    module OSC

      # Find and identify OSC Actions
      module Action

        extend self

        # Is the given action OSC?
        # @param [Hash] action
        # @return [Boolean]
        def osc?(action)
          !action[:osc].nil?
        end

        # Filter the given actions only to return OSC actions
        # @param [Array<Hash>] actions
        # @return [Array<Hash>]
        def osc_actions(actions)
          actions.select { |action| osc?(action) }
        end

        # Find an action by its OSC address
        # @param [Array<Hash>] actions
        # @param [String] address
        # @return [Hash]
        def find_by_address(actions, address)
          osc_actions(actions).find do |action|
            action[:osc][:address] == address
          end
        end

      end

    end

  end

end
