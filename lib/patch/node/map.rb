module Patch

  module Node

    # A map of connections between nodes for a given patch
    class Map

      attr_reader :from, :to

      # @param [Array<Object>, NodeContainer, Object] from
      # @param [Array<Object>, NodeContainer, Object] to
      def initialize(from, to)
        @from = to_node_container(from)
        @to = to_node_container(to)
      end

      # Disable the map for the given patch context
      # @return [Boolean]
      def disable(patch)
        result = @to.map do |to_node|
          disabled = @from.map do |from_node|
            from_node.disable(patch)
            true
          end
          disabled.any?
        end
        result.any?
      end

      # Enable this map for the given nodes
      # @param [::Patch::Patch] patch The patch context to enable the map in
      # @return [Boolean] Whether nodes were enabled
      def enable(patch)
        result = @to.map do |to_node|
          enabled = @from.map do |from_node|
            from_node.listen(patch) do |messages|
              to_node.puts(messages)
            end
            true
          end
          enabled.any?
        end
        result.flatten.any?
      end

      # The nodes for this map, collected
      # @return [NodeContainer]
      def nodes
        (@from | @to)
      end

      private

      # Convert the given arg to a node container
      # @param [Object] object
      # @return [NodeContainer]
      def to_node_container(object)
        if !object.kind_of?(Array) || !object.kind_of?(Node::Container)
          object = [object].flatten.compact
        end
        if object.kind_of?(Array)
          object = Node::Container.new(object)
        end
        object
      end

    end

  end

end
