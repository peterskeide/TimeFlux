
$:.unshift File.join(File.dirname(__FILE__),'..','lib')

require 'test/unit'
require 'user'
require 'test_helper'

class UserTest < ActiveSupport::TestCase
  
  context "A User instance" do

    should "return its full name" do
      assert_equal 'Bob Foobar', users(:bob).fullname
    end

    should "not save without a username" do
      user = User.new
      assert !user.save
    end

  end
end

