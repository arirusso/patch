require "helper"

class Patch::HubTest < Test::Unit::TestCase

  context "Hub" do

    context "#listen" do

      setup do
        @action = File.join(__dir__, "config/control.yml")
        @io = File.join(__dir__, "config/io.yml")
      end

      should "start listeners and controller" do
        Patch::IO::MIDI::Input.any_instance.expects(:listen).once
        Patch::IO::OSC::Server.any_instance.expects(:listen).once
        Patch::IO::Websocket.any_instance.expects(:start).once
        @instance = Patch::Hub.new(@io, :action => @action)
      end

    end

  end

end
