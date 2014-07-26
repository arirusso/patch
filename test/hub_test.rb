require "helper"

class ControlHub::HubTest < Test::Unit::TestCase

  context "Hub" do

    context "#listen" do

      setup do
        @control = File.join(__dir__, "config/control.yml")
        @io = File.join(__dir__, "config/io.yml")
      end

      should "start listeners and controller" do
        ControlHub::IO::MIDI.any_instance.expects(:listen).once
        ControlHub::IO::OSC.any_instance.expects(:listen).once
        ControlHub::IO::Websocket.any_instance.expects(:start).once
        @instance = ControlHub::Hub.new(:control => @control, :io => @io)
      end

    end

  end

end
