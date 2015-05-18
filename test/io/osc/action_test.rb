require "helper"

class Patch::IO::OSC::ActionTest < Minitest::Test

  context "Action" do

    setup do
      @actions = [
        {
          :name=>"Volume",
          :key=>"volume",
          :default=> {
            :scale=>0..2.0
          },
          :midi => {
            :channel=>4,
            :index=>7
          }
        },
        {
          :name=>"Z Depth",
          :key=>"zDepth",
          :default=>{
            :scale=>0..1000
          },
          :osc=>{
            :address=>"/1/faderA",
            :scale=> {
              :osc=>0..1.0
            }
          }
        }
      ]
    end

    context "#osc?" do

      should "return true for actions with osc" do
        assert Patch::IO::OSC::Action.osc?(@actions[1])
      end

      should "return false for actions without osc" do
        refute Patch::IO::OSC::Action.osc?(@actions[0])
      end

    end

    context "#osc_actions" do

      should "return only osc actions" do
        actions = Patch::IO::OSC::Action.osc_actions(@actions)
        refute_nil actions
        refute_empty actions
        assert_equal 1, actions.size
        assert_equal @actions[1], actions.first
      end

    end

    context "#find_by_address" do

      should "return action with address" do
        addy = "/1/faderA"
        action = Patch::IO::OSC::Action.find_by_address(@actions, addy)
        refute_nil action
        assert_equal addy, action[:osc][:address]
      end

      should "return nil if not found" do
        assert_nil Patch::IO::OSC::Action.find_by_address(@actions, "/1/faderZ")
      end

    end

  end
end
