require 'test_helper'

class UserTest < ActiveSupport::TestCase

  setup do
    @date = Date.new(2009, 6, 1) # first of june, 2009
    Date.stubs(:today).returns(@date)
  end

  context "A User instance" do

    setup { @user = users(:bob) }

    should "return its full name" do
      assert_equal 'Bob Foobar', @user.fullname
    end

    should "not save without a username" do
      @user.login = nil
      assert !@user.save
    end

    should "tell if the user has reported enough hours for a month" do
      #TODO (test for locking) assert_equal "ok", @user.status_for_month(Date.today, 10, 75)
      assert_equal "warn", @user.status_for_month(Date.today, 10, 999)
      assert_equal "warn", @user.status_for_month(Date.today, 99, 75)
      assert_equal "error", @user.status_for_month(Date.today, 99, 999)
    end
    
    should "not be destroyed if it is the last admin" do
      assert_equal 1, User.find_all_by_admin(true).size # Guard assert
      assert !@user.destroy
      assert_equal 'Cannot not remove last admin user', @user.errors.entries[0][1]
    end
    
    should "not be destroyed if it has registered time entries" do
      users(:bill).update_attribute(:admin, true) # Create 2nd admin to bypass admin validation   
      assert @user.time_entries # Guard assert
      assert !@user.destroy
      assert_equal 'User has time entries', @user.errors.entries[0][1]
    end
    
    should "not be destroyed if it is assigned to projects" do
      users(:bill).update_attribute(:admin, true) # Create 2nd admin to bypass admin validation
      @user.time_entries.clear # Remove time entries to bypass time entry validation
      @user.projects << Project.first
      assert !@user.destroy
      assert_equal 'User is assigned to one or more projects', @user.errors.entries[0][1]
    end

  end
  
end