module Patch 
  class Nodes

    include Enumerable
    extend Forwardable

    def_delegators :@nodes, :[], :<<, :+, :*, :-, :empty?, :push

    def initialize(nodes = nil)
      @threads = []
      @nodes = []
      @nodes += nodes unless nodes.nil?
    end

    def each(&block)
      @nodes.each(&block)
    end

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

    # Get the nodes of the given direction
    # @param [String] direction
    # @param [Hash] options
    # @option options [Symbol] :type The type of node (eg :midi)
    # @return [IO::MIDI, IO::OSC, IO::Websocket]
    def find_all_by_type(type)
      klass = Node.modules[type]
      @nodes.select { |node| node.class.name.match(/\A#{klass}.*/) }
    end

    def find_by_id(id)
      @nodes.find { |node| node.id == id }
    end

    def action=(action)
      @nodes.each do |node| 
        if node.respond_to?(:action=)
          node_type = Node.modules.find { |name, klass| node.class.name.match(/\A#{klass}.*/) }.first
          node.action = action.find_all_by_type(node_type)
        end
      end
    end

  end
end
