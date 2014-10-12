module Patch

  class Patch

    attr_reader :action, :map, :name

    def self.all_from_spec(spec)
      spec = get_spec(spec)
      patches = []
      spec.each do |name, patch|
        patches << from_spec(name, patch)
      end
      patches
    end

    def self.from_spec(name, spec)
      action = Action.new(spec[:action])
      map = Map.new(spec[:node_map])
      new(name, action, map)
    end

    def initialize(name, action, map)
      @name = name
      @action = action
      @map = map
    end

    def enable(nodes)
      @map.each do |from, to|
        to_node = nodes.find_by_id(to)
        from.each do |id|
          from_node = nodes.find_by_id(id)
          from_node.listen(self) do |messages|
            to_node.out(messages)
          end
        end
      end
    end

    def print_report
      puts "Map"
      @map.each do |from, to|
        puts "#{from} => #{to}"
      end
      puts
      puts "Actions"
      action_names = @action.map { |mapping| mapping[:name] }
      action_names_string = action_names.join(", ")
      puts "#{@name} (#{action_names_string})"
      puts
    end

    private

    def self.get_spec(spec)
      spec_file = case spec
                  when File, String then spec
                  end
      case spec_file
      when nil then spec
      else YAML.load_file(spec_file)
      end
    end

  end
end
