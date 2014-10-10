module ControlHub

  class Map

    def initialize(map)
      @map = map
    end

    def enable(nodes)
      @map.each do |from, to|
        to_node = find_node_by_id(nodes, to)
        from.each do |id|
          from_node = find_node_by_id(nodes, id)
          from_node.listen do |messages| 
            to_node.out(messages)
          end
        end
      end
    end

    private

    def find_node_by_id(nodes, id)
      nodes.find { |node| node.id == id }
    end

  end
end
