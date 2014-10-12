require "helper"

class Patch::NodeTest < Test::Unit::TestCase

  context "Node" do

    setup do
      @nodes_path = File.join(__dir__,"config/nodes.yml")
    end

    context ".new_from_spec" do

      context "from files" do

        setup do
          @nodes_file = File.new(@nodes_path)
          @nodes = Patch::Node.all_from_spec(@nodes_file)
        end

        should "populate" do
          assert_not_nil @nodes
          assert_not_empty @nodes
        end

      end

      context "from strings" do

        setup do
          @nodes = Patch::Node.all_from_spec(@nodes_path)
        end

        should "populate" do
          assert_not_nil @nodes
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
          assert_not_empty @nodes
        end
      end

    end

    context "#any?" do

      context "osc" do
        should "be true" do
          @nodes = Patch::Node.all_from_spec(@nodes_path)
          assert_not_empty @nodes.find_all_by_type(:osc)
        end

      end

      context "midi" do

        should "be true" do
          @nodes = Patch::Node.all_from_spec(@nodes_path)
          assert_not_empty @nodes.find_all_by_type(:midi)
        end
      end

    end

  end

end
