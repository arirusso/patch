require "helper"

class Patch::IO::WebsocketTest < Test::Unit::TestCase

  context "Websocket" do

    setup do
      @nodes_path = File.join(__dir__,"../config/nodes.yml")
      @nodes = Patch::Node.all_from_spec(@nodes_path)
      @server = @nodes.find_all_by_type(:websocket).first
    end

    context "#handle_input" do

      setup do
        @message = { :value => "blah", :timestamp => 1396406728702 }.to_json
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

