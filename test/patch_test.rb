require "helper"

class Patch::PatchTest < Minitest::Test

  context "Patch" do

    setup do
      load_test_data
      @nodes = Patch::Config.to_nodes(@nodes_path)
      @patches = Patch::Config.to_patches(@nodes, @patches_path)
    end

    context "#populate_actions" do

      should "populate actions" do
        patch = @patches.first
        refute_nil patch.actions
        refute_empty patch.actions
        assert patch.actions.all? { |action| action.kind_of?(Hash) }
      end

    end

    context "#populate_maps" do

      should "populate node maps" do
        patch = @patches.first
        refute_nil patch.maps
        refute_empty patch.maps
        assert patch.maps.all? { |map| map.kind_of?(Patch::Node::Map) }
      end

    end

    context "#default_messages" do

      setup do
        @patch = @patches.first
        @messages = @patch.default_messages
        @actions_with_default = @patch.actions.select { |action| !action[:default].nil? }
      end

      should "populate messages from defaults" do
        refute_nil @messages
        refute_empty @messages
        assert_equal @actions_with_default.count, @messages.count
        @actions_with_default.each_with_index do |action, i|
          refute_nil @messages.find { |message| message.index == i }
        end
      end

    end

    context "#enable" do

      setup do
        Patch::IO::MIDI::Input.any_instance.expects(:listen).once
        Patch::IO::OSC::Server.any_instance.expects(:listen).once
        Patch::IO::Websocket::Node.any_instance.expects(:listen).once
      end

      teardown do
        Patch::IO::MIDI::Input.any_instance.unstub(:listen)
        Patch::IO::OSC::Server.any_instance.unstub(:listen)
        Patch::IO::Websocket::Node.any_instance.unstub(:listen)
      end

      should "map nodes together" do
        assert @patches.first.enable
      end

    end

  end

end
