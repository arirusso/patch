require "helper"

class Patch::IOTest < Test::Unit::TestCase

  context "IO" do

    setup do
      @nodes_path = File.join(__dir__,"config/nodes.yml")
    end

    context "Module" do

      context ".all" do

        should "contain modules" do
          modules = Patch::IO::Module.all
          assert_not_nil modules
          assert_not_empty modules
          assert modules.all? { |mod| mod.kind_of?(Module) }
        end

      end

    end

  end

end
