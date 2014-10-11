module Patch

  class Action

    include Enumerable
    extend Forwardable

    attr_reader :spec
    def_delegators :@spec, :empty?
    
    def initialize(spec)
      populate(spec)
    end

    def each(&block)
      @spec.each(&block)
    end

    # Actions that have specification for the given type
    # @param [Symbol, String] type The type of control eg :osc, :midi
    # @return [Hash]
    def find_all_by_type(type)
      action = {}
      @spec.each do |patch_name, patch_schema|
        action[patch_name] = patch_schema.select { |mapping| mapping.keys.map(&:to_s).include?(type.to_s) }
      end
      action
    end

    private

    def populate(spec)
      spec_file = case spec
                      when File, String then spec
                      end
      @spec = case spec_file
                 when nil then spec
                 else YAML.load_file(spec_file)
                 end
    end


  end
end
