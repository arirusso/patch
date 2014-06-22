module ControlHub

  # An application object; connects the inputs and output
  class Hub

    attr_reader :config, :inputs, :output

    def initialize(options = {})
      @debug = Debug.new($>)
      @inputs = []
      @threads = []
      populate_config(options[:control], options[:io])
      populate_inputs
      populate_outputs
    end

    def listen  
      EM.epoll
      EM.run do
        @output.start
        @inputs.each do |input|
          @threads << Thread.new do
            input.listen do |message| 
              @outputs.each do |output| 
                output.act(message)
              end
            end
          end
        end
        @threads.each { |thread| thread.abort_on_exception = true }
      end
    end

    def add(type)
      inputs = case type
      when :midi then get_midi_inputs
      when :osc then get_osc_inputs
      end
      @inputs += inputs unless inputs.nil?
      input
    end

    def midi_inputs
      @inputs.select { |input| input.kind_of?(ControlHub::Input::MIDI::Listener) }
    end

    def osc_inputs
      @inputs.select { |input| input.kind_of?(ControlHub::Input::OSC::Listener) }
    end

    private

    def populate_inputs
      @inputs ||= []
      @inputs += @config.nodes(:input).map do |input|
        klass = config.node_class(:input, input[:type])
        klass.new(input, @config.controls(input[:type]), :debug => @debug)
      end
    end

    def populate_outputs
      @outputs ||= []
      @outputs += @config.nodes(:output).map do |output|
        klass = config.node_class(:output, output[:type])
        klass.new(output, :debug => @debug)
      end
    end

    def populate_config(control_path, io_path)
      @config = Config.new(:control => control_path, :io => io_path)
    end

  end
end
