require "helper"

class Patch::IO::OSC::ServerTest < Minitest::Test

  context "Server" do

    setup do
      load_test_data
      @nodes = Patch::Config.to_nodes(@nodes_path)
      @patches = Patch::Config.to_patches(@nodes, @patches_path)
      @nodes = Patch::Config.to_nodes(@nodes_path)
      @server = @nodes.find_all_by_type(:osc).first
      @server.instance_variable_get("@server").stubs(:run).returns(:true)
    end

    teardown do
      @server.instance_variable_get("@server").unstub(:run)
    end

    context "#initialize" do

      should "have id" do
        refute_nil @server.id
      end

      should "initialize client" do
        refute_nil @server.instance_variable_get("@client")
      end

      should "initialize server" do
        refute_nil @server.instance_variable_get("@server")
      end

    end

    context "#handle_message_received" do

      setup do
        @client = @server.instance_variable_get("@client").instance_variable_get("@client")
        @message = ::OSC::Message.new( "/1/rotaryA" , 0.5)
        @patch = @patches.first
        @client.expects(:send).once.with(@message)
        @scale = Object.new
        @scale.expects(:from).once.returns(@scale)
        @scale.expects(:to).once
      end

      teardown do
        @client.unstub(:send)
        @scale.unstub(:from)
        @scale.unstub(:to)
      end

      should "return array of messages" do
        @results = @server.send(:handle_message_received, @patch, @message)
        refute_nil @results
        assert_equal Array, @results.class
        refute_empty @results

        @results.each do |message|
          assert_equal Patch::Message, message.class
          assert_equal :test_patch, message.patch_name
          refute_nil message.index
          refute_nil message.value
        end
      end

      should "yield array of messages" do
        @server.send(:handle_message_received, @patch, @message) do |messages|
          @results = messages
          refute_nil @results
          assert_equal Array, @results.class
          refute_empty @results

          @results.each do |message|
            assert_equal Patch::Message, message.class
            assert_equal :test_patch, message.patch_name
            refute_nil message.index
            refute_nil message.value
          end
        end
      end

      should "scale value" do
        @results = @server.send(:handle_message_received, @patch, @message)
      end
    end

    context "#start" do

      should "start server" do
        server = @server.instance_variable_get("@server")
        server.expects(:run)
        @server.start
      end

    end

    context "#listen" do

      setup do
        @patch = @patches.first
      end

      should "bind addresses" do
        resource = @server.instance_variable_get("@server")
        osc_actions = Patch::IO::OSC::Action.osc_actions(@patch.actions)
        resource.expects(:add_address).times(osc_actions.count)
        assert @server.listen(@patch)
      end

    end

  end

end
