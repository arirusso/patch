require "helper"

class Patch::SpecTest < Minitest::Test

  context "Spec" do

    setup do
      load_test_data
    end

    context ".to_hub" do

      setup do
        @hub = Patch::Config.to_hub(@nodes_path, :patches => @patches_path)
      end

      should "have nodes" do
        refute_nil @hub.nodes
      end

      should "have patches" do
        refute_nil @hub.patches
      end

    end

    context ".to_nodes" do

      context "from files" do

        setup do
          @nodes = Patch::Config.to_nodes(@nodes_file)
        end

        should "populate" do
          refute_nil @nodes
          assert @nodes.kind_of?(Patch::Node::Container)
          refute_empty @nodes
        end

      end

      context "from strings" do

        setup do
          @nodes = Patch::Config.to_nodes(@nodes_path)
        end

        should "populate" do
          refute_nil @nodes
          assert @nodes.kind_of?(Patch::Node::Container)
          refute_empty @nodes
        end

      end

      context "from hashes" do

        setup do
          @nodes_hash = {
            :nodes => [{
              :type => "websocket",
              :id => 1,
              :host => "localhost",
              :port =>9006
            }]
          }
          @nodes = Patch::Config.to_nodes(@nodes_hash)
        end

        should "populate" do
          refute_nil @nodes
          assert @nodes.kind_of?(Patch::Node::Container)
          refute_empty @nodes
          assert_equal @nodes_hash[:nodes].count, @nodes.count
        end

      end

      context ".to_node_maps" do

        setup do
          @hash = YAML.load(File.new(@patches_path))
          @nodes = Patch::Config.to_nodes(@nodes_file)
          @map_config = @hash[:patches][:test_patch][:node_map]
        end

        should "instantiate maps" do
          @maps = Patch::Config.to_node_maps(@nodes, @map_config)
          refute_nil @maps
          refute_empty @maps
          assert_equal @map_config.size, @maps.size
          assert @maps.first.kind_of?(Patch::Node::Map)
        end

      end

      context ".to_patches" do

        setup do
          @nodes = Patch::Config.to_nodes(@nodes_file)
          @patches = Patch::Config.to_patches(@nodes, @patches_file)
        end

        should "create patches" do
          refute_nil @patches
          refute_empty @patches
          assert @patches.first.kind_of?(Patch::Patch)
        end

      end

      context ".to_patch" do

        setup do
          @nodes = Patch::Config.to_nodes(@nodes_file)
          config = {
            :node_map => [{ [1,2] => 3 }],
            :action => []
          }
          @patch = Patch::Config.send(:to_patch, @nodes, :test, config)
        end

        should "create patch" do
          refute_nil @patch
          assert @patch.kind_of?(Patch::Patch)
          refute_nil @patch.maps
          refute_nil @patch.actions
        end

      end

      context ".to_h" do

        setup do
          @path = File.join(__dir__, "config/patches.yml")
          @file = File.new(@path)
          @hash = {
            :test => {
              :node_map => [{ [1,2] => 3 }],
              :action => []
            }
          }
        end

        context "path" do

          setup do
            @config = Patch::Config.send(:to_h, @path)
          end

          should "populate" do
            refute_nil @config
            refute_empty @config
            assert_equal Hash, @config.class
            assert_equal 1, @config.keys.count
          end

        end

        context "file" do

          setup do
            @config = Patch::Config.send(:to_h, @file)
          end

          should "populate" do
            refute_nil @config
            refute_empty @config
            assert_equal Hash, @config.class
            assert_equal 1, @config.keys.count
          end

        end

        context "hash" do

          setup do
            @config = Patch::Config.send(:to_h, @hash)
          end

          should "populate" do
            refute_nil @config
            refute_empty @config
            assert_equal Hash, @config.class
            assert_equal 1, @config.keys.count
          end

        end

      end

    end
  end
end
