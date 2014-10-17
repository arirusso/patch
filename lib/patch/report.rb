module Patch

  # Terminal/Console output explaining the hub configuration
  class Report

    # @param [Hub] hub The hub to print a report for
    # @return [Report]
    def self.print(hub)
      new(hub).print
    end

    # @param [Hub] hub The hub to report about
    def initialize(hub)
      @hub = hub
    end

    # Print a report to standard out
    # @return [Report] self
    def print
      report = self.report
      puts
      print_logo
      puts
      puts Rainbow("IPs").cyan
      puts Rainbow("———").cyan
      report[:ips].each { |ip| puts ip }
      puts
      puts Rainbow("Nodes").cyan
      puts Rainbow("———").cyan
      report[:nodes].each do |node|
        puts "#{node[:id]}: #{node[:name]}"
      end
      puts
      if report[:patches].count > 0
        puts Rainbow("Patches").cyan
        puts Rainbow("———").cyan
        report[:patches].each_with_index do |patch, i|
          puts "#{i+1}. #{patch[:name]}"
          puts Rainbow("|").cyan
          puts Rainbow("| Node Map").cyan
          puts Rainbow("| ———").cyan
          patch[:maps].each { |map| puts Rainbow("| ").cyan + map }
          puts Rainbow("|").cyan
          puts Rainbow("| Actions").cyan
          puts Rainbow("| ———").cyan
          chunked_actions(patch[:actions]).each do |chunk|
            puts Rainbow("| ").cyan + chunk
          end
          puts Rainbow("|").cyan
          puts
        end
      else
        puts
      end
      puts "Logging to #{report[:log_file]}"
      puts
      self
    end

    # Construct the report hash
    # @return [Hash]
    def report
      report = {}
      report[:ips] = @hub.ips
      report[:nodes] = @hub.nodes.map { |node| node_report(node) }
      report[:patches] = @hub.patches.map { |patch| patch_report(patch) }
      report[:log_file] = @hub.log_file.path
      report
    end

    private

    # Get a patch action formatted for terminal width
    # @param [Array<String>] actions
    # @return [Array<String>]
    def chunked_actions(actions)
      max_length = columns - 10
      chunks = []
      actions.each do |action|
        if chunks.last.nil? || chunks.last.length >= max_length - action.length
          chunks << ""
        end
        chunk = chunks.last
        chunk << "#{action}"
        chunk << ", " unless action == actions.last
      end
      chunks
    end

    # The number of columns of the terminal
    # @return [Fixnum]
    def columns
      `tput cols`.to_i
    end

    # Output the patch logo
    # @return [Boolean]
    def print_logo
      color = :blue
      puts Rainbow("██████╗  █████╗ ████████╗ ██████╗██╗  ██╗").send(color)
      puts Rainbow("██╔══██╗██╔══██╗╚══██╔══╝██╔════╝██║  ██║").send(color)
      puts Rainbow("██████╔╝███████║   ██║   ██║     ███████║").send(color)
      puts Rainbow("██╔═══╝ ██╔══██║   ██║   ██║     ██╔══██║").send(color)
      puts Rainbow("██║     ██║  ██║   ██║   ╚██████╗██║  ██║").send(color)
      puts Rainbow("╚═╝     ╚═╝  ╚═╝   ╚═╝    ╚═════╝╚═╝  ╚═╣").send(color)
      puts Rainbow("═≡≡≡▓▓▓═════════════════════════════════╝").send(color)
      true
    end

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
      report[:maps] = patch.maps.map { |map| "#{map.from} => #{map.to}" }
      report[:actions] = patch.actions.map { |mapping| mapping[:name] }
      report
    end

  end
end
