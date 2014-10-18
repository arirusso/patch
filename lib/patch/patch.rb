module Patch

  # A single patch consisting of a node mapping and actions
  class Patch

    attr_reader :actions, :maps, :name

    # @param [Symbol, String] name
    # @param [Array<Node::Map>, Node::Map] maps A node map or maps
    # @param [Array<Hash>, Action::Container, Hash] actions An action or actions
    def initialize(name, maps, actions)
      @name = name
      populate_maps(maps)
      populate_actions(actions)
    end

    # Enable the given nodes to implement this patch
    # @param [Node::Container] nodes
    # @return [Boolean]
    def enable
      result = @maps.map { |map| map.enable(self) }
      result.any?
    end

    private

    # Populate the patch actions from various arg formats
    # @param [Array<Hash>, Action::Container, Hash] actions
    # @return [Action::Container]
    def populate_actions(actions)
      actions = [actions] if actions.kind_of?(Hash)
      actions = Action::Container.new(actions) if actions.kind_of?(Array)
      @actions = actions
    end

    # Populate the node maps from various arg formats
    # @param [Array<Hash, Node::Map>, Hash, Node::Map] maps
    # @return [Array<Node::Map>]
    def populate_maps(maps)
      maps = [maps] unless maps.kind_of?(Array)
      maps = maps.map do |map| 
        if map.kind_of?(Hash)
          Node::Map.new(map.keys.first, map.values.first)
        else
          map
        end
      end
      @maps = maps.flatten.compact
    end

  end
end
