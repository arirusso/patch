require "helper"

class Patch::IO::MIDI::MessageTest < Minitest::Test


  context "Message" do

    setup do
      load_test_data
      @nodes = Patch::Config.to_nodes(@nodes_path)
      @patches = Patch::Config.to_patches(@nodes, @patches_path)
    end

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

      context "not filtered" do

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

      context "filtered" do

        context "pass" do

          setup do
            @message = MIDIMessage::ControlChange.new(0, 1, 127)
            @result = ::Patch::IO::MIDI::Message.to_patch_messages(@patches.first, @message)
          end

          should "have correct values" do
            refute_nil @result
            refute_empty @result
            message = @result.first

            assert_equal ::Patch::Message, message.class
            assert_equal 1, message.index
            assert_equal 5, message.value
          end

        end

        context "reject" do

          setup do
            @message = MIDIMessage::ControlChange.new(0, 1, 0)
            @result = ::Patch::IO::MIDI::Message.to_patch_messages(@patches.first, @message)
          end

          should "have no messages" do
            refute_nil @result
            assert_empty @result
          end

        end

      end

    end

  end

end
