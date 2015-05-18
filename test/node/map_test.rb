require "helper"

class Patch::Node::MapTest < Minitest::Test

  context "Map" do

    context "#enable" do

      setup do
        load_test_data
        @nodes = Patch::Config.to_nodes(@nodes_path)
        @patches = Patch::Config.to_patches(@nodes, @patches_path)
        @maps = @patches.first.maps
        @node_classes = [Patch::IO::MIDI::Input, Patch::IO::OSC::Server, Patch::IO::Websocket::Node]
        @node_classes.each { |c| c.any_instance.expects(:listen).once }
      end

      teardown do
        @node_classes.each { |c| c.any_instance.unstub(:listen) }
      end

      should "map nodes together" do
        assert @maps.first.enable(@patches.first)
      end

    end

  end

end
