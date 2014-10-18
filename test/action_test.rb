require "helper"

class Patch::ActionTest < Test::Unit::TestCase

  context "Action" do

    context "Container" do

      setup do
        @patches_path = File.join(__dir__,"config/patches.yml")
      end

      context "#empty?" do

        context "from files" do

          setup do
            @patches_file = File.new(@patches_path)
            @patches = Patch::Config.to_patches(@patches_file)
          end

          should "populate" do
            assert_not_nil @patches
            assert_not_empty @patches
          end

          should "store the actions" do
            assert_not_nil @patches.first.actions
            assert_not_empty @patches.first.actions
            assert_equal Hash, @patches.first.actions.first.class
          end

          should "not be empty" do
            refute @patches.first.actions.empty?
          end

        end

        context "from strings" do

          setup do
            @patches = Patch::Config.to_patches(@patches_path)
          end

          should "populate" do
            assert_not_nil @patches
            assert_not_empty @patches
            assert_not_nil @patches.first.actions
          end

          should "store the actions" do
            assert_not_nil @patches.first.actions
            assert_not_empty @patches.first.actions
            assert_equal Hash, @patches.first.actions.first.class
          end

          should "not be empty" do
            refute @patches.first.actions.empty?
          end

        end

        context "from hashes" do

          setup do
            @patches_hash = {
              :patches => {
                :test_patch => {
                  :node_map => { [1,2] => 3 },
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
            }
            @patches = Patch::Config.to_patches(@patches_hash)
          end

          should "populate" do
            assert_not_nil @patches
            assert_not_empty @patches
            assert_not_nil @patches.first.actions
          end

          should "store the actions" do
            assert_not_nil @patches.first.actions
            assert_not_empty @patches.first.actions
            assert_equal Hash, @patches.first.actions.first.class
          end

          should "not be empty" do
            refute @patches.first.actions.empty?
          end

        end

      end

      context "#index" do

        setup do
          @patches_file = File.new(@patches_path)
          @patches = Patch::Config.to_patches(@patches_file)
        end

        should "populate" do
          assert_not_nil @patches
          assert_not_empty @patches
          assert_not_nil @patches.first.actions
        end

        should "not be empty" do
          refute @patches.first.actions.empty?
        end

        should "return an index" do
          action = @patches.first.actions.sample
          assert_not_nil action

          index = @patches.first.actions.index(action)

          assert_not_nil index
          assert index.kind_of?(Fixnum)
          assert_equal @patches.first.actions.index(action), index
        end

      end

      context "#find_all_by_type" do

        setup do
          @patches = Patch::Config.to_patches(@patches_path)
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
end
