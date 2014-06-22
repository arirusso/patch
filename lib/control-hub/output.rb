require "control-hub/output/messenger"
require "control-hub/output/websocket"

module ControlHub

  # Mechanism that outputs control messages
  module Output

    # Shortcut to create a new output instance
    # @param [Config] config
    # @param [Hash] options
    def self.new(config, options = {})
      Websocket.new(config, options)
    end

  end
end
