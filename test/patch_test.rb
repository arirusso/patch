require "helper"

class Patch::PatchTest < Test::Unit::TestCase

  context "Patch" do

    setup do
      @patches_path = File.join(__dir__, "config/patches.yml")
      @patches_file = File.new(@patches_path)
    end

    context "#enable" do

      setup do
        @nodes_path = File.join(__dir__,"config/nodes.yml")
        @patches_path = File.join(__dir__, "config/patches.yml")
        @patches = Patch::Config.to_patches(@patches_path)
        @nodes = Patch::Config.to_nodes(@nodes_path)
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

