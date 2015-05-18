require "helper"

class Patch::IO::MIDI::ActionTest < Minitest::Test

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
          },
          :osc=> {
            :address=>"/faderM",
            :scale=> {
              :osc=>0..1.0
            }
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

    context "#midi_actions" do

      should "return only midi actions" do
        actions = Patch::IO::MIDI::Action.midi_actions(@actions)
        refute_nil actions
        refute_empty actions
        assert_equal 1, actions.size
        assert_equal @actions[0], actions.first
      end

    end

    context "#midi?" do

      should "return true for actions with midi" do
        assert Patch::IO::MIDI::Action.midi?(@actions[0])
      end

      should "return false for actions without midi" do
        refute Patch::IO::MIDI::Action.midi?(@actions[1])
      end

    end

    context "#find_by_index" do

      should "return action if it has midi" do
        action = Patch::IO::MIDI::Action.find_by_index(@actions, 7)
        refute_nil action
      end

      should "not return action if it doesn't have midi" do
        action = Patch::IO::MIDI::Action.find_by_index(@actions, 1)
        assert_nil action
      end

    end

  end

end
