require "helper"

class Patch::IO::WebsocketTest < Minitest::Test

  context "Websocket" do

    context "#new_from_config" do

      setup do
        @config = {
          :id => 6,
          :type => "websocket",
          :host => "localhost",
          :port => 9006
        }
        @websocket = Patch::IO::Websocket.new_from_config(@config)
      end

      should "be node" do
        refute_nil @websocket
        assert Patch::IO::Websocket::Node, @websocket.class
      end

      should "have id" do
        refute_nil @websocket.id
        assert_equal 6, @websocket.id
      end

      should "not initialize underlying socket yet" do
        assert_nil @websocket.instance_variable_get("@socket")
      end

    end

  end

end
