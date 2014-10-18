module Patch

  # A network or hardware connection
  module Node

    module ClassMethods

      # Instantiate nodes from the given spec or spec file
      # @param [File, Hash, String] spec
      # @param [Hash] options
      # @option options [Log] :log
      # @return [Array<Patch::IO>]
      def all_from_spec(spec, options = {})
        spec = Spec.new(spec)
        get_nodes(spec, :log => options[:log])
      end

      # Mapping of node modules and names
      # @return [Hash]
      def modules
        @modules ||= {
          :midi => IO::MIDI,
          :osc => IO::OSC,
          :websocket => IO::Websocket
        }
      end

      private

      # All of the nodes from the spec
      # @param [Hash] spec
      # @param [Hash] options
      # @option options [Log] :log
      # @return [::Patch::Node::Container]
      def get_nodes(spec, options = {})
        node_array = spec[:nodes].map do |node|
          type = node[:type].to_sym
          mod = modules[type]
          mod.new_from_spec(node, :log => options[:log])
        end
        Container.new(node_array)
      end

    end
    extend ClassMethods

    # A container for Patch::Node
    class Container

      include Enumerable
      extend Forwardable

      def_delegators :@nodes, :[], :<<, :+, :*, :-, :empty?, :push

      # @param [Node, nil] nodes
      def initialize(nodes = nil)
        @threads = []
        @nodes = []
        @nodes += nodes unless nodes.nil?
      end

      def each(&block)
        @nodes.each(&block)
      end

      # Enable the nodes in this container
      # @return [Boolean]
      def enable
        result = @nodes.map { |node| enable_node(node) }
        result.any?
      end

      # Get the nodes of the given type
      # @param [Symbol] :type The type of node (eg :midi)
      # @return [Array<IO::MIDI, IO::OSC, IO::Websocket>]
      def find_all_by_type(type)
        klass = Node.modules[type]
        @nodes.select { |node| node.class.name.match(/\A#{klass}.*/) }
      end

      # Find the node with the given id
      # @param [Fixnum] id
      # @return [IO::MIDI, IO::OSC, IO::Websocket]
      def find_by_id(id)
        @nodes.find { |node| node.id == id }
      end

      private

      # Enable the given node
      # @param [Patch::Node] node
      # @return [Boolean]
      def enable_node(node)
        thread = Thread.new do
          begin
            node.start if node.respond_to?(:start)
          rescue Exception => exception
            Thread.main.raise(exception)
          end
        end
        thread.abort_on_exception = true
        @threads << thread
        true
      end

    end

    # A map of connections between nodes for a given patch
    class Map

      attr_reader :from, :to

      # Instantiate Map objects given a map spec hash
      # @param [Hash] spec
      # @return [Array<Map>]
      def self.all_from_spec(spec)
        spec.map { |from, to| new(from, to) }
      end

      # @param [Array<Fixnum>, Fixnum] from
      # @param [Array<Fixnum>, Fixnum] to
      def initialize(from, to)
        @from = [from].flatten
        @to = [to].flatten
      end

      # Enable this map for the given nodes
      # @param [::Patch::Patch] patch The patch context to enable the map in
      # @param [::Patch::Node::Container] nodes Nodes to enable this map for
      # @return [Boolean] Whether nodes were enabled
      def enable(patch, nodes)
        result = @to.map do |to_id|
          to_node = nodes.find_by_id(to_id)
          enabled = @from.map do |from_id|
            from_node = nodes.find_by_id(from_id)
            from_node.listen(patch) do |messages|
              to_node.puts(messages)
            end
            true
          end
          enabled.any?
        end
        result.any?
      end

    end

  end
end
