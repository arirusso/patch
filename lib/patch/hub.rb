module Patch 

  # The main application object
  class Hub

    attr_reader :patches, :nodes

    # @param [File, String] nodes_spec
    # @param [Hash] options
    # @option options [File, String] :patches
    def initialize(nodes_spec, options = {})
      @debug = Debug.new($>)
      @threads = []
      @nodes = Node.all_from_spec(nodes_spec, :debug => @debug)
      @patches = Patch.all_from_spec(options[:patches]) unless options[:patches].nil?
      @patches ||= []
    end

    # Collected IP addresses for the nodes
    # @return [Array<String>]
    def ips
      regex = /\b\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}\b/
      all_ips = Socket.ip_address_list.map(&:inspect_sockaddr)
      all_ips.select { |ip| !!ip.match(regex) }
    end

    # Start the hub
    # @return [Boolean]
    def listen
      @patches.each { |patch| patch.enable(@nodes) }
      begin
        EM.epoll
        EM.run { @nodes.enable }
        true
      rescue SystemExit, Interrupt => exception
        exit 0
      end
    end

  end
end
