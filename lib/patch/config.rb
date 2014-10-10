module Patch 

  # Hub configuration class
  class Config

    attr_reader :control, :control_file, :io, :io_file

    def initialize(io, options = {})
      populate_io(io)
      populate_control(options[:control]) unless options[:control].nil?
      @modules = {
        :midi => IO::MIDI,
        :osc => IO::OSC,
        :websocket => IO::Websocket
      }
    end

    # Is there a control spec?
    # @return [Boolean]
    def control?
      !@control.nil?
    end

    # The nodes for the given direction
    # @param [Symbol, String] direction
    # @param [Hash] options
    # @option options [Symbol] :type The type of node eg OSC, MIDI
    # @return [Array<IO::OSC, IO::MIDI, IO::Websocket>]
    def nodes(options = {})
      if options[:type].nil?
        @io
      else
        @io[:nodes].select { |node| node[:type] == options[:type].to_s } 
      end
    end

    # Are there nodes for the given direction?
    # @param [Symbol, String] direction
    # @param [Hash] options
    # @param [Hash] options
    # @option options [Symbol] :type The type of node eg OSC, MIDI
    # @return [Boolean]
    def nodes?(options = {})
      if !@io.nil?
        if options[:type].nil?
          true
        else 
          nodes = nodes(:type => options[:type])
          !nodes.nil? && !nodes.empty?
        end
      else
        false
      end
    end

    # Controls that have specification for the given type
    # @param [Symbol, String] type The type of control eg OSC, MIDI
    # @return [Hash]
    def controls(type)
      controls = {}
      if control?
        @control.each do |namespace, schema|
          controls[namespace] = schema.select { |mapping| mapping.keys.map(&:to_s).include?(type.to_s) }
        end
      end
      controls
    end

    private

    def io_module(type)
      @modules[type.to_sym]
    end

    def populate_control(control)
      @control_file = case control
                      when File, String then control
                      end
      @control = case @control_file
                 when nil then control
                 else YAML.load_file(@control_file)
                 end
    end

    def populate_io(io)
      @io_file = case io
                 when File, String then io
                 end
      @io = case @io_file
            when nil then io
            else YAML.load_file(@io_file)
            end
    end

  end
end
