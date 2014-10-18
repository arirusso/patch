require "helper"

class Patch::PatchTest < Test::Unit::TestCase

  context "Patch" do

    setup do
      @patches_path = File.join(__dir__, "config/patches.yml")
      @nodes_path = File.join(__dir__,"config/nodes.yml")
    end

    context "#enable" do

      setup do
        @nodes = Patch::Config.to_nodes(@nodes_path)
        @patches = Patch::Config.to_patches(@nodes, @patches_path)
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

