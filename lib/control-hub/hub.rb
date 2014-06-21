module ControlHub

  # An application object; connects the inputs and output
  class Hub

    attr_reader :config, :output, :inputs

    def initialize(options = {})
      @debug = Debug.new($>)
      @threads = []
      populate_config(options[:control], options[:io])
      populate_inputs
      populate_output
    end

    def listen  
      EM.epoll
      EM.run do
        @output.start
        @inputs.each do |input|
          @threads << Thread.new do
            input.listen { |control| @controller.act(control) }
          end
        end
        @threads.each { |thread| thread.abort_on_exception = true }
      end
    end

    private

    def populate_output
      @output = Output.new(@config, :debug => @debug)
    end

    def populate_inputs
      @inputs ||= []
      @inputs << ControlHub::Input::MIDI.new(@config, :debug => @debug) if @config.midi?
      @inputs << ControlHub::Input::OSC.new(@config, :debug => @debug) if @config.osc?
      @inputs
    end

    def populate_config(control_path, io_path)
      control_path ||= File.join(__dir__, "../../config/control.yml")
      io_path ||= File.join(__dir__, "../../config/io.yml")
      @config = Config.new(:control => control_path, :io => io_path)
    end

  end
end
