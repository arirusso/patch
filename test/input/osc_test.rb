require "helper"

class ControlHub::Input::OSCTest < Test::Unit::TestCase

  include ControlHub

  context "OSC" do

    setup do
      @control = File.join(__dir__,"../config/control.yml")
      @io = File.join(__dir__,"../config/io.yml")
      @config = ControlHub::Config.new(:control => @control, :io => @io)
      @osc = ControlHub::Input::OSC.new(@config)
    end

    context "#initialize" do

      should "initialize client" do
        assert_not_nil @osc.instance_variable_get("@client")
      end

      should "initialize server" do
        assert_not_nil @osc.instance_variable_get("@server")
      end

    end

    context "#handle_message_received" do

      setup do
        @client = @osc.instance_variable_get("@client")
        @message = Object.new
        @message.stubs(:to_a).returns([0.5])
        @message.stubs(:address).returns("/1/rotaryA")
      end

      should "return hash" do
        @client.expects(:send).once.with(@message)
        @hash = @osc.send(:handle_message_received, @message)
        assert_not_nil @hash
        assert_equal Hash, @hash.class
        assert_not_nil @hash[:WebcamMesh]
        assert_not_nil @hash[:WebcamMesh][:index]
        assert_not_nil @hash[:WebcamMesh][:value]
      end

      should "yield hash" do
        @client.expects(:send).once.with(@message)
        @osc.send(:handle_message_received, @message) do |hash|
          @hash = hash
          assert_not_nil @hash
          assert_equal Hash, @hash.class
          assert_not_nil @hash[:WebcamMesh]
          assert_not_nil @hash[:WebcamMesh][:index]
          assert_not_nil @hash[:WebcamMesh][:value]
        end
      end

      should "scale value" do
        @client.expects(:send).once.with(@message)
        scale = Object.new
        scale.expects(:from).once.returns(scale)
        scale.expects(:to).once
        @hash = @osc.send(:handle_message_received, @message)
        Scale.unstub(:transform)
      end
    end

    context "#listen" do

      should "start server" do
        server = @osc.instance_variable_get("@server")
        server.expects(:run)
        @osc.listen
      end

    end

  end

end

