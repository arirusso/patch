require "helper"

class ControlHub::InstanceTest < Test::Unit::TestCase

  context "Instance" do

    context "#listen" do

      setup do
        @control = File.join(__dir__, "config/control.yml")
        @io = File.join(__dir__, "config/io.yml")
      end

      should "start listeners and controller" do
        ControlHub::Listener::MIDI.any_instance.expects(:listen).once
        ControlHub::Listener::OSC.any_instance.expects(:listen).once
        ControlHub::Controller::Server.any_instance.expects(:start).once
        @instance = ControlHub::Instance.new(:control => @control, :io => @io)
      end

    end

  end

end
