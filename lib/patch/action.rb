module Patch

  class Action

    include Enumerable
    extend Forwardable

    attr_reader :spec
    def_delegators :@spec, :empty?, :index
    
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
