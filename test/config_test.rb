require "helper"

class Patch::ConfigTest < Test::Unit::TestCase

  context "Config" do

    setup do
      @control = File.join(__dir__,"config/control.yml")
      @io = File.join(__dir__,"config/io.yml")
    end

    context "#initialize" do

      context "from files" do

        setup do
          @control_file = File.new(@control)
          @io_file = File.new(@io)
          @config = Patch::Config.new(@io, :control => @control_file)
        end

        should "populate" do
          assert_not_nil @config.control
          assert_not_nil @config.io
          assert_not_empty @config.control
          assert_not_empty @config.io
          assert @config.control.kind_of?(Hash)
          assert @config.io.kind_of?(Hash)
        end

      end

      context "from strings" do

        setup do
          @config = Patch::Config.new(@io, :control => @control)
        end

        should "populate" do
          assert_not_nil @config.control
          assert_not_nil @config.io
          assert_not_empty @config.control
          assert_not_empty @config.io
          assert @config.control.kind_of?(Hash)
          assert @config.io.kind_of?(Hash)
        end

      end

      context "from hashes" do

        setup do
          @control_hash = {
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
          @io_hash = {
            :output=> {
              :type=>"websocket",
              :host=>"localhost", 
              :port=>9006
            }
          }
          @config = Patch::Config.new(@io_hash, :control => @control_hash)
        end

        should "populate" do
          assert_not_nil @config.control
          assert_not_nil @config.io
          assert_equal @control_hash, @config.control
          assert_equal @io_hash, @config.io
        end
      end

      context "from both strings and hashes" do

        setup do
          @io_hash = {
            :output=> {
              :type=>"websocket",
              :host=>"localhost", 
              :port=>9006
            }
          }
          @config = Patch::Config.new(@io_hash, :control => @control)
        end

        should "populate" do
          assert_not_nil @config.control
          assert_not_nil @config.io
          assert_not_empty @config.control
          assert_not_empty @config.io
          assert_equal @io_hash, @config.io
        end

      end

    end

    context "#nodes?" do

      context "osc" do
        should "be true" do
          @config = Patch::Config.new(@io, :control => @control)
          assert @config.nodes?(:type => :osc)
        end

      end

      context "midi" do

        should "be true" do
          @config = Patch::Config.new(@io, :control => @control)
          assert @config.nodes?(:type => :midi)
        end
      end

    end

    context "#control?" do

      should "be true" do
        @config = Patch::Config.new(@io, :control => @control)
        assert @config.control?
      end

    end

    context "#controls" do

      context "midi" do

        should "be populated" do
          @config = Patch::Config.new(@io, :control => @control)
          assert_not_nil @config.controls(:midi)
          assert_not_empty @config.controls(:midi)
          assert_not_nil @config.controls(:midi)[:test_namespace]
          assert_not_nil @config.controls(:midi)[:test_namespace].first[:midi][:channel]
        end
      end

      context "osc" do

        should "be populated" do
          @config = Patch::Config.new(@io, :control => @control)
          assert_not_nil @config.controls(:osc)
          assert_not_empty @config.controls(:osc)
          assert_not_nil @config.controls(:osc)[:test_namespace]
          assert_not_nil @config.controls(:osc)[:test_namespace].first[:osc][:address]
        end

      end

    end

  end

end
