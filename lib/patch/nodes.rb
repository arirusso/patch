module Patch

  # A container for Patch::Node
  class Nodes

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
      @nodes.map do |node|
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
      true
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

  end
end
