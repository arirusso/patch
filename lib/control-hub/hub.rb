module ControlHub

  # An application object; connects the inputs and output
  class Hub

    attr_reader :config, :nodes

    # @param [File, String] io
    # @param [Hash] options
    # @option options [File, String] :control
    def initialize(io, options = {})
      @debug = Debug.new($>)
      @nodes = []
      @threads = []
      @config = Config.new(io, :control => options[:control])
      populate_nodes
      populate_node_map
    end

    # Start the hub
    # @return [Boolean]
    def listen  
      EM.epoll
      EM.run { enable_nodes }
      true
    end

    # Get the nodes of the given direction
    # @param [String] direction
    # @param [Hash] options
    # @option options [Symbol] :type The type of node (eg :midi)
    # @return [IO::MIDI, IO::OSC, IO::Websocket]
    def nodes(options = {})
      if options[:type].nil?
        @nodes
      else
        type = @config.io_classes[options[:type]]
        @nodes.select { |node| node.kind_of?(type) }
      end
    end

    def find_node_by_id(id)
      @nodes.find { |node| node.id == id }
    end

    private

    def populate_node_map
      @config.io[:map].each do |from, to|
        to_node = find_node_by_id(to)
        from.each do |id|
          from_node = find_node_by_id(id)
          from_node.listen do |messages| 
            to_node.out(messages)
          end
        end
      end
    end

    # Populate all of the nodes from the spec
    def populate_nodes
      nodes = @config.io[:nodes].map do |node|
        mod = config.send(:io_module, node[:type])
        options = { 
          :control => @config.controls(node[:type]), 
          :debug => @debug
        }
        mod.new(node, options)
      end 
      @nodes += nodes.flatten.compact
    end

    # Enable the inputs
    # @return [Boolean]
    def enable_nodes
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
    
  end
end
