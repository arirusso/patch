require "helper"

class Patch::HubTest < Test::Unit::TestCase

  context "Hub" do

    context "#listen" do

      setup do
        @action_path = File.join(__dir__, "config/action.yml")
        @nodes_path = File.join(__dir__, "config/nodes.yml")
      end

      should "start listeners and controller" do
        Patch::IO::MIDI::Input.any_instance.expects(:listen).once
        Patch::IO::OSC::Server.any_instance.expects(:listen).once
        Patch::IO::Websocket.any_instance.expects(:start).once
        @instance = Patch::Hub.new(@nodes_path, :action => @action_path)
      end

    end

  end

end
