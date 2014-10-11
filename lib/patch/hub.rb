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
      @nodes = Nodes.new(nodes_spec)
      unless options[:action].nil?
        @action = Action.new(options[:action]) 
        @nodes.action = @action
      end
      @map = Map.new(@nodes.spec[:map])
      @map.enable(@nodes)
    end

    # Start the hub
    # @return [Boolean]
    def listen  
      EM.epoll
      EM.run { enable_nodes }
      true
    end

  end
end
