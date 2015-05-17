require "helper"

class Patch::NodeTest < Minitest::Test

  context "Node" do

    setup do
      load_test_data
    end

    context "Container" do

      setup do
        @nodes = Patch::Config.to_nodes(@nodes_path)
      end

      context "#find_all_by_type" do

        should "return osc nodes" do
          refute_empty @nodes.find_all_by_type(:osc)
        end

        should "return midi nodes" do
          refute_empty @nodes.find_all_by_type(:midi)
        end

      end

      context "#enable" do

        setup do
          @node_classes = [Patch::IO::MIDI::Input, Patch::IO::OSC::Server, Patch::IO::Websocket::Node]
          @node_classes.each { |c| c.any_instance.expects(:start).once }
        end

        teardown do
          @node_classes.each { |c| c.any_instance.unstub(:start) }
        end

        should "enable nodes" do
          assert @nodes.enable
        end

      end

      context "#find_by_id" do

        should "return node with id" do
          node = @nodes.find_by_id(2)
          refute_nil node
          refute_nil node.id
          assert_equal 2, node.id
        end

        should "return nil if not found" do
          node = @nodes.find_by_id(99)
          assert_nil node
        end

      end

    end

    context "Map" do

      context "#enable" do

        setup do
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

end
