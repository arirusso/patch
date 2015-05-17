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
      @patches.each(&:enable)
      begin
        enable_nodes
        @thread.join unless !!options[:background]
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

    # Enable the nodes
    # @return [Thread]
    def enable_nodes
      @thread = ::Patch::Thread.new do
        EM.epoll
        EM.run { nodes.enable }
        !nodes.empty?
      end
    end

    # Populate the patches given various arg formats
    # @param [Array<Patch>, Patch] patches
    # @return [Array<Patch>]
    def populate_patches(patches)
      @patches = [patches].flatten.compact
    end

  end
end
