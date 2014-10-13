require "helper"

class Patch::ActionTest < Test::Unit::TestCase

  context "Action" do

    setup do
      @patches_path = File.join(__dir__,"config/patches.yml")
    end

    context "#initialize" do

      context "from files" do

        setup do
          @patches_file = File.new(@patches_path)
          @patches = Patch::Patch.all_from_spec(@patches_file)
        end

        should "populate" do
          assert_not_nil @patches
          assert_not_empty @patches
          assert_not_nil @patches.first.actions
          assert_not_nil @patches.first.actions.spec
           assert @patches.first.actions.spec.kind_of?(Array)
        end

      end

      context "from strings" do

        setup do
          @patches = Patch::Patch.all_from_spec(@patches_path)
        end

        should "populate" do
          assert_not_nil @patches
          assert_not_empty @patches
          assert_not_nil @patches.first.actions
          assert_not_nil @patches.first.actions.spec
          assert @patches.first.actions.spec.kind_of?(Array)
        end

      end

      context "from hashes" do

        setup do
          @patches_hash = {
            :test_patch => {
              :action => [
                { 
                  :name=>"Zoom", 
                  :midi=> {
                    :channel=>0, 
                    :type=>"ControlChange", 
                    :scale=>0.1..5.0
                  }, 
                  :osc => {
                    :address=>"/1/rotaryA", 
                    :scale=> { 
                      :from=>0..1, 
                      :to=>0.1..5.0
                    }
                  }
                }
              ]
            }
          }
          @patches = Patch::Patch.all_from_spec(@patches_hash)
        end

        should "populate" do
          assert_not_nil @patches
          assert_not_empty @patches
          assert_not_nil @patches.first.actions
          assert_not_nil @patches.first.actions.spec
          assert @patches.first.actions.spec.kind_of?(Array)
        end
      end

    end

    context "#by_type" do

      setup do
        @patches = Patch::Patch.all_from_spec(@patches_path)
        @patch = @patches.first
        @actions = @patch.actions
      end

      context "midi" do

        should "be populated" do
          assert_not_nil @actions.find_all_by_type(:midi)
          assert_not_empty @actions.find_all_by_type(:midi)
          assert_not_nil @actions.find_all_by_type(:midi)
          assert_not_nil @actions.find_all_by_type(:midi).first[:midi][:channel]
        end
      end

      context "osc" do

        should "be populated" do
          assert_not_nil @actions.find_all_by_type(:osc)
          assert_not_empty @actions.find_all_by_type(:osc)
          assert_not_nil @actions.find_all_by_type(:osc)
          assert_not_nil @actions.find_all_by_type(:osc).first[:osc][:address]
        end

      end

    end

  end

end

