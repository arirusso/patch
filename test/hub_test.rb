require "helper"

class Patch::HubTest < Minitest::Test

  context "Hub" do

    setup do
      load_test_data
      @hub = Patch::Config.to_hub(@nodes_path, :patches => @patches_path)
    end

    context "#ips" do

      should "have ips array" do
        refute_nil @hub.ips
        refute_empty @hub.ips
      end

    end

    context "#listen" do

      should "start listeners and controller" do
        @hub.patches.each { |patch| patch.expects(:enable).once }
        @hub.nodes.each { |node| node.expects(:enable).once }
        assert @hub.listen(:background => true)
      end

    end

    context "#nodes" do

      should "be populated" do
        refute_nil @hub.nodes
      end

      should "have nodes" do
        refute_empty @hub.nodes
      end

      should "be node container" do
        assert_equal Patch::Node::Container, @hub.nodes.class
      end

    end

  end

end
