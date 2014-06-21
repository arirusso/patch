module ControlHub

  # An application object; connects the MIDI/OSC listeners to the video controller
  class Instance

    attr_reader :config, :controller, :listeners

    def initialize(options = {})
      @debug = Debug.new($>)
      @threads = []
      populate_config(options[:control], options[:io])
      populate_listeners
      populate_controller
    end

    def listen  
      EM.epoll
      EM.run do
        @controller.start
        @listeners.each do |listener|
          @threads << Thread.new do
            listener.listen { |control| @controller.act(control) }
          end
        end
        @threads.each { |thread| thread.abort_on_exception = true }
      end
    end

    private

    def populate_controller
      @controller = Controller.new(@config, :debug => @debug)
    end

    def populate_listeners
      @listeners ||= []
      @listeners << ControlHub::Listener::MIDI.new(@config, :debug => @debug) if @config.midi?
      @listeners << ControlHub::Listener::OSC.new(@config, :debug => @debug) if @config.osc?
    end

    def populate_config(control_path, io_path)
      control_path ||= File.join(__dir__, "../../config/control.yml")
      io_path ||= File.join(__dir__, "../../config/io.yml")
      @config = Config.new(:control => control_path, :io => io_path)
    end

  end
end
