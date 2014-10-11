module Patch

  class Nodes

    include Enumerable
    extend Forwardable

    attr_reader :spec
    def_delegators :@nodes, :empty?

    def initialize(spec)
      populate(spec)
    end

    def each(&block)
      @nodes.each(&block)
    end

    def modules
      @modules ||= {
        :midi => IO::MIDI,
        :osc => IO::OSC,
        :websocket => IO::Websocket
      }
    end

    # @return [Boolean]
    def enable
      @nodes.map do |node|
        thread = Thread.new do
          begin
            node.start if node.respond_to?(:start)
          rescue Exception => exception
            Thread.main.raise(exception)
          end
        end
        thread.abort_on_exception = true
        @threads << thread
      end
      true
    end

    # Get the nodes of the given direction
    # @param [String] direction
    # @param [Hash] options
    # @option options [Symbol] :type The type of node (eg :midi)
    # @return [IO::MIDI, IO::OSC, IO::Websocket]
    def find_all_by_type(type, &block)
      klass = modules[type]
      @nodes.select { |node| node.class.name.match(/\A#{klass}.*/) }
    end

    def find_by_id(id)
      @nodes.find { |node| node.id == id }
    end

    def action=(action)
      @nodes.each do |node| 
        if node.respond_to?(:action=)
          node_type = modules.find { |name, klass| node.class.name.match(/\A#{klass}.*/) }.first
          node.action = action.find_all_by_type(node_type)
        end
      end
    end

    private

    def populate(spec)
      populate_spec(spec)
      populate_nodes
    end

    def populate_spec(spec)
      spec_file = case spec
                 when File, String then spec
                 end
      @spec = case spec_file
            when nil then spec
            else YAML.load_file(spec_file)
            end
    end

    # Populate all of the nodes from the spec
    def populate_nodes
      nodes = @spec[:nodes].map do |node|
        mod = modules[node[:type].to_sym]
        mod.new(node, :debug => @debug)
      end 
      @nodes = nodes.flatten.compact
    end

  end
end
