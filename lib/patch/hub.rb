module Patch 

  # An application object; connects the inputs and output
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

    def ips
      Socket.ip_address_list.map(&:inspect_sockaddr).select { |ip| ip.match(/\b\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}\b/) }
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
