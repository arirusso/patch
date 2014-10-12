module Patch

  class Report

    # @param [Hub] hub The hub to report about
    def initialize(hub)
      @hub = hub
    end

    # Print a report to standard out
    # @return [Hash]
    def print
      report = get_report
      cols = `tput cols`.to_i
      puts Rainbow("██████╗  █████╗ ████████╗ ██████╗██╗  ██╗").blue
      puts Rainbow("██╔══██╗██╔══██╗╚══██╔══╝██╔════╝██║  ██║").blue
      puts Rainbow("██████╔╝███████║   ██║   ██║     ███████║").blue
      puts Rainbow("██╔═══╝ ██╔══██║   ██║   ██║     ██╔══██║").blue
      puts Rainbow("██║     ██║  ██║   ██║   ╚██████╗██║  ██║").blue
      puts Rainbow("╚═╝     ╚═╝  ╚═╝   ╚═╝    ╚═════╝╚═╝  ╚═╝").blue
      puts
      puts Rainbow("IPs").cyan
      puts Rainbow("---").cyan
      report[:ips].each { |ip| puts ip }
      puts
      puts Rainbow("Nodes").cyan
      puts Rainbow("---").cyan
      report[:nodes].each do |node|
        puts "#{node[:id]}: #{node[:name]}"
      end
      puts
      puts Rainbow("Patches").cyan
      puts Rainbow("---").cyan
      report[:patches].each_with_index do |patch, i|
        puts "#{i+1}. #{patch[:name]}"
        puts Rainbow("|").cyan
        puts Rainbow("| Map").cyan
        puts Rainbow("| ---").cyan
        patch[:map].each { |map| puts Rainbow("| ").cyan + map }
        puts Rainbow("|").cyan
        puts Rainbow("| Actions").cyan
        puts Rainbow("| ---").cyan
        len = cols - 10
        chunks = []
        patch[:action].each do |action|
          if chunks.last.nil? || chunks.last.length >= len - action.length
            chunks << ""
          end
          chunk = chunks.last
          chunk << "#{action}"
          chunk << ", " unless action == patch[:action].last
        end
        chunks.each do |chunk|
          puts Rainbow("| ").cyan + chunk
        end
        puts Rainbow("|").cyan
      end
      report
    end

    # Construct the report hash
    # @return [Hash]
    def get_report
      report = {}
      report[:ips] = @hub.ips
      report[:nodes] = @hub.nodes.map { |node| node_report(node) }
      report[:patches] = @hub.patches.map { |patch| patch_report(patch) }
      report
    end

    private

    # Construct the report about a node
    # @return [Hash]
    def node_report(node)
      report = {}
      report[:id] = node.id
      report[:name] = node.class.name
      report
    end

    # Construct the report about a patch
    # @return [Hash]
    def patch_report(patch)
      report = {}
      report[:name] = patch.name
      report[:map] = patch.map.map { |from, to| "#{from} => #{to}" }
      report[:action] = patch.action.map { |mapping| mapping[:name] }
      report
    end

  end
end
