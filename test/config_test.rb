require "helper"

class Patch::ConfigTest < Test::Unit::TestCase

  context "Config" do

    setup do
      @io = File.join(__dir__,"config/io.yml")
    end

    context "#initialize" do

      context "from files" do

        setup do
          @io_file = File.new(@io)
          @config = Patch::Config.new(@io)
        end

        should "populate" do
          assert_not_nil @config.io
          assert_not_empty @config.io
          assert @config.io.kind_of?(Hash)
        end

      end

      context "from strings" do

        setup do
          @config = Patch::Config.new(@io)
        end

        should "populate" do
          assert_not_nil @config.io
          assert_not_empty @config.io
          assert @config.io.kind_of?(Hash)
        end

      end

      context "from hashes" do

        setup do
          @io_hash = {
            :output=> {
              :type=>"websocket",
              :host=>"localhost", 
              :port=>9006
            }
          }
          @config = Patch::Config.new(@io_hash)
        end

        should "populate" do
          assert_not_nil @config.io
          assert_not_empty @config.io
          assert @config.io.kind_of?(Hash)
        end
      end

    end

    context "#nodes?" do

      context "osc" do
        should "be true" do
          @config = Patch::Config.new(@io)
          assert @config.nodes?(:type => :osc)
        end

      end

      context "midi" do

        should "be true" do
          @config = Patch::Config.new(@io)
          assert @config.nodes?(:type => :midi)
        end
      end

    end

  end

end
