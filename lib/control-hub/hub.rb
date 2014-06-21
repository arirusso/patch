module ControlHub

  # An application object; connects the inputs and output
  class Hub

    attr_reader :config, :inputs, :output

    def initialize(options = {})
      @debug = Debug.new($>)
      @inputs = []
      @threads = []
      populate_config(options[:control], options[:io])
      populate_output
    end

    def listen  
      EM.epoll
      EM.run do
        @output.start
        @inputs.each do |input|
          @threads << Thread.new do
            input.listen { |control| @output.act(control) }
          end
        end
        @threads.each { |thread| thread.abort_on_exception = true }
      end
    end

    def add(type)
      klass = case type
      when :midi then ControlHub::Input::MIDI
      when :osc then ControlHub::Input::OSC
      end
      @inputs << klass.new(@config, :debug => @debug) if @config.send("#{type.to_s}?")
    end

    def midi_inputs
      @inputs.select { |input| input.kind_of?(ControlHub::Input::MIDI) }
    end

    def osc_inputs
      @inputs.select { |input| input.kind_of?(ControlHub::Input::OSC) }
    end

    private

    def populate_output
      @output = Output.new(@config, :debug => @debug)
    end

    def populate_config(control_path, io_path)
      control_path ||= File.join(__dir__, "../../config/control.yml")
      io_path ||= File.join(__dir__, "../../config/io.yml")
      @config = Config.new(:control => control_path, :io => io_path)
    end

  end
end
