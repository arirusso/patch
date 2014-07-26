require "helper"

class ControlHub::IO::WebsocketTest < Test::Unit::TestCase

  include ControlHub

  context "Websocket" do

    setup do
      @control = File.join(__dir__,"../config/control.yml")
      @io = File.join(__dir__,"../config/io.yml")
      @config = ControlHub::Config.new(:control => @control, :io => @io)
      @server = ControlHub::IO::Websocket.new(@config)
    end

    context "#handle_input" do

      setup do
        @message = { :value => "blah", :timestamp => 1396406728702 }.to_json
        @result = @server.handle_input(@message)
      end

      should "convert from String to Message" do
        assert_not_nil @result
        assert_equal Message, @result.class
        assert_equal "blah", @result[:value]
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

