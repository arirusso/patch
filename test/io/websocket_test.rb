require "helper"

class Patch::IO::WebsocketTest < Test::Unit::TestCase

  context "Websocket" do

    setup do
      @nodes_path = File.join(__dir__,"../config/nodes.yml")
      @nodes = Patch::Config.to_nodes(@nodes_path)
      @server = @nodes.find_all_by_type(:websocket).first
    end

    context "#start" do

      should "start server" do
        Patch::IO::Websocket.any_instance.unstub(:start)
        EM::WebSocket.expects(:run).once
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
        @server.instance_variable_get("@socket").expects(:send).once
        assert @server.puts(@message)
      end

    end

    context "#handle_input" do

      setup do
        hash = { 
          :value => "blah", 
          :timestamp => 1396406728702 
        }
        @message = hash.to_json
        @result = @server.send(:handle_input, @message)
      end

      should "convert from String to Message" do
        assert_not_nil @result
        assert_equal ::Patch::Message, @result.class
        assert_equal "blah", @result.value
      end

      should "convert timestamp from js time to ruby" do
        time = @result.time
        assert_not_nil time
        assert_equal Time, time.class
        assert_equal 2014, time.year
        assert_equal 4, time.month
        assert_equal 22, time.hour
      end
      
    end

  end

end
