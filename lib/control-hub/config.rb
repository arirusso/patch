module ControlHub

  class Config

    attr_reader :control, :control_file, :io, :io_file

    def initialize(options = {})
      populate_config(:control, options)
      populate_config(:io, options)
    end

    def control?
      !@control.nil?
    end

    def midi?
      !@io.nil? && !@io[:midi].nil? && control? && !midi_controls.empty?
    end

    def osc?
      !@io.nil? && !@io[:osc].nil? && control? && !osc_controls.empty?
    end

    def midi_controls
      @midi_controls ||= controls_for(:midi)
    end

    def osc_controls
      @osc_controls ||= controls_for(:osc)
    end

    private

    def controls_for(type)
      controls = {}
      if control?
        @control.each do |key, schema|
          controls[key] = schema.select { |mapping| mapping.keys.include?(type) }
        end
      end
      controls
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
