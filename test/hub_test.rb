require "helper"

class ControlHub::HubTest < Test::Unit::TestCase

  context "Hub" do

    context "#listen" do

      setup do
        @control = File.join(__dir__, "config/control.yml")
        @io = File.join(__dir__, "config/io.yml")
      end

      should "start listeners and controller" do
        ControlHub::Input::MIDI::Listener.any_instance.expects(:listen).once
        ControlHub::Input::OSC::Listener.any_instance.expects(:listen).once
        ControlHub::Output::Websocket::Server.any_instance.expects(:start).once
        @instance = ControlHub::Hub.new(:control => @control, :io => @io)
      end

    end

  end

end
