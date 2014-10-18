module Patch 

  # The main application object
  class Hub

    attr_reader :log, :patches, :nodes

    # @param [Hash] options
    # @option options [IO] :log
    # @option options [Node::Container] :nodes
    # @option options [Array<Patch>] :patches
    def initialize(options = {})
      @log = Log.new(options.fetch(:log, $>))
      @nodes = options.fetch(:nodes, Node::Container.new)
      @patches = options.fetch(:patches, [])
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

  end
end
