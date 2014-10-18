require "helper"

class Patch::NodeTest < Test::Unit::TestCase

  context "Node" do

    setup do
      @nodes_path = File.join(__dir__,"config/nodes.yml")
    end

    context ".modules" do

      should "contain keys and modules" do
        modules = Patch::Node.modules
        assert_not_nil modules
        assert modules.kind_of?(Hash)
        assert_not_empty modules
        assert modules.all? { |k, v| k.kind_of?(Symbol) }
        assert modules.all? { |k, v| v.kind_of?(Module) }
      end

    end

    context "Container" do

      setup do
        @nodes = Patch::Config.to_nodes(@nodes_path)
      end

      context "#find_all_by_type" do

        should "return osc nodes" do
          assert_not_empty @nodes.find_all_by_type(:osc)
        end

        should "return midi nodes" do
          assert_not_empty @nodes.find_all_by_type(:midi)
        end

      end

      context "#enable" do

        should "enable nodes" do
          Patch::IO::MIDI::Input.any_instance.expects(:start).once
          Patch::IO::OSC::Server.any_instance.expects(:start).once
          Patch::IO::Websocket.any_instance.expects(:start).once
          assert @nodes.enable
        end

      end

      context "#find_by_id" do

        should "return node with id" do
          node = @nodes.find_by_id(2)
          assert_not_nil node
          assert_not_nil node.id
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
          @patches_path = File.join(__dir__, "config/patches.yml")
          @patches = Patch::Config.to_patches(@patches_path)
          @nodes = Patch::Config.to_nodes(@nodes_path)
          @maps = @patches.first.maps
        end

        should "map nodes together" do
          Patch::IO::MIDI::Input.any_instance.expects(:listen).once
          Patch::IO::OSC::Server.any_instance.expects(:listen).once
          Patch::IO::Websocket.any_instance.expects(:listen).once
          assert @maps.first.enable(@patches.first, @nodes)
        end

      end

    end

  end

end
