module ControlHub

  # An application object; connects the inputs and output
  class Hub

    attr_reader :config, :nodes

    # @param [Hash] options
    # @option options [File, String] :control
    # @option options [File, String] :io
    def initialize(options = {})
      @debug = Debug.new($>)
      @nodes = {
        :input => [],
        :output => []
      }
      @threads = []
      populate_config(options[:control], options[:io])
      populate_nodes
    end

    # Start the hub
    # @return [Boolean]
    def listen  
      EM.epoll
      EM.run { enable_nodes }
      true
    end

    # Get the output nodes
    # @param [Hash] options
    # @option options [Symbol] :type The type of node (eg :midi)
    # @return [IO::MIDI, IO::OSC, IO::Websocket]
    def outputs(options = {})
      nodes(:output, options)
    end

    # Get the input nodes
    # @param [Hash] options
    # @option options [Symbol] :type The type of node (eg :midi)
    # @return [IO::MIDI, IO::OSC, IO::Websocket]
    def inputs(options = {})
      nodes(:input, options)
    end

    # Get the nodes of the given direction
    # @param [String] direction
    # @param [Hash] options
    # @option options [Symbol] :type The type of node (eg :midi)
    # @return [IO::MIDI, IO::OSC, IO::Websocket]
    def nodes(direction, options = {})
      dir = @nodes[direction]
      if options[:type].nil?
        dir
      else
        type = @config.io_classes[options[:type]]
        dir.select { |node| node.kind_of?(type) }
      end
    end

    private

    # Populate all of the nodes from the spec
    def populate_nodes
      populate_inputs + populate_outputs
    end

    # Enable the nodes
    # @return [Boolean]
    def enable_nodes
      enable_outputs || enable_inputs
    end

    # Enable the outputs
    # @return [Boolean]
    def enable_outputs
      @nodes[:output].each(&:start)
      true
    end

    # Enable the inputs
    # @return [Boolean]
    def enable_inputs
      @nodes[:input].each do |input|
        Thread::abort_on_exception = true
        @threads << Thread.new do
          input.listen do |messages|
            @nodes[:output].each do |output| 
              output.out(messages)
            end
          end
          input.start
        end
      end
      true
    end

    # Populate the inputs
    # @return [Array]
    def populate_inputs
      @nodes[:input] += @config.nodes(:input).map do |input|
        klass = config.send(:io_class, input[:type])
        klass.new(input, :control => @config.controls(input[:type]), :debug => @debug)
      end
    end

    # Populate the outputs
    # @return [Array]
    def populate_outputs
      @nodes[:output] += @config.nodes(:output).map do |output|
        klass = config.send(:io_class, output[:type])
        klass.new(output, :debug => @debug)
      end
    end
    
    # Populate the config
    # @param [String, File] control_path
    # @param [String, File] io_path
    # @return [Config]
    def populate_config(control_path, io_path)
      @config = Config.new(:control => control_path, :io => io_path)
    end

  end
end
