module Patch

  # A map of connections between nodes for a given patch
  class Map

    include Enumerable

    # Instantiate Map objects given a map spec hash
    # @param [Hash] spec
    # @return [Array<Map>]
    def all_from_spec(spec)
      maps = []
      spec.each do |name, schema|
        maps << new(schema[:map])
      end
      maps
    end

    # @param [Hash] spec
    def initialize(spec)
      @map = spec
    end

    def each(&block)
      @map.each(&block)
    end

  end
end
