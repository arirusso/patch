require "helper"

class Patch::ActionTest < Test::Unit::TestCase

  context "Action" do

    setup do
      @action_path = File.join(__dir__,"config/action.yml")
    end

    context "#initialize" do

      context "from files" do

        setup do
          @action_file = File.new(@action_path)
          @action = Patch::Action.new(@action_file)
        end

        should "populate" do
          assert_not_nil @action.spec
          assert_not_empty @action.spec
          assert @action.spec.kind_of?(Hash)
        end

      end

      context "from strings" do

        setup do
          @action = Patch::Action.new(@action_path)
        end

        should "populate" do
          assert_not_nil @action.spec
          assert_not_empty @action.spec
          assert @action.spec.kind_of?(Hash)
        end

      end

      context "from hashes" do

        setup do
          @action_hash = {
            :controls => [
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
          @action = Patch::Action.new(@action_hash)
        end

        should "populate" do
          assert_not_nil @action.spec
          assert_not_empty @action.spec
          assert @action.spec.kind_of?(Hash)
        end
      end

    end

    context "#by_type" do

      setup do
        @action = Patch::Action.new(@action_path)
      end

      context "midi" do

        should "be populated" do
          assert_not_nil @action.find_all_by_type(:midi)
          assert_not_empty @action.find_all_by_type(:midi)
          assert_not_nil @action.find_all_by_type(:midi)[:test_patch]
          assert_not_nil @action.find_all_by_type(:midi)[:test_patch].first[:midi][:channel]
        end
      end

      context "osc" do

        should "be populated" do
          assert_not_nil @action.find_all_by_type(:osc)
          assert_not_empty @action.find_all_by_type(:osc)
          assert_not_nil @action.find_all_by_type(:osc)[:test_patch]
          assert_not_nil @action.find_all_by_type(:osc)[:test_patch].first[:osc][:address]
        end

      end

    end

  end

end

