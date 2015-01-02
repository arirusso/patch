dir = File.dirname(File.expand_path(__FILE__))
$LOAD_PATH.unshift(dir + "/../lib")

require "minitest/autorun"
require "mocha/test_unit"
require "shoulda-context"

require "patch"

UDPSocket.any_instance.stubs(:connect)
EventMachine.stubs(:open_datagram_socket).returns(true)
EventMachine.stubs(:open_udp_socket).returns(true)
EventMachine.stubs(:start_server).returns(true)
EventMachine.stubs(:start_tcp_server).returns(true)

def load_test_data
  @nodes_path = File.join(__dir__,"/config/nodes.yml")
  @nodes_file = File.new(@nodes_path)
  @patches_path = File.join(__dir__,"config/patches.yml")
  @patches_file = File.new(@patches_path)
end
