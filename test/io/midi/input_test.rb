require "helper"

class Patch::IO::MIDI::InputTest < Minitest::Test

  context "Input" do

    setup do
      load_test_data
      @nodes = Patch::Config.to_nodes(@nodes_path)
      @patches = Patch::Config.to_patches(@nodes, @patches_path)
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

      context "message value" do

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

      context "messages" do

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

  end
end
