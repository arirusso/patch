require "patch/io/websocket/node"
require "patch/io/websocket/socket"

module Patch

  module IO

    # Websocket IO
    module Websocket

      # Key that will be used by Patch to identify the module
      KEY = :websocket
      extend self
      ::Patch::IO::Module.add(self)

      # Construct a websocket from a node config
      # @param [Hash] config
      # @param [Hash] options
      # @param [Hash]
      # @option properties [Log] :log
      def new_from_config(config, options = {})
        ::Patch::IO::Websocket::Node.new(config[:id], config[:host], config[:port], options)
      end

    end
  end
end
