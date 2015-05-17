# Modules
require "patch/io/osc/action"
require "patch/io/osc/message"
# Classes
require "patch/io/osc/client"
require "patch/io/osc/server"

module Patch

  module IO

    # Receive OSC messages and do something with them
    module OSC

      # Key that will be used by Patch to identify the module
      KEY = :osc
      extend self
      ::Patch::IO::Module.add(self)

      # Instantiate an OSC server and/or client using the given config
      # @param [Hash] config
      # @param [Hash] options
      # @option options [Action::Container] :actions
      # @option options [Log] :log
      # @return [::Patch::IO::OSC::Server]
      def new_from_config(config, options = {})
        instance_options = {
          :log => options[:log]
        }
        if config[:server].nil?
          unless config[:client].nil?
            instance_options[:id] = config[:id]
            Client.new(config[:client], instance_options)
          end
        else
          instance_options[:echo] = config[:client]
          Server.new(config[:id], config[:server][:port], instance_options)
        end
      end

    end
  end
end
