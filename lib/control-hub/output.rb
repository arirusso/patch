require "control-hub/output/messenger"
require "control-hub/output/server"

module ControlHub

  # Mechanism that outputs control messages
  module Output

    # Shortcut to create a new output instance
    # @param [Config] config
    # @param [Hash] options
    def self.new(config, options = {})
      Server.new(config, options)
    end

  end
end
