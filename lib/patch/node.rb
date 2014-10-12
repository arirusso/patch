module Patch

  # A network or hardware connection
  module Node

    extend self

    # Instantiate nodes from the given spec or spec file
    # @param [File, Hash, String] spec
    # @return [Array<Patch::IO>]
    def all_from_spec(spec, options = {})
      spec = get_spec(spec)
      get_nodes(spec, :debug => options[:debug])
    end

    # Mapping of node modules and names
    # @return [Hash]
    def modules
      @modules ||= {
        :midi => IO::MIDI,
        :osc => IO::OSC,
        :websocket => IO::Websocket
      }
    end

    private

    # Get a spec hash from the given spec file, filename or hash
    # @param [File, Hash, String] spec
    # @return [Hash]
    def get_spec(spec)
      spec_file = case spec
                  when File, String then spec
                  end
      case spec_file
      when nil then spec
      else YAML.load_file(spec_file)
      end
    end

    # All of the nodes from the spec
    # @return [Array<Patch::IO>]
    def get_nodes(spec, options = {})
      node_array = spec[:nodes].map do |node|
        mod = modules[node[:type].to_sym]
        mod.new(node, :debug => options[:debug])
      end
      Nodes.new(node_array)
    end

  end
end
