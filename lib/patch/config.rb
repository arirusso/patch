module Patch 

  # IO configuration class
  class Config

    attr_reader :io, :io_file

    def initialize(io)
      populate_io(io)
      @modules = {
        :midi => IO::MIDI,
        :osc => IO::OSC,
        :websocket => IO::Websocket
      }
    end

    # The nodes for the given direction
    # @param [Symbol, String] direction
    # @param [Hash] options
    # @option options [Symbol] :type The type of node eg OSC, MIDI
    # @return [Array<IO::OSC, IO::MIDI, IO::Websocket>]
    def nodes(options = {})
      if options[:type].nil?
        @io
      else
        @io[:nodes].select { |node| node[:type] == options[:type].to_s } 
      end
    end

    # Are there nodes for the given direction?
    # @param [Symbol, String] direction
    # @param [Hash] options
    # @param [Hash] options
    # @option options [Symbol] :type The type of node eg OSC, MIDI
    # @return [Boolean]
    def nodes?(options = {})
      if !@io.nil?
        if options[:type].nil?
          true
        else 
          nodes = nodes(:type => options[:type])
          !nodes.nil? && !nodes.empty?
        end
      else
        false
      end
    end

    private

    def io_module(type)
      @modules[type.to_sym]
    end

    def populate_io(io)
      @io_file = case io
                 when File, String then io
                 end
      @io = case @io_file
            when nil then io
            else YAML.load_file(@io_file)
            end
    end

  end
end
