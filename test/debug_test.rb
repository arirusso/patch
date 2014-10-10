require "helper"

class Patch::DebugTest < Test::Unit::TestCase

  context "Debug" do

    setup do
      @control = File.join(__dir__,"config/control.yml")
      @io = File.join(__dir__,"config/io.yml")
      @control_file = File.new(@control)
      @io_file = File.new(@io)
      @config = Patch::Config.new(:control => @control_file, :io => @io_file)
      @out = Object.new
    end

    context "#exception" do

      should "display exception" do
        message = "blah blah"
        @out.expects(:puts).once
        @debug = Patch::Debug.new(@out)
        begin
          raise(message)
        rescue Exception => e
          @debug.exception(e)
        end
      end

    end

    context "#info" do

      should "display message" do
        message = "blah blah"
        @out.expects(:puts).once
        @debug = Patch::Debug.new(@out)
        @debug.info(message)
      end

    end

    context "#populate_level" do

      setup do
        @message = "blah blah"
        @error = "error!"
      end

      should "only output info" do
        @debug = Patch::Debug.new(@out, :show => :info)
        refute @debug.instance_variable_get("@exception")
        assert @debug.instance_variable_get("@info")
        @out.expects(:puts).once
        output = Object.new
        output.expects(:colorize).once.with(:blue)
        @debug.expects(:format).once.with(@message).returns(output)
        @debug.info(@message)
        begin
          raise(@error)
        rescue Exception => e
          @debug.exception(e)
        end
      end

      should "only output exception" do
        @debug = Patch::Debug.new(@out, :show => :exception)
        assert @debug.instance_variable_get("@exception")
        refute @debug.instance_variable_get("@info")
        @out.expects(:puts).once
        output = Object.new
        output.expects(:colorize).once.with(:red)
        @debug.expects(:format).once.with(@error).returns(output)
        begin
          raise(@error)
        rescue Exception => e
          @debug.exception(e)
        end
      end

      should "show everything" do
        @debug = Patch::Debug.new(@out)
        assert @debug.instance_variable_get("@exception")
        assert @debug.instance_variable_get("@info")
        @out.expects(:puts).twice
        output = Object.new
        output.expects(:colorize).once.with(:red)
        output.expects(:colorize).once.with(:blue)
        @debug.expects(:format).once.with(@error).returns(output)
        @debug.expects(:format).once.with(@message).returns(output)
        begin
          raise(@error)
        rescue Exception => e
          @debug.exception(e)
        end
      end


    end

  end

end
