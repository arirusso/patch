require "helper"

class Patch::MessageTest < Test::Unit::TestCase

  context "Message" do

    setup do
      @message = Patch::Message.new
    end

    context "#to_h" do

      setup do
        @message.index = 1
        @message.value = 100
        @message.patch_name = :test
      end

      should "have basic properties" do
        @result = @message.to_h
        assert_not_nil @result
        assert_not_empty @result
        assert_not_nil @result[:index]
        assert_not_nil @result[:value]
        assert_not_nil @result[:patch_name]
        assert_not_nil @result[:timestamp]
        assert_equal 1, @result[:index]
        assert_equal 100, @result[:value]
        assert_equal :test, @result[:patch_name]        
      end

      should "have properties from hash" do
        @message.send(:populate_from_properties, { :a_property => "hello!" })
        @result = @message.to_h
        assert_not_nil @result
        assert_not_nil @result[:a_property]
        assert_equal "hello!", @result[:a_property]
      end

    end

    context "#to_json" do

      setup do
        @message.index = 10
        @message.value = 200
        @message.patch_name = :test
      end

      should "have all of the message properties" do
        hash = @message.to_h
        json = @message.to_json
        hash.each do |key, value|
          assert json.include?(key.to_s)
          assert json.include?(value.to_s)
        end
      end

    end

    context "#timestamp" do
      
      should "be js int time format" do
        result = @message.timestamp
        assert_not_nil result
        assert_equal Fixnum, result.class
        assert result.to_s.size > Time.new.to_i.to_s.size
        assert_equal (result / 1000).to_s.size, Time.new.to_i.to_s.size
      end

    end

    context "#populate_from_properties" do

      setup do
        @hash = { 
          :index => 2, 
          :value => "blah", 
          :patch_name => :test, 
          :another_property => "something" 
        }
        @message.send(:populate_from_properties, @hash)
      end

      should "have properties from hash" do
        assert_not_nil @message.index
        assert_not_nil @message.value
        assert_not_nil @message.patch_name
        assert_equal 2, @message.index
        assert_equal "blah", @message.value
        assert_equal :test, @message.patch_name
      end

    end

  end

end
