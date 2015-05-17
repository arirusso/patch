require "helper"

class Patch::PatchTest < Minitest::Test

  context "Patch" do

    setup do
      load_test_data
    end

    context "#enable" do

      setup do
        @nodes = Patch::Config.to_nodes(@nodes_path)
        @patches = Patch::Config.to_patches(@nodes, @patches_path)
        Patch::IO::MIDI::Input.any_instance.expects(:listen).once
        Patch::IO::OSC::Server.any_instance.expects(:listen).once
        Patch::IO::Websocket::Node.any_instance.expects(:listen).once
      end

      teardown do
        Patch::IO::MIDI::Input.any_instance.unstub(:listen)
        Patch::IO::OSC::Server.any_instance.unstub(:listen)
        Patch::IO::Websocket::Node.any_instance.unstub(:listen)
      end

      should "map nodes together" do
        assert @patches.first.enable
      end

    end

  end

end
