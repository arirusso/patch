# Modules
require "patch/io/midi/action"
require "patch/io/midi/message"
# Classes
require "patch/io/midi/input"
require "patch/io/midi/output"

module Patch

  module IO

    # MIDI IO
    module MIDI

      # Key that will be used by Patch to identify the module
      KEY = :midi
      extend self
      ::Patch::IO::Module.add(self)

      # Instantiate a MIDI device based on the given config
      # @param [Hash] config
      # @param [Hash] options
      # @option options [Log] :log
      # @return [MIDI::Input, MIDI::Output]
      def new_from_config(config, options = {})
        klass = get_direction_class(config[:direction])
        klass.new(config[:id], config[:name], :log => options[:log])
      end

      private

      # Get the direction class for the given key
      # @param [Symbol] key
      # @return [Class]
      def get_direction_class(key)
        case key.to_sym
        when :input then Input
        when :output then Output
        end
      end

    end

  end
end
