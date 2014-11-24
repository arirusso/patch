module Patch

  # A network or hardware connection
  module Node

    module Module

      extend self

      def find_by_key(key)
        all.find { |mod| mod.key == key }
      end

      # Mapping of node modules and names
      # @return [Hash]
      def all
        @modules ||= [
          IO::MIDI,
          IO::OSC,
          IO::Websocket
        ]
      end

    end

    # A container for Patch::Node
    class Container < Array

      def initialize(*args)
        @threads = []
        super
      end

      # Enable the nodes in this container
      # @return [Boolean]
      def enable
        result = map { |node| enable_node(node) }
        result.any?
      end

      # Get the nodes of the given type
      # @param [Symbol] :type The type of node (eg :midi)
      # @return [Array<IO::MIDI, IO::OSC, IO::Websocket>]
      def find_all_by_type(type)
        klass = Node::Module.find_by_key(type)
        select { |node| node.class.name.match(/\A#{klass}.*/) }
      end

      # Find the node with the given id
      # @param [Fixnum] id
      # @return [IO::MIDI, IO::OSC, IO::Websocket]
      def find_by_id(id)
        find { |node| node.id == id }
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

      # @param [Array<Object>, NodeContainer, Object] from
      # @param [Array<Object>, NodeContainer, Object] to
      def initialize(from, to)
        @from = to_node_container(from)
        @to = to_node_container(to)
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
