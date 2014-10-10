require "helper"

class Patch::MessageTest < Test::Unit::TestCase

  include Patch

  context "Message" do

    setup do
      @message = Message.new
    end

    context "#new_timestamp" do

      should "be js int time format" do
        result = @message.timestamp
        assert_not_nil result
        assert_equal Fixnum, result.class
        assert result.to_s.size > Time.new.to_i.to_s.size
        assert_equal (result / 1000).to_s.size, Time.new.to_i.to_s.size
      end

    end

  end

end
