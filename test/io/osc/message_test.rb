require "helper"

class Patch::IO::OSC::MessageTest < Minitest::Test

  context "Message" do

    setup do
      load_test_data
      @nodes = Patch::Config.to_nodes(@nodes_path)
      @patches = Patch::Config.to_patches(@nodes, @patches_path)
    end

    context ".to_osc_messages" do

      setup do
        @message = Patch::Message.new(:index => 0, :patch_name => @patches.first.name, :value => 5)
        @result = ::Patch::IO::OSC::Message.to_osc_messages(@patches.first, @message)
      end

      should "have correct properties" do
        refute_nil @result
        refute_empty @result
        message = @result.first

        assert_equal ::OSC::Message, message.class
        assert_equal "/1/rotaryA", message.address
        assert_equal 1, message.to_a[0]
      end

    end

    context ".to_patch_messages" do

      setup do
        @message = ::OSC::Message.new("/1/rotaryA", 1)
        @result = ::Patch::IO::OSC::Message.to_patch_messages(@patches.first, @message)
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

end
