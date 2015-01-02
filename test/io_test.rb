require "helper"

class Patch::IOTest < Minitest::Test

  context "IO" do

    setup do
      load_test_data
    end

    context "Module" do

      context ".all" do

        should "contain modules" do
          modules = Patch::IO::Module.all
          refute_nil modules
          refute_empty modules
          assert modules.all? { |mod| mod.kind_of?(Module) }
        end

      end

    end

  end

end
