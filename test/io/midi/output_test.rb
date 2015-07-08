require "helper"

class Patch::IO::MIDI::OutputTest < Minitest::Test

  context "Output" do

    setup do
      load_test_data
      @nodes = Patch::Config.to_nodes(@nodes_path)
      @patches = Patch::Config.to_patches(@nodes, @patches_path)
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
        @message.value = 5
        @message.patch_name = @patch.name
        @output.device.expects(:puts).once.with(0xB0, 0x00, 0x7F)
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
