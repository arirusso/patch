require "helper"

class Patch::IO::Websocket::NodeTest < Minitest::Test

  context "Node" do

    setup do
      load_test_data
      @nodes = Patch::Config.to_nodes(@nodes_path)
      @patches = Patch::Config.to_patches(@nodes, @patches_path)
      @server = @nodes.find_all_by_type(:websocket).first
    end

    context "#listen" do

      setup do
        EM::WebSocket.expects(:run).once
      end

      teardown do
        EM::WebSocket.unstub(:run)
        #Patch::IO::Websocket.any_instance.unstub(:start)
      end

      should "start server" do
        assert @server.listen(@patches.first) do
          @val = "something"
        end
      end

    end

    context "#start" do

      setup do
        EM::WebSocket.expects(:run).once
      end

      teardown do
        EM::WebSocket.unstub(:run)
        #Patch::IO::Websocket.any_instance.unstub(:start)
      end

      should "start server" do
        assert @server.start
      end

    end

    context "#puts" do

      setup do
        @message = Patch::Message.new
        @message.index = 1
        @message.value = 100
        @message.patch_name = :test
      end

      should "convert message to json" do
        @server.stubs(:running?).returns(true)
        @server.instance_variable_set("@socket", Object.new)
        @server.instance_variable_get("@socket").expects(:puts).once
        assert @server.puts(@patches.first, @message)
      end

    end

    context "#handle_input" do

      setup do
        @timestamp = 1396406728702
        hash = {
          :value => "blah",
          :timestamp => @timestamp
        }
        @message = hash.to_json
        @result = @server.send(:handle_input, nil, @message)
      end

      should "convert from String to Message" do
        refute_nil @result
        assert_equal ::Patch::Message, @result.class
        assert_equal "blah", @result.value
      end

      should "convert timestamp from js time to ruby" do
        time = @result.time
        refute_nil time
        assert_equal Time.at(@timestamp / 1000), time
      end

    end

  end

end
