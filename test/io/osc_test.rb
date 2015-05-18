require "helper"

class Patch::IO::OSCTest < Minitest::Test

  context "OSC" do

    context "#new_from_config" do

      context "server" do

        setup do
          @config = {
            :id => 3,
            :type => "osc",
            :server => {
              :port => 8000
            }
          }
          @server = Patch::IO::OSC.new_from_config(@config)
        end

        should "be server" do
          refute_nil @server
          assert Patch::IO::OSC::Server, @server.class
        end

        should "have id" do
          refute_nil @server.id
          assert_equal 3, @server.id
        end

        should "not initialize client" do
          assert_nil @server.instance_variable_get("@client")
        end

        should "initialize server" do
          refute_nil @server.instance_variable_get("@server")
        end

      end

      context "server with echo" do

        setup do
          @config = {
            :id => 4,
            :type => "osc",
            :client => {
              :host => "192.168.1.118",
              :port => 9000
            },
            :server => {
              :port => 8000
            }
          }
          @server = Patch::IO::OSC.new_from_config(@config)
        end

        should "be server" do
          refute_nil @server
          assert Patch::IO::OSC::Server, @server.class
        end

        should "have id" do
          refute_nil @server.id
          assert_equal 4, @server.id
        end

        should "initialize echo client" do
          refute_nil @server.instance_variable_get("@client")
        end

        should "initialize server" do
          refute_nil @server.instance_variable_get("@server")
        end

      end

      context "client" do

        setup do
          @config = {
            :id => 5,
            :type => "osc",
            :client => {
              :host => "192.168.1.118",
              :port => 9000
            }
          }
          @client = ::Patch::IO::OSC.new_from_config(@config)
        end

        should "be client" do
          refute_nil @client
          assert Patch::IO::OSC::Client, @client.class
        end

        should "have id" do
          refute_nil @client.id
          assert_equal 5, @client.id
        end

        should "initialize underlying client" do
          refute_nil @client.instance_variable_get("@client")
        end

      end

    end
  end
end
