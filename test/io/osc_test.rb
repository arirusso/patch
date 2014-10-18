require "helper"

class Patch::IO::OSCTest < Test::Unit::TestCase

  context "OSC" do

    setup do
      @nodes_path = File.join(__dir__,"../config/nodes.yml")
      @patches_path = File.join(__dir__,"../config/patches.yml")
      @nodes = Patch::Config.to_nodes(@nodes_path)
      @patches = Patch::Config.to_patches(@nodes, @patches_path)
    end

    context "Message" do

      context ".to_osc_messages" do

        setup do
          @message = Patch::Message.new(:index => 0, :patch_name => @patches.first.name, :value => 5)
          @result = ::Patch::IO::OSC::Message.to_osc_messages(@patches.first, @message)
        end

        should "have correct properties" do
          assert_not_nil @result
          assert_not_empty @result
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
          assert_not_nil @result
          assert_not_empty @result
          message = @result.first

          assert_equal ::Patch::Message, message.class
          assert_equal 0, message.index
          assert_equal 5, message.value
        end

      end

    end

    context "Server" do

      setup do
        @nodes_path = File.join(__dir__,"../config/nodes.yml")
        @nodes = Patch::Config.to_nodes(@nodes_path)
        @server = @nodes.find_all_by_type(:osc).first
        @server.instance_variable_get("@server").stubs(:run).returns(:true)
      end

      context "#initialize" do

        should "have id" do
          assert_not_nil @server.id
        end

        should "initialize client" do
          assert_not_nil @server.instance_variable_get("@client")
        end

        should "initialize server" do
          assert_not_nil @server.instance_variable_get("@server")
        end

      end

      context "#handle_message_received" do

        setup do
          @client = @server.instance_variable_get("@client").instance_variable_get("@client")
          @message = ::OSC::Message.new( "/1/rotaryA" , 0.5)
          @patch = @patches.first
        end

        should "return array of messages" do
          @client.expects(:send).once.with(@message)
          @results = @server.send(:handle_message_received, @patch, @message)
          assert_not_nil @results
          assert_equal Array, @results.class
          assert_not_empty @results

          @results.each do |message|
            assert_equal Patch::Message, message.class
            assert_equal :test_patch, message.patch_name
            assert_not_nil message.index
            assert_not_nil message.value
          end
        end

        should "yield array of messages" do
          @client.expects(:send).once.with(@message)
          @server.send(:handle_message_received, @patch, @message) do |messages|
            @results = messages
            assert_not_nil @results
            assert_equal Array, @results.class
            assert_not_empty @results

            @results.each do |message|
              assert_equal Patch::Message, message.class
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
          @results = @server.send(:handle_message_received, @patch, @message)
          Scale.unstub(:transform)
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
          osc_actions = @patch.actions.find_all_by_type(:osc)
          resource.expects(:add_address).times(osc_actions.count)
          assert @server.listen(@patch)
        end

      end

    end

    context "Client" do

      setup do
        @client = ::Patch::IO::OSC::Client.new("blah", 9000)
      end

      context "#puts" do

        setup do
          @resource = @client.instance_variable_get("@client")
          @resource.expects(:send).once
        end

        context "osc message" do

          setup do
            @message = ::OSC::Message.new( "/1/rotaryA" , 0.5)
          end

          should "send message to underlying client" do
            assert @client.puts(@patches.first, @message)
          end

        end

        context "patch message" do

          setup do
            @message = Patch::Message.new(:index => 0, :patch_name => @patches.first.name, :value => 5)
          end

          should "send message to underlying client" do
            assert @client.puts(@patches.first, @message)
          end

        end
        
      end

    end

  end
end
