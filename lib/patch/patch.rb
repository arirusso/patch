module Patch

  # A single patch consisting of a node mapping and actions
  class Patch

    attr_reader :actions, :maps, :name

    # @param [Symbol, String] name
    # @param [Action::Container] actions
    # @param [Array<Node::Map>, Node::Map] maps
    def initialize(name, actions, maps)
      @name = name
      @actions = actions
      @maps = [maps].flatten
    end

    # Enable the given nodes to implement this patch
    # @param [Node::Container] nodes
    # @return [Boolean]
    def enable(nodes)
      result = @maps.map { |map| map.enable(self, nodes) }
      result.any?
    end

  end
end
