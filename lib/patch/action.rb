module Patch

  # Describes an action that's taken when messages are received
  module Action

    # Container for actions
    class Container

      include Enumerable
      extend Forwardable

      attr_reader :spec
      def_delegators :@spec, :at, :empty?, :index

      # @param [Array<Hash>] spec
      def initialize(spec)
        @spec = spec
      end

      def each(&block)
        @spec.each(&block)
      end

      # Actions that have specification for the given type
      # @param [Symbol, String] type The type of control eg :osc, :midi
      # @return [Hash]
      def find_all_by_type(type)
        @spec.select { |action| action.keys.map(&:to_s).include?(type.to_s) }
      end

    end

  end
end
