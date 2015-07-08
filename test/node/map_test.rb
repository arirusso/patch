require "helper"

class Patch::Node::MapTest < Minitest::Test
  include Mocha::ParameterMatchers

  context "Map" do

    setup do
      load_test_data
      @nodes = Patch::Config.to_nodes(@nodes_path)
      @patches = Patch::Config.to_patches(@nodes, @patches_path)
    end

    context "#nodes" do

      setup do
        @map = @patches.first.maps.first
      end

      should "return all from and to nodes" do
        @nodes = @map.nodes
        refute_nil @nodes
        refute_empty @nodes
        assert @map.from.all? { |node| @nodes.include?(node) }
        assert @map.to.all? { |node| @nodes.include?(node) }
      end

    end

    context "#enable" do

      setup do
        @patch = @patches.first
        @maps = @patch.maps
        refute_empty @nodes
        assert [Patch::IO::MIDI::Input, Patch::IO::OSC::Server, Patch::IO::Websocket::Node].all? { |klass| @nodes.map(&:class).include?(klass) }
        ::Patch::Thread.expects(:new).times(@nodes.count)
        refute_empty @maps
        @maps.each do |map|
          refute_empty map.to.nodes
          map.to.nodes.each do |node|
            node.expects(:puts).at_least_once.with(is_a(Patch::Patch), is_a(Array))
          end
        end
      end

      teardown do
        ::Patch::Thread.unstub(:new)
        @maps.each do |map|
          map.to.nodes.each { |node| node.unstub(:puts) }
        end
      end

      should "create node start threads" do
        assert @maps.first.enable(@patch)
      end

    end

  end

end
