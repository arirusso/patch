require "helper"

class Patch::IO::MIDITest < Test::Unit::TestCase

  context "MIDI" do

    setup do
      @patches_path = File.join(__dir__, "../config/patches.yml")
      @patches_file = File.new(@patches_path)
      @patches = Patch::Patch.all_from_spec(@patches_file)
    end

    context "Input" do

      setup do
        @nodes_file = File.join(__dir__,"../config/nodes.yml")
        @nodes = Patch::Node.all_from_spec(@nodes_file)
        @input = @nodes.find_all_by_type(:midi).first
      end

      context "#initialize" do

        should "have id" do
          assert_not_nil @input.id
        end

        should "have midi input" do
          assert_not_nil @input
        end

        should "initialize midi listener" do
          assert_not_nil @input.instance_variable_get("@listener")
        end

      end

      context "#start" do

        should "start listener" do
          ::MIDIEye::Listener.any_instance.expects(:run)
          @input.start
        end

      end

      context "#handle_event_received" do

        setup do
          @message = MIDIMessage::ControlChange.new(0, 0x00, 0x30)
          @patch = @patches.first
        end

        should "perform scaling on value" do
          scale = Object.new
          Scale.expects(:transform).once.returns(scale)
          scale.expects(:from).once.returns(scale)
          scale.expects(:to).once
          @result = @input.send(:handle_event_received, @patch, { :message => @message })
        end

        should "return array of messages" do
          Scale.unstub(:transform)
          @result = @input.send(:handle_event_received, @patch, { :message => @message })
          assert_not_nil @result
          assert_equal Array, @result.class
          assert_not_empty @result

          @result.each do |message|
            assert_equal ::Patch::Message, message.class
            assert_equal :test_patch, message.patch_name
            assert_not_nil message.index
            assert_not_nil message.value
          end
        end

        should "yield array of messages" do
          Scale.unstub(:transform)
          @input.send(:handle_event_received, @patch, { :message => @message }) do |hash|
            @result = hash
            assert_not_nil @result
            assert_equal Array, @result.class
            assert_not_empty @result

            @result.each do |message|
              assert_equal ::Patch::Message, message.class
              assert_equal :test_patch, message.patch_name
              assert_not_nil message.index
              assert_not_nil message.value
            end
          end
        end

      end
    end

    context "Message" do

      context ".to_midi_messages" do

        setup do
          @message = Patch::Message.new(:index => 0, :patch_name => @patches.first.name, :value => 3.0)
          @result = ::Patch::IO::MIDI::Message.to_midi_messages(@patches.first, @message)
        end

        should "have correct properties" do
          assert_not_nil @result
          assert_not_empty @result
          message = @result.first

          assert_equal ::MIDIMessage::ControlChange, message.class
          assert_equal 0, message.index
          assert_equal 75, message.value
        end

      end

      context ".to_patch_messages" do

        setup do
          @message = MIDIMessage::ControlChange.new(0, 0, 127)
          @result = ::Patch::IO::MIDI::Message.to_patch_messages(@patches.first, @message)
        end

        should "have correct values" do
          assert_not_nil @result
          assert_not_empty @result
          message = @result.first

          assert_equal ::Patch::Message, message.class
          assert_equal 0, message.index
          assert_equal 5, message.value
        end

      end

    end

    context "Output" do

      setup do
        @patch = @patches.first
        @output = ::Patch::IO::MIDI::Output.new(:id => 0)
      end

      context "#initialize" do

        should "have id" do
          assert_not_nil @output.id
        end

      end

      context "#puts" do

        setup do
          @message = Patch::Message.new
          @message.index = 0
          @message.value = 100
          @message.patch_name = @patch.name
        end

        should "send midi message" do
          @output.instance_variable_set("@device", Object.new)
          @output.device.expects(:puts).once
          @output.puts(@patch, @message)
        end

      end

    end

  end
end
