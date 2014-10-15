require "helper"

class Patch::HubTest < Test::Unit::TestCase

  context "Hub" do

    setup do
      @patches_path = File.join(__dir__, "config/patches.yml")
      @nodes_path = File.join(__dir__, "config/nodes.yml")
      @hub = Patch::Hub.new(@nodes_path, :patches => @patches_path)
    end

    context "#ips" do

      should "have ips array" do
        assert_not_nil @hub.ips
        assert_not_empty @hub.ips
      end

    end

    context "#listen" do

      should "start listeners and controller" do
        @hub.patches.each { |patch| patch.expects(:enable).once }
        @hub.nodes.each { |node| node.expects(:enable).once }
        assert @hub.listen(:background => true)
      end

    end

  end

end
