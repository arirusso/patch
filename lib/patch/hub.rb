module Patch

  # The main application object
  class Hub

    attr_reader :log, :patches

    # @param [Hash] options
    # @option options [IO] :log
    # @option options [Array<Patch>] :patches
    def initialize(options = {})
      @log = Log.new(options[:log]) unless options[:log].nil?
      populate_patches(options[:patches] || options[:patch])
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
    # @return [Hub] self
    def listen(options = {})
      @patches.each { |patch| patch.enable }
      begin
        if !!options[:background]
          enable_nodes_in_background
        else
          enable_nodes
        end
        self
      rescue SystemExit, Interrupt => exception
        exit 0
      end
    end

    # All of the nodes used by the patches
    # @return [Node::Container]
    def nodes
      nodes = @patches.map { |patch| patch.maps.map(&:nodes) }.flatten.compact.uniq
      Node::Container.new(nodes)
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
      EM.run { nodes.enable }
      !nodes.empty?
    end

    # Populate the patches given various arg formats
    # @param [Array<Patch>, Patch] patches
    # @return [Array<Patch>]
    def populate_patches(patches)
      @patches = [patches].flatten.compact
    end

  end
end
