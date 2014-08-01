module ControlHub

  # An application object; connects the inputs and output
  class Hub

    attr_reader :config, :nodes

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

    def listen  
      EM.epoll
      EM.run { enable_nodes }
    end

    def outputs(options = {})
      nodes(:output, options)
    end

    def inputs(options = {})
      nodes(:input, options)
    end

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

    def populate_nodes
      populate_inputs
      populate_outputs
    end

    def enable_nodes
      enable_outputs
      enable_inputs
    end

    def enable_outputs
      @nodes[:output].each(&:start)
    end

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
    end

    def populate_inputs
      @nodes[:input] += @config.nodes(:input).map do |input|
        klass = config.io_class(input[:type])
        klass.new(input, :control => @config.controls(input[:type]), :debug => @debug)
      end
    end

    def populate_outputs
      @nodes[:output] += @config.nodes(:output).map do |output|
        klass = config.io_class(output[:type])
        klass.new(output, :debug => @debug)
      end
    end

    def populate_config(control_path, io_path)
      @config = Config.new(:control => control_path, :io => io_path)
    end

  end
end
