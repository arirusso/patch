module Patch 

  # The main application object
  class Hub

    attr_reader :log, :patches, :nodes

    # @param [Hash] options
    # @option options [IO] :log
    # @option options [Node::Container] :nodes
    # @option options [Array<Patch>] :patches
    def initialize(options = {})
      @log = Log.new(options[:log]) unless options[:log].nil?
      populate_nodes(options[:nodes])
      populate_patches(options[:patches])
      @threads = []
    end

    # Collected IP addresses for the nodes
    # @return [Array<String>]
    def ips
      regex = /\b\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}\b/
      all_ips = Socket.ip_address_list.map(&:inspect_sockaddr)
      all_ips.select { |ip| !!ip.match(regex) }
    end

    # Start the hub
    # @param [Hash] options
    # @option options [Boolean] :background Run in a background thread (default: false)
    # @return [Boolean]
    def listen(options = {})
      @patches.each { |patch| patch.enable(@nodes) }
      begin
        if !!options[:background]
          enable_nodes_in_background
        else
          enable_nodes
        end
      rescue SystemExit, Interrupt => exception
        exit 0
      end
    end

    private

    # Enable the nodes in a background thread
    # @return [Thread]
    def enable_nodes_in_background
      @thread = Thread.new do
        begin
          enable_nodes
        rescue Exception => exception
          Thread.main.raise(exception)
        end
      end
      @thread.abort_on_exception = true
      @thread
    end

    # Enable the nodes
    # @return [Boolean] Whether nodes were enabled
    def enable_nodes
      EM.epoll
      EM.run { @nodes.enable }
      !@nodes.empty?
    end

    # Populate the nodes given various arg formats
    # @param [Array<IO::MIDI, IO::OSC, IO::Websocket>, IO::MIDI, IO::OSC, IO::Websocket] nodes
    # @return [Array<IO::MIDI, IO::OSC, IO::Websocket>]
    def populate_nodes(nodes)
      if nodes.nil?
        nodes = Node::Container.new
      else
        nodes = [nodes] if !nodes.kind_of?(Array) && !nodes.kind_of?(Node::Container)
        nodes = Node::Container.new(nodes) if nodes.kind_of?(Array)
      end
      @nodes = nodes
    end

    # Populate the patches given various arg formats
    # @param [Array<Patch>, Patch] patches
    # @return [Array<Patch>]
    def populate_patches(patches)
      if patches.nil?
        patches = []
      else
        patches = [patches] if patches.kind_of?(::Patch::Patch)
      end
      @patches = patches
    end

  end
end
