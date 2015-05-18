require "helper"

class Patch::NodeTest < Minitest::Test

  context "Node" do

    should "load classes" do
      refute_nil Patch::Node::Container
      refute_nil Patch::Node::Map
    end
    
  end

end
