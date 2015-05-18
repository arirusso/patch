require "helper"

class Patch::Node::ContainerTest < Minitest::Test

  context "Container" do

    setup do
      @nodes_hash = {
        :nodes => [
          {
            :id => 1,
            :type => "websocket",
            :host => "localhost",
            :port => 9006
          },
          {
            :id => 2,
            :type => "midi",
            :direction => "input",
            :name => "Apple Inc. IAC Driver"
          },
          {
            :id => 3,
            :type => "osc",
            :server => {
              :port => 8000
            },
            :client => {
              :host => "192.168.1.118",
              :port => 9000
            }
          }
        ]
      }.freeze
      @nodes = Patch::Config.to_nodes(@nodes_hash)
    end

    context "#find_all_by_type" do

      should "return osc nodes" do
        nodes = @nodes.find_all_by_type(:osc)
        refute_nil nodes
        refute_empty nodes
        assert nodes.all? { |node| node.class.name.match(/\APatch\:\:IO\:\:OSC/) }
      end

      should "return midi nodes" do
        nodes = @nodes.find_all_by_type(:midi)
        refute_nil nodes
        refute_empty nodes
        assert nodes.all? { |node| node.class.name.match(/\APatch\:\:IO\:\:MIDI/)  }
      end

      should "return websocket nodes" do
        nodes = @nodes.find_all_by_type(:websocket)
        refute_nil nodes
        refute_empty nodes
        assert nodes.all? { |node| node.class.name.match(/\APatch\:\:IO\:\:Websocket/)  }
      end

      should "not return non existant nodes" do
        nodes = @nodes.find_all_by_type(:http)
        refute_nil nodes
        assert_empty nodes
      end

    end

    context "#enable" do

      setup do
        @node_classes = [Patch::IO::MIDI::Input, Patch::IO::OSC::Server, Patch::IO::Websocket::Node]
        @node_classes.each { |c| c.any_instance.expects(:start).once }
      end

      teardown do
        @node_classes.each { |c| c.any_instance.unstub(:start) }
      end

      should "enable nodes" do
        assert @nodes.enable
      end

    end

    context "#find_by_id" do

      should "return node with id" do
        node = @nodes.find_by_id(2)
        refute_nil node
        refute_nil node.id
        assert_equal 2, node.id
      end

      should "return nil if not found" do
        node = @nodes.find_by_id(99)
        assert_nil node
      end

    end

  end

end
