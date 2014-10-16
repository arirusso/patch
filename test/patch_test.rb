require "helper"

class Patch::PatchTest < Test::Unit::TestCase

  context "Patch" do

    setup do
      @patches_path = File.join(__dir__, "config/patches.yml")
      @patches_file = File.new(@patches_path)
    end

    context ".all_from_spec" do

      setup do
        @patches = Patch::Patch.all_from_spec(@patches_file)
      end

      should "create patches" do
        assert_not_nil @patches
        assert_not_empty @patches
        assert @patches.first.kind_of?(Patch::Patch)
      end

    end

    context ".from_spec" do

      setup do
        spec = {
          :node_map => [{ [1,2] => 3 }],
          :action => []
        }
        @patch = Patch::Patch.from_spec(:test, spec)
      end

      should "create patch" do
        assert_not_nil @patch
        assert @patch.kind_of?(Patch::Patch)
        assert_not_nil @patch.maps
        assert_not_nil @patch.actions
      end

    end

    context "#enable" do

      setup do
        @nodes_path = File.join(__dir__,"config/nodes.yml")
        @patches_path = File.join(__dir__, "config/patches.yml")
        @patches = Patch::Patch.all_from_spec(@patches_path)
        @nodes = Patch::Node.all_from_spec(@nodes_path)
      end

      should "map nodes together" do
        Patch::IO::MIDI::Input.any_instance.expects(:listen).once
        Patch::IO::OSC::Server.any_instance.expects(:listen).once
        Patch::IO::Websocket.any_instance.expects(:listen).once
        assert @patches.first.enable(@nodes)
      end

    end

  end

end

