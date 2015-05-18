require "helper"

class Patch::IO::OSC::ClientTest < Minitest::Test

  context "Client" do

    setup do
      load_test_data
      @nodes = Patch::Config.to_nodes(@nodes_path)
      @patches = Patch::Config.to_patches(@nodes, @patches_path)
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
