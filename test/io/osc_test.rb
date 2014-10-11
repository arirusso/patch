require "helper"

class Patch::IO::OSCTest < Test::Unit::TestCase

  include Patch

  context "OSC" do

    setup do
      @action_path = File.join(__dir__,"../config/action.yml")
      @nodes_path = File.join(__dir__,"../config/nodes.yml")
      @nodes = Patch::Nodes.new(@nodes_path)
      @action = Patch::Action.new(@action_path)
      @osc = @nodes.find_all_by_type(:osc).first
      @osc.action = @action.find_all_by_type(:osc)
      @osc.instance_variable_get("@server").stubs(:run).returns(:true)
    end

    context "#initialize" do

      should "have id" do
        assert_not_nil @osc.id
      end

      should "initialize client" do
        assert_not_nil @osc.instance_variable_get("@client")
      end

      should "initialize server" do
        assert_not_nil @osc.instance_variable_get("@server")
      end

    end

    context "#handle_message_received" do

      setup do
        @client = @osc.instance_variable_get("@client").instance_variable_get("@client")
        @message = ::OSC::Message.new( "/1/rotaryA" , 0.5 )
      end

      should "return array of messages" do
        @client.expects(:send).once.with(@message)
        @results = @osc.send(:handle_message_received, @message)
        assert_not_nil @results
        assert_equal Array, @results.class
        assert_not_empty @results

        @results.each do |message|
          assert_equal Message, message.class
          assert_equal :test_patch, message.patch_name
          assert_not_nil message.index
          assert_not_nil message.value
        end
      end

      should "yield array of messages" do
        @client.expects(:send).once.with(@message)
        @osc.send(:handle_message_received, @message) do |messages|
          @results = messages
          assert_not_nil @results
          assert_equal Array, @results.class
          assert_not_empty @results

          @results.each do |message|
            assert_equal Message, message.class
            assert_equal :test_patch, message.patch_name
            assert_not_nil message.index
            assert_not_nil message.value
          end
        end
      end

      should "scale value" do
        @client.expects(:send).once.with(@message)
        scale = Object.new
        scale.expects(:from).once.returns(scale)
        scale.expects(:to).once
        @results = @osc.send(:handle_message_received, @message)
        Scale.unstub(:transform)
      end
    end

    context "#start" do

      should "start server" do
        server = @osc.instance_variable_get("@server")
        server.expects(:run)
        @osc.start
      end

    end

  end

end

