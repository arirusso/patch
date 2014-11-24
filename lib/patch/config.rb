module Patch

  # Deal with config files, hashes
  module Config

    extend self

    # @param [Hash] nodes_config
    # @param [Hash] options
    # @option options [IO] :log
    # @return [Hub]
    def to_hub(nodes_config, options = {})
      log = Log.new(options.fetch(:log, $>))
      nodes = to_nodes(nodes_config, :log => log)
      patches = to_patches(nodes, options[:patches]) unless options[:patches].nil?
      Hub.new(:log => log, :patches => patches)
    end

    # Instantiate actions from an action config
    # @param [Array<Hash>] config
    # @return [::Patch::Action::Container]
    def to_actions(config)
      Action::Container.new(config)
    end

    # Instantiate patch objects from the given patch config file, filename or hash
    # @param [NodeContainer] nodes
    # @param [File, Hash, String] config
    # @return [Array<Patch>]
    def to_patches(nodes, config)
      config = to_h(config)
      patches = []
      config[:patches].each do |name, patch|
        patches << to_patch(nodes, name, patch)
      end
      patches
    end

    # Instantiate node objects from the given node config or config file
    # @param [File, Hash, String] config
    # @param [Hash] options
    # @option options [Log] :log
    # @return [Node::Container]
    def to_nodes(config, options = {})
      config = to_h(config)
      node_array = config[:nodes].map { |node_config| to_node(node_config, options) }
      Node::Container.new(node_array)
    end

    # Instantiate Node::Map objects given a map config hash
    # @param [NodeContainer] nodes
    # @param [Hash] config
    # @return [Array<Node::Map>]
    def to_node_maps(nodes, config)
      config.map do |from, to|
        from_ids = [from].flatten
        to_ids = [to].flatten
        from_nodes = from_ids.map { |id| nodes.find_by_id(id) }
        to_nodes = to_ids.map { |id| nodes.find_by_id(id) }
        Node::Map.new(from_nodes, to_nodes)
      end
    end

    private

    # Instantiate a node from the given node config
    # @param [Hash] config
    # @param [Hash] options
    # @option options [Log] :log
    # @return [Patch::IO::MIDI, Patch::IO::OSC, Patch::IO::Websocket]
    def to_node(node_config, options = {})
      module_key = node_config[:type].to_sym
      mod = IO::Module.find_by_key(module_key)
      mod.new_from_config(node_config, :log => options[:log])
    end

    # Instantiate a patch object for the given config hash
    # @param [NodeContainer] nodes
    # @param [Symbol, String] name
    # @param [Hash] config
    # @return [Patch]
    def to_patch(nodes, name, config)
      action_config = config[:actions] || config[:action]
      actions = to_actions(action_config)
      maps = to_node_maps(nodes, config[:node_map])
      Patch.new(name, maps, actions)
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
