module ControlHub

  class Config

    include Input::MIDI::Config
    include Input::OSC::Config
    include Output::Websocket::Config

    attr_reader :control, :control_file, :io, :io_file

    def initialize(options = {})
      populate_config(:control, options)
      populate_config(:io, options)
    end

    def control?
      !@control.nil?
    end

    def input?
      nodes?(:input)
    end

    def node_class(direction, type)
      send("#{type}_#{direction}_class")
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

    def nodes?(direction)
      !@io.nil? && !@io[direction].nil? && !@io[direction].empty?
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
