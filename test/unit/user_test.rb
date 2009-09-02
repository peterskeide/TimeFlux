require 'test_helper'

class UserTest < ActiveSupport::TestCase

  setup do
    @date = Date.new(2009, 6, 1) # first of june, 2009
    Date.stubs(:today).returns(@date)
  end

  context "A User instance" do

    should "return its full name" do
      assert_equal 'Bob Foobar', users(:bob).fullname
    end

    should "not save without a username" do
      user = User.new
      assert !user.save
    end

    should "tell if the user has reported enough hours for a month" do
      assert_equal "ok", users(:bob).status_for_month(Date.today, 10, 75)
      assert_equal "warn", users(:bob).status_for_month(Date.today, 10, 999)
      assert_equal "warn", users(:bob).status_for_month(Date.today, 99, 75)
      assert_equal "error", users(:bob).status_for_month(Date.today, 99, 999)
    end

  end
  
end