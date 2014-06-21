require "helper"

class ControlHub::Listener::MIDITest < Test::Unit::TestCase

  include ControlHub

  context "MIDI" do

    setup do
      @control = File.join(__dir__,"../config/control.yml")
      @io = File.join(__dir__,"../config/io.yml")
      @config = ControlHub::Config.new(:control => @control, :io => @io)
      @midi = ControlHub::Listener::MIDI.new(@config)
    end

    context "#initialize" do

      setup do
        assert_not_nil @config.io[:midi][:input]
        assert_not_nil @config.io[:midi][:input][:name]
      end

      should "have midi input" do
        assert_not_nil @midi.input
      end

      should "initialize midi listener" do
        assert_not_nil @midi.instance_variable_get("@listener")
      end

      should "create control mapping" do
        assert_not_nil @midi.instance_variable_get("@control")
      end
      
    end

    context "#listen" do

      should "start listener" do
        MIDIEye::Listener.any_instance.expects(:run)
        @midi.listen
      end

    end

    context "#handle_event_received" do

      setup do
        @message = MIDIMessage::ControlChange.new(0, 0x01, 0x30)
      end

      should "perform scaling on value" do
        scale = Object.new
        Scale.expects(:transform).once.returns(scale)
        scale.expects(:from).once.returns(scale)
        scale.expects(:to).once
        @result = @midi.send(:handle_event_received, { :message => @message })
      end

      should "return hash" do
        Scale.unstub(:transform)
        @result = @midi.send(:handle_event_received, { :message => @message })
        assert_not_nil @result
        assert_equal Hash, @result.class
        assert_not_nil @result[:index]
        assert_not_nil @result[:value]
        assert_equal @message.index - 1, @result[:index][:WebcamMesh]
      end

      should "yield hash" do
        Scale.unstub(:transform)
        @midi.send(:handle_event_received, { :message => @message }) do |hash|
          @result = hash
          assert_not_nil @result
          assert_equal Hash, @result.class
          assert_not_nil @result[:index]
          assert_not_nil @result[:value]
          assert_equal @message.index - 1, @result[:index][:WebcamMesh]
        end
      end

    end

  end

end
