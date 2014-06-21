require "control-hub/controller/messenger"
require "control-hub/controller/server"

module ControlHub

  # Mechanism that sends control messages to the video display
  module Controller

    # Shortcut to create a new controller instance
    # @param [Config] config
    # @param [Hash] options
    def self.new(config, options = {})
      Server.new(config, options)
    end

  end
end
