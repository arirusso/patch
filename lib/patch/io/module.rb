module Patch

  module IO

    # Manage node modules
    class Module

      class << self

        # Find an IO module by its key
        # @param [Symbol] key
        # @return [Module]
        def find_by_key(key)
          all.find { |mod| mod::KEY === key }
        end

        # Add an IO module to the list of modules available to Patch
        # @param [Module] mod
        # @return [Array<Module>]
        def add(mod)
          @modules ||= []
          @modules << mod
        end

        # Mapping of node modules and names
        # @return [Array<Module>]
        def all
          @modules ||= []
        end

      end

    end
  end
end
