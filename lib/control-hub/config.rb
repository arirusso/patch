module ControlHub

  # Hub configuration class
  class Config

    attr_reader :control, :control_file, :io, :io_classes, :io_file

    def initialize(options = {})
      populate_config(:control, options)
      populate_config(:io, options)
      @io_classes = {
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

    # Is there an input node?
    # @return [Boolean]
    def input?
      nodes?(:input)
    end

    # Is there an output node?
    # @return [Boolean]
    def output?
      nodes?(:output)
    end

    # The nodes for the given direction
    # @param [Symbol, String] direction
    # @param [Hash] options
    # @option options [Symbol] :type The type of node eg OSC, MIDI
    # @return [Array<IO::OSC, IO::MIDI, IO::Websocket>]
    def nodes(direction, options = {})
      if nodes?(direction)
        if options[:type].nil?
          @io[direction]
        else
          @io[direction].select { |node| node[:type] == options[:type].to_s } 
        end
      end
    end

    # Are there nodes for the given direction?
    # @param [Symbol, String] direction
    # @param [Hash] options
    # @param [Hash] options
    # @option options [Symbol] :type The type of node eg OSC, MIDI
    # @return [Boolean]
    def nodes?(direction, options = {})
      if !@io.nil? && !@io[direction].nil? && !@io[direction].empty?
        if options[:type].nil?
          true
        else 
          nodes = nodes(direction, :type => options[:type])
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

    def io_class(type)
      @io_classes[type.to_sym]
    end

    def populate_config(key, options = {})
      file_var = case options[key]
        when File, String then options[key]
      end
      instance_variable_set("@#{key.to_s}_file", file_var)
      var = case file_var
        when nil then options[key]
        else YAML.load_file(file_var)
      end
      instance_variable_set("@#{key.to_s}", var) 
    end

  end
end
