module Patch

  # A network or hardware connection
  module Node

    extend self

    # Instantiate nodes from the given spec or spec file
    # @param [File, Hash, String] spec
    # @return [Array<Patch::IO>]
    def all_from_spec(spec, options = {})
      spec = Spec.new(spec)
      get_nodes(spec, :debug => options[:debug])
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
    # @return [::Patch::Node::Container]
    def get_nodes(spec, options = {})
      node_array = spec[:nodes].map do |node|
        type = node[:type].to_sym
        mod = modules[type]
        mod.new(node, :debug => options[:debug])
      end
      Container.new(node_array)
    end

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
      end

    end

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
end
