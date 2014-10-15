require "helper"

class Patch::ReportTest < Test::Unit::TestCase

  context "Message" do

    setup do
      @patches_path = File.join(__dir__, "config/patches.yml")
      @nodes_path = File.join(__dir__, "config/nodes.yml")
      @hub = Patch::Hub.new(@nodes_path, :patches => @patches_path)
      @report = Patch::Report.new(@hub)
    end

    context "#report" do

      should "include ips" do
        ips = @report.report[:ips]
        assert_not_nil ips
        assert_equal @hub.ips.count, ips.count
      end

      should "include nodes" do
        nodes = @report.report[:nodes]
        assert_not_nil nodes
        assert_equal @hub.nodes.count, nodes.count
      end

      should "include patches" do
        patches = @report.report[:patches]
        assert_not_nil patches
        assert_equal @hub.patches.count, patches.count
      end

    end

  end

end

