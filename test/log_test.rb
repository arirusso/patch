require "helper"

class Patch::LogTest < Test::Unit::TestCase

  context "Log" do

    setup do
      @out = Object.new
    end

    context "#exception" do

      should "display exception" do
        message = "blah blah"
        @out.expects(:puts).once
        @log = Patch::Log.new(@out)
        begin
          raise(message)
        rescue Exception => e
          @log.exception(e)
        end
      end

    end

    context "#info" do

      should "display message" do
        message = "blah blah"
        @out.expects(:puts).once
        @log = Patch::Log.new(@out)
        @log.info(message)
      end

    end

    context "#populate_level" do

      setup do
        @message = "blah blah"
        @error = "error!"
      end

      should "only output info" do
        @log = Patch::Log.new(@out, :show => :info)
        refute @log.instance_variable_get("@exception")
        assert @log.instance_variable_get("@info")
        @out.expects(:puts).once
        output = Object.new
        output.expects(:colorize).once.with(:blue)
        @log.expects(:format).once.with(@message, :type => :info).returns(output)
        @log.info(@message)
        begin
          raise(@error)
        rescue Exception => e
          @log.exception(e)
        end
      end

      should "only output exception" do
        @log = Patch::Log.new(@out, :show => :exception)
        assert @log.instance_variable_get("@exception")
        refute @log.instance_variable_get("@info")
        @out.expects(:puts).once
        output = Object.new
        output.expects(:colorize).once.with(:red)
        @log.expects(:format).once.with(@error, :type => :exception).returns(output)
        begin
          raise(@error)
        rescue Exception => e
          @log.exception(e)
        end
      end

      should "show everything" do
        @log = Patch::Log.new(@out)
        assert @log.instance_variable_get("@exception")
        assert @log.instance_variable_get("@info")
        @out.expects(:puts).twice
        output = Object.new
        output.expects(:colorize).once.with(:red)
        output.expects(:colorize).once.with(:blue)
        @log.expects(:format).once.with(@error, :type => :exception).returns(output)
        @log.expects(:format).once.with(@message, :type => :info).returns(output)
        begin
          raise(@error)
        rescue Exception => e
          @log.exception(e)
        end
      end


    end

  end

end
