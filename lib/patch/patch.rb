module Patch

  # A single patch consisting of a node mapping and actions
  class Patch

    attr_reader :action, :map, :name

    # Instantiate patch objects from the given spec file, filename or hash
    # @param [File, Hash, String] spec
    # @return [Array<Patch>]
    def self.all_from_spec(spec)
      spec = Spec.new(spec)
      patches = []
      spec.each do |name, patch|
        patches << from_spec(name, patch)
      end
      patches
    end

    # Instantiate a patch object for the given spec hash
    # @param [Symbol, String] name
    # @param [Hash] spec
    # @return [Patch]
    def self.from_spec(name, spec)
      action = Action.new(spec[:action])
      map = Node::Map.new(spec[:node_map])
      new(name, action, map)
    end

    # @param [Symbol, String] name
    # @param [Action] action
    # @param [Node::Map] map
    def initialize(name, action, map)
      @name = name
      @action = action
      @map = map
    end

    # Enable the given nodes to implement this patch
    # @param [Node::Container] nodes
    # @return 
    def enable(nodes)
      result = @map.map do |from, to|
        to_node = nodes.find_by_id(to)
        from.map do |id|
          from_node = nodes.find_by_id(id)
          from_node.listen(self) do |messages|
            to_node.puts(messages)
          end
          true
        end
      end
      result.flatten.any?
    end

  end
end
