require "helper"

class ControlHub::Input::MIDITest < Test::Unit::TestCase

  include ControlHub

  context "MIDI" do

    setup do
      @control = File.join(__dir__,"../config/control.yml")
      @io = File.join(__dir__,"../config/io.yml")
      @config = ControlHub::Config.new(:control => @control, :io => @io)
      @midi = ControlHub::Input::MIDI.new(@config.nodes(:input, :type => :midi).first, :control => @config.controls(:midi))
    end

    context "#initialize" do

      setup do
        inputs = @config.nodes(:input, :type => :midi)
        assert_not_nil inputs
        assert_not_empty inputs
        assert_not_nil inputs.first[:name]
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
        ::MIDIEye::Listener.any_instance.expects(:run)
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
        assert_equal Message, @result.class
        assert_not_nil @result[:index]
        assert_not_nil @result[:value]
        assert_equal @message.index - 1, @result[:index][:a_namespace]
      end

      should "yield hash" do
        Scale.unstub(:transform)
        @midi.send(:handle_event_received, { :message => @message }) do |hash|
          @result = hash
          assert_not_nil @result
          assert_equal Message, @result.class
          assert_not_nil @result[:index]
          assert_not_nil @result[:value]
          assert_equal @message.index - 1, @result[:index][:a_namespace]
        end
      end

    end

  end

end
