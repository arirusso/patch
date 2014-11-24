module Patch

  # Namespace for IO nodes
  module IO

    # Manage node modules
    module Module

      extend self

      def find_by_key(key)
        all.find { |mod| mod.key == key }
      end

      def add(mod)
        @modules ||= []
        @modules << mod
      end

      # Mapping of node modules and names
      # @return [Hash]
      def all
        @modules ||= []
      end

    end

  end

end

require "patch/io/midi"
require "patch/io/osc"
require "patch/io/websocket"
