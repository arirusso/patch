module ControlHub

  class Config

    attr_reader :control, :control_file, :io, :io_classes, :io_file

    def initialize(options = {})
      populate_config(:control, options)
      populate_config(:io, options)
      @io_classes = {
        :input => {
          :midi => Input::MIDI,
          :osc => Input::OSC
        },
        :output => {
          :websocket => Output::Websocket
        }
      }
    end

    def control?
      !@control.nil?
    end

    def input?
      nodes?(:input)
    end

    def io_class(direction, type)
      @io_classes[direction][type.to_sym]
    end

    def output?
      nodes?(:output)
    end

    def nodes(direction, options = {})
      if nodes?(direction)
        if options[:type].nil?
          @io[direction]
        else
          @io[direction].select { |node| node[:type] == options[:type].to_s } 
        end
      end
    end

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

    def controls(type)
      controls = {}
      if control?
        @control.each do |key, schema|
          controls[key] = schema.select { |mapping| mapping.keys.map(&:to_s).include?(type.to_s) }
        end
      end
      controls
    end

    private

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
