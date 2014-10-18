module Patch

  # Deal with config files, hashes
  module Config

    extend self

    # @param [Hash] nodes_config
    # @param [Hash] options
    # @option options [IO] :log
    def to_hub(nodes_config, options = {})
      log = Log.new(options.fetch(:log, $>))
      nodes = to_nodes(nodes_config, :log => log)
      patches = to_patches(options[:patches]) unless options[:patches].nil?
      Hub.new(:log => log, :nodes => nodes, :patches => patches)
    end

    # Instantiate actions from an action config
    # @param [Array<Hash>] config
    # @return [::Patch::Action::Container]
    def to_actions(config)
      Action::Container.new(config)
    end

    # Instantiate patch objects from the given patch config file, filename or hash
    # @param [File, Hash, String] config
    # @return [Array<Patch>]
    def to_patches(config)
      config = to_h(config)
      patches = []
      config[:patches].each do |name, patch|
        patches << to_patch(name, patch)
      end
      patches
    end

    # Instantiate node objects from the given node config or config file
    # @param [File, Hash, String] config
    # @param [Hash] options
    # @option options [Log] :log
    # @return [Array<Patch::IO>]
    def to_nodes(config, options = {})
      config = to_h(config)
      node_array = config[:nodes].map { |node_config| to_node(node_config, options) }
      Node::Container.new(node_array)
    end

    # Instantiate Node::Map objects given a map config hash
    # @param [Hash] config
    # @return [Array<Node::Map>]
    def to_node_maps(config)
      config.map { |from, to| Node::Map.new(from, to) }
    end

    private

    # Instantiate a node from the given node config
    # @param [Hash] config
    # @param [Hash] options
    # @option options [Log] :log
    # @return [Patch::IO::MIDI, Patch::IO::OSC, Patch::IO::Websocket]
    def to_node(node_config, options = {})
      type = node_config[:type].to_sym
      mod = Node.modules[type]
      mod.new_from_config(node_config, :log => options[:log])
    end

    # Instantiate a patch object for the given config hash
    # @param [Symbol, String] name
    # @param [Hash] config
    # @return [Patch]
    def to_patch(name, config)
      action_config = config[:actions] || config[:action]
      actions = to_actions(action_config)
      maps = to_node_maps(config[:node_map])
      Patch.new(name, actions, maps)
    end

    # Given a file name, file or hash, populate a config hash
    # @param [File, Hash, String] object
    # @return [Hash]
    def to_h(object)
      config_file = case object
                  when File, String then object
                  end
      case config_file
      when nil then object
      else YAML.load_file(config_file)
      end
    end

  end
end
