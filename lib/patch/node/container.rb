module Patch

  module Node

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
        klass = IO::Module.find_by_key(type)
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
        if node.respond_to?(:start) && !node.active?
          @threads << ::Patch::Thread.new { node.start }
        end
        true
      end

    end

  end

end
