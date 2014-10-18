require "helper"

class Patch::SpecTest < Test::Unit::TestCase

  context "Spec" do

    setup do
      @nodes_path = File.join(__dir__,"config/nodes.yml")
      @nodes_file = File.new(@nodes_path)
      @patches_path = File.join(__dir__, "config/patches.yml")
      @patches_file = File.new(@patches_path)
    end

    context ".to_hub" do

      setup do
        @hub = Patch::Config.to_hub(@nodes_path, :patches => @patches_path)
      end

      should "have nodes" do
        assert_not_nil @hub.nodes
      end

      should "have patches" do
        assert_not_nil @hub.patches
      end

    end

    context ".to_nodes" do

      context "from files" do

        setup do
          @nodes = Patch::Config.to_nodes(@nodes_file)
        end

        should "populate" do
          assert_not_nil @nodes
          assert @nodes.kind_of?(Patch::Node::Container)
          assert_not_empty @nodes
        end

      end

      context "from strings" do

        setup do
          @nodes = Patch::Config.to_nodes(@nodes_path)
        end

        should "populate" do
          assert_not_nil @nodes
          assert @nodes.kind_of?(Patch::Node::Container)
          assert_not_empty @nodes
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
          assert_not_nil @nodes
          assert @nodes.kind_of?(Patch::Node::Container)
          assert_not_empty @nodes
          assert_equal @nodes_hash[:nodes].count, @nodes.count
        end

      end

      context ".to_node_maps" do

        setup do
          @patches_path = File.join(__dir__, "config/patches.yml")
          @hash = YAML.load(File.new(@patches_path))
          @map_spec = @hash[:patches][:test_patch][:node_map]
        end

        should "instantiate maps" do
          @maps = Patch::Config.to_node_maps(@map_spec)
          assert_not_nil @maps
          assert_not_empty @maps
          assert_equal @map_spec.size, @maps.size
          assert @maps.first.kind_of?(Patch::Node::Map)
        end

      end

      context ".to_patches" do

        setup do
          @patches = Patch::Config.to_patches(@patches_file)
        end

        should "create patches" do
          assert_not_nil @patches
          assert_not_empty @patches
          assert @patches.first.kind_of?(Patch::Patch)
        end

      end

      context ".to_patch" do

        setup do
          spec = {
            :node_map => [{ [1,2] => 3 }],
            :action => []
          }
          @patch = Patch::Config.send(:to_patch, :test, spec)
        end

        should "create patch" do
          assert_not_nil @patch
          assert @patch.kind_of?(Patch::Patch)
          assert_not_nil @patch.maps
          assert_not_nil @patch.actions
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
            @spec = Patch::Config.send(:to_h, @path)
          end

          should "populate" do
            assert_not_nil @spec
            assert_not_empty @spec
            assert_equal Hash, @spec.class
            assert_equal 1, @spec.keys.count
          end

        end

        context "file" do

          setup do
            @spec = Patch::Config.send(:to_h, @file)
          end

          should "populate" do
            assert_not_nil @spec
            assert_not_empty @spec
            assert_equal Hash, @spec.class
            assert_equal 1, @spec.keys.count
          end

        end

        context "hash" do

          setup do
            @spec = Patch::Config.send(:to_h, @hash)
          end

          should "populate" do
            assert_not_nil @spec
            assert_not_empty @spec
            assert_equal Hash, @spec.class
            assert_equal 1, @spec.keys.count
          end

        end

      end

    end
  end
end
