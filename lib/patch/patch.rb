module Patch

  # A single patch consisting of a node mapping and actions
  class Patch

    attr_reader :actions, :maps, :name

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
      action_spec = spec[:actions] || spec[:action]
      actions = Action::Container.new(action_spec)
      maps = Node::Map.all_from_spec(spec[:node_map])
      new(name, actions, maps)
    end

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
