require "helper"

class Patch::NodeTest < Test::Unit::TestCase

  context "Node" do

    setup do
      @nodes_path = File.join(__dir__,"config/nodes.yml")
    end

    context "ClassMethods" do

      context "#all_from_spec" do

        context "from files" do

          setup do
            @nodes_file = File.new(@nodes_path)
            @nodes = Patch::Node.all_from_spec(@nodes_file)
          end

          should "populate" do
            assert_not_nil @nodes
            assert @nodes.kind_of?(Patch::Node::Container)
            assert_not_empty @nodes
          end

        end

        context "from strings" do

          setup do
            @nodes = Patch::Node.all_from_spec(@nodes_path)
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
            @nodes = Patch::Node.all_from_spec(@nodes_hash)
          end

          should "populate" do
            assert_not_nil @nodes
            assert @nodes.kind_of?(Patch::Node::Container)
            assert_not_empty @nodes
            assert_equal @nodes_hash[:nodes].count, @nodes.count
          end

        end

      end

      context "#modules" do

        should "contain keys and modules" do
          modules = Patch::Node.modules
          assert_not_nil modules
          assert modules.kind_of?(Hash)
          assert_not_empty modules
          assert modules.all? { |k, v| k.kind_of?(Symbol) }
          assert modules.all? { |k, v| v.kind_of?(Module) }
        end

      end

    end

    context "Container" do

      setup do
        @nodes = Patch::Node.all_from_spec(@nodes_path)
      end

      context "#find_all_by_type" do

        should "return osc nodes" do
          assert_not_empty @nodes.find_all_by_type(:osc)
        end

        should "return midi nodes" do
          assert_not_empty @nodes.find_all_by_type(:midi)
        end

      end

      context "#enable" do

        should "enable nodes" do
          Patch::IO::MIDI::Input.any_instance.expects(:start).once
          Patch::IO::OSC::Server.any_instance.expects(:start).once
          Patch::IO::Websocket.any_instance.expects(:start).once
          assert @nodes.enable
        end

      end

      context "#find_by_id" do

        should "return node with id" do
          node = @nodes.find_by_id(2)
          assert_not_nil node
          assert_not_nil node.id
          assert_equal 2, node.id
        end
        
        should "return nil if not found" do
          node = @nodes.find_by_id(99)
          assert_nil node
        end

      end

    end

    context "Map" do

      context ".all_from_spec" do

        setup do
          @patches_path = File.join(__dir__, "config/patches.yml")
          @hash = YAML.load(File.new(@patches_path))
          @map_spec = @hash[:test_patch][:node_map]
        end

        should "instantiate maps" do
          @maps = Patch::Node::Map.all_from_spec(@map_spec)
          assert_not_nil @maps
          assert_not_empty @maps
          assert_equal @map_spec.size, @maps.size
          assert @maps.first.kind_of?(Patch::Node::Map)
        end

      end

      context "#enable" do

        setup do
          @patches_path = File.join(__dir__, "config/patches.yml")
          @patches = Patch::Patch.all_from_spec(@patches_path)
          @nodes = Patch::Node.all_from_spec(@nodes_path)
          @maps = @patches.first.maps
        end

        should "map nodes together" do
          Patch::IO::MIDI::Input.any_instance.expects(:listen).once
          Patch::IO::OSC::Server.any_instance.expects(:listen).once
          Patch::IO::Websocket.any_instance.expects(:listen).once
          assert @maps.first.enable(@nodes)
        end
        
      end
      
    end

  end

end
