require "helper"

class Patch::IO::MIDITest < Minitest::Test

  context "MIDI" do

    setup do
      load_test_data
      @nodes = Patch::Config.to_nodes(@nodes_path)
      @patches = Patch::Config.to_patches(@nodes, @patches_path)
    end

    context "Input" do

      setup do
        @input = @nodes.find_all_by_type(:midi).first
      end

      context "#initialize" do

        should "have id" do
          refute_nil @input.id
        end

        should "have midi input" do
          refute_nil @input
        end

        should "initialize midi listener" do
          refute_nil @input.instance_variable_get("@listener")
        end

      end

      context "#start" do

        setup do
          ::MIDIEye::Listener.any_instance.expects(:run)
        end

        teardown do
          ::MIDIEye::Listener.any_instance.unstub(:run)
        end

        should "start listener" do
          @input.start
        end

      end

      context "#stop" do

        setup do
          refute @input.listener.running?
          @input.start
          assert @input.listener.running?
        end

        should "stop listener" do
          assert @input.stop
          sleep(0.5) # wait until listener thread is killed
          refute @input.listener.running?
        end

      end

      context "#handle_event_received" do

        setup do
          @message = MIDIMessage::ControlChange.new(0, 0x00, 0x30)
          @patch = @patches.first
          @scale = Object.new
          @scale.expects(:from).once.returns(@scale)
          @scale.expects(:to).once
        end

        teardown do
          @scale.unstub(:from)
          @scale.unstub(:to)
        end

        context "test value" do

          setup do
            Scale.expects(:transform).once.returns(@scale)
          end

          teardown do
            Scale.unstub(:transform)
          end

          should "perform scaling on value" do
            @result = @input.send(:handle_event_received, @patch, { :message => @message })
          end

        end

        should "return array of messages" do
          @result = @input.send(:handle_event_received, @patch, { :message => @message })
          refute_nil @result
          assert_equal Array, @result.class
          refute_empty @result

          @result.each do |message|
            assert_equal ::Patch::Message, message.class
            assert_equal :test_patch, message.patch_name
            refute_nil message.index
            refute_nil message.value
          end
        end

        should "yield array of messages" do
          Scale.unstub(:transform)
          @input.send(:handle_event_received, @patch, { :message => @message }) do |hash|
            @result = hash
            refute_nil @result
            assert_equal Array, @result.class
            refute_empty @result

            @result.each do |message|
              assert_equal ::Patch::Message, message.class
              assert_equal :test_patch, message.patch_name
              refute_nil message.index
              refute_nil message.value
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
          refute_nil @result
          refute_empty @result
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
          refute_nil @result
          refute_empty @result
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
        @output = ::Patch::IO::MIDI::Output.new(0, $>)
      end

      context "#initialize" do

        should "have id" do
          refute_nil @output.id
        end

      end

      context "#puts" do

        setup do
          @message = Patch::Message.new
          @message.index = 0
          @message.value = 100
          @message.patch_name = @patch.name
          @output.device.expects(:puts).once
        end

        teardown do
          @output.device.unstub(:puts)
        end

        should "send midi message" do
          @output.puts(@patch, @message)
        end

      end

    end

  end
end
