module Patch 

  # An application object; connects the inputs and output
  class Hub

    attr_reader :nodes

    # @param [File, String] nodes_spec
    # @param [Hash] options
    # @option options [File, String] :control
    def initialize(nodes_spec, options = {})
      @debug = Debug.new($>)
      @nodes = []
      @threads = []
      @nodes = Nodes.new(nodes_spec, :debug => @debug)
      unless options[:action].nil?
        @action = Action.new(options[:action]) 
        @nodes.action = @action
      end
      @map = Map.new(@nodes)
    end

    def ips
      Socket.ip_address_list.map(&:inspect_sockaddr).select { |ip| ip.match(/\b\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}\b/) }
    end

    def print_report
      puts "Patch"
      puts "Configuration"
      puts
      puts "IPs"
      ips.each { |ip| puts ip }
      puts
      puts "Nodes"
      @nodes.each do |node|
        puts "#{node.id}: #{node.class.name}"
      end
      puts
      puts "Map"
      @map.each do |from, to|
        puts "#{from} => #{to}"
      end
      puts
      puts "Actions"
      @action.each do |name, actions|
        action_names = actions.map { |action| action[:name] }.join(', ')
        puts "#{name} (#{action_names})"
      end
    end

    # Start the hub
    # @return [Boolean]
    def listen
      @map.enable
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
