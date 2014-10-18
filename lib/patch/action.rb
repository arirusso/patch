module Patch

  # Describes an action that's taken when messages are received
  module Action

    # Container for actions
    class Container

      include Enumerable
      extend Forwardable

      def_delegators :@actions, :at, :empty?, :index, :sample

      # @param [Array<Hash>, Hash] actions
      def initialize(actions)
        @actions = [actions].flatten.compact
      end

      def each(&block)
        @actions.each(&block)
      end

      # Actions that have specification for the given type
      # @param [Symbol, String] type The type of control eg :osc, :midi
      # @return [Hash]
      def find_all_by_type(type)
        @actions.select { |action| action.keys.map(&:to_s).include?(type.to_s) }
      end

    end

  end
end
