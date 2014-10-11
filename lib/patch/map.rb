module Patch

  class Map

    def initialize(nodes)
      @map = nodes.spec[:map]
      @nodes = nodes
    end

    def enable
      @map.each do |from, to|
        to_node = @nodes.find_by_id(to)
        from.each do |id|
          from_node = @nodes.find_by_id(id)
          from_node.listen do |messages| 
            to_node.out(messages)
          end
        end
      end
    end

  end
end
