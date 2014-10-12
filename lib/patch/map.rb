module Patch

  class Map

    include Enumerable

    def all_from_spec(spec)
      maps = []
      spec.each do |name, schema|
        maps << new(schema[:map])
      end
      maps
    end

    def initialize(spec)
      @map = spec
    end

    def each(&block)
      @map.each(&block)
    end

  end
end
