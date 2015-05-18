require "helper"

class Patch::IO::MIDITest < Minitest::Test

  context "MIDI" do

    context "#get_direction_class" do

      should "return input class" do
        assert_equal Patch::IO::MIDI::Input, Patch::IO::MIDI.send(:get_direction_class, "input")
        assert_equal Patch::IO::MIDI::Input, Patch::IO::MIDI.send(:get_direction_class, :input)
      end

      should "return output class" do
        assert_equal Patch::IO::MIDI::Output, Patch::IO::MIDI.send(:get_direction_class, "output")
        assert_equal Patch::IO::MIDI::Output, Patch::IO::MIDI.send(:get_direction_class, :output)
      end

      should "return nil" do
        assert_nil Patch::IO::MIDI.send(:get_direction_class, "blah")
        assert_nil Patch::IO::MIDI.send(:get_direction_class, :blah)
      end

    end

    context "#new_from_config" do

      context "input" do

        setup do
          @config = {
            :id=>2,
            :type=>"midi",
            :direction=>"input",
            :name=>"Apple Inc. IAC Driver"
          }
          @input = Patch::IO::MIDI.new_from_config(@config)
        end

        should "be input" do
          refute_nil @input
          assert_equal Patch::IO::MIDI::Input, @input.class
        end

        should "have id" do
          refute_nil @input.id
          assert_equal 2, @input.id
        end

        should "have underlying midi input" do
          refute_nil @input.device
          assert_equal @config[:name], @input.device.name
        end

        should "initialize midi listener" do
          refute_nil @input.instance_variable_get("@listener")
        end


      end

      context "output" do

        setup do
          @config = {
            :id=>3,
            :type=>"midi",
            :direction=>"output",
            :name=>"Apple Inc. IAC Driver"
          }
          @output = ::Patch::IO::MIDI.new_from_config(@config)
        end

        should "be output" do
          refute_nil @output
          assert_equal Patch::IO::MIDI::Output, @output.class
        end

        should "have id" do
          refute_nil @output.id
          assert_equal 3, @output.id
        end

        should "have underlying midi output" do
          refute_nil @output.device
          assert_equal @config[:name], @output.device.name
        end

      end

    end
  end

end
