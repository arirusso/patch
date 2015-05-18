require "helper"

class Patch::IO::ModuleTest < Minitest::Test

  context "Module" do

    context ".all" do

      should "contain modules" do
        modules = Patch::IO::Module.all
        refute_nil modules
        refute_empty modules
        assert modules.all? { |mod| mod.kind_of?(Module) }
        assert modules.all? { |mod| mod.name.match(/\APatch\:\:IO/) }
      end

    end

  end

end
