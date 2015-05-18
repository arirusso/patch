module Patch

  # Deal with config files, hashes
  module Config

    extend self

    # @param [Hash] nodes_config
    # @param [Hash] options
    # @option options [IO] :log
    # @return [Hub]
    def to_hub(nodes_config, options = {})
      log = Log.new(options.fetch(:log, $>)) unless options[:log].nil?
      nodes = to_nodes(nodes_config, :log => log)
      patches = to_patches(nodes, options[:patches]) unless options[:patches].nil?
      Hub.new(:log => log, :patches => patches)
    end

    # Instantiate patch objects from the given patch config file, filename or hash
    # @param [NodeContainer] nodes
    # @param [File, Hash, String] config
    # @return [Array<Patch>]
    def to_patches(nodes, config)
      config = ensure_hash(config)
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
      config = ensure_hash(config)
      node_array = config[:nodes].map { |node_config| to_node(node_config, options) }
      Node::Container.new(node_array)
    end

    # Instantiate Node::Map objects given a map config hash
    # @param [NodeContainer] nodes
    # @param [Hash] config
    # @return [Array<Node::Map>]
    def to_node_maps(nodes, config)
      config.map { |from, to| get_node_map(nodes, from, to) }
    end

    private

    # @param [NodeContainer] nodes
    # @param [Array<Object>, Object] from (id)
    # @param [Array<Object>, Object] to (id)
    # @return [Node::Map]
    def get_node_map(nodes, from, to)
      from_nodes = get_nodes(nodes, from)
      to_nodes = get_nodes(nodes, to)
      Node::Map.new(from_nodes, to_nodes)
    end

    # @param [NodeContainer] nodes
    # @param [Array<Object>, Object] from (id)
    # @return [Array<Patch::IO::MIDI, Patch::IO::OSC, Patch::IO::Websocket>]
    def get_nodes(nodes, ids)
      ids = [ids].flatten
      ids.map { |id| nodes.find_by_id(id) }
    end

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
      actions = config[:actions] || config[:action]
      maps = to_node_maps(nodes, config[:node_map])
      Patch.new(name, maps, actions)
    end

    # @param [File, Hash, String] object
    # @return [File, String]
    def get_config_file(object)
      case object
      when File, String then object
      end
    end

    # Given a file name, file or hash, populate a config hash and freeze it
    # @param [File, Hash, String] object
    # @return [Hash]
    def ensure_hash(object)
      hash = if (config_file = get_config_file(object)).nil?
        object
      else
        YAML.load_file(config_file)
      end
      deep_freeze_config(hash) unless hash.nil?
    end

    # @param [Enumerable] container
    # @return [Enumerable]
    def deep_freeze_config(container)
      container.freeze
      values = container.respond_to?(:values) ? container.values : container
      enums = values.select { |item| item.kind_of?(Array) || item.kind_of?(Hash) }
      enums.each { |item| deep_freeze_config(item) }
      container
    end

  end
end
