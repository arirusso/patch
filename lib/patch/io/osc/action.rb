module Patch

  module IO

    module OSC

      # Find and identify OSC Actions
      module Action

        extend self

        # Find an action by its OSC address
        # @param [Array<Hash>] actions
        # @param [String] address
        # @return [Hash]
        def find_by_address(actions, address)
          actions.find_all_by_type(:osc).find { |action| action[:osc][:address] == address }
        end

      end

    end

  end

end
