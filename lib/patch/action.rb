module Patch

  class Action

    extend Forwardable

    attr_reader :spec
    def_delegators :@spec, :empty?
    
    def initialize(spec)
      populate(spec)
    end

    # Actions that have specification for the given type
    # @param [Symbol, String] type The type of control eg :osc, :midi
    # @return [Hash]
    def find_all_by_type(type)
      controls = {}
      @spec.each do |namespace, schema|
        controls[namespace] = schema.select { |mapping| mapping.keys.map(&:to_s).include?(type.to_s) }
      end
      controls
    end

    private

    def populate(control)
      spec_file = case control
                      when File, String then control
                      end
      @spec = case spec_file
                 when nil then control
                 else YAML.load_file(spec_file)
                 end
    end


  end
end
