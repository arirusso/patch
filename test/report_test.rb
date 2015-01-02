require "helper"

class Patch::ReportTest < Minitest::Test

  context "Message" do

    setup do
      load_test_data
      @hub = Patch::Config.to_hub(@nodes_path, :patches => @patches_path)
      @report = Patch::Report.new(@hub)
    end

    context "#report" do

      should "include ips" do
        ips = @report.report[:ips]
        refute_nil ips
        assert_equal @hub.ips.count, ips.count
      end

      should "include nodes" do
        nodes = @report.report[:nodes]
        refute_nil nodes
        assert_equal @hub.nodes.count, nodes.count
      end

      should "include patches" do
        patches = @report.report[:patches]
        refute_nil patches
        assert_equal @hub.patches.count, patches.count
      end

    end

  end

end
