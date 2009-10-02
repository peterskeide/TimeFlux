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
      #assert_equal "warn", @user.status_for_month(Date.today, 10, 999)
      #assert_equal "warn", @user.status_for_month(Date.today, 99, 75)
      #assert_equal "error", @user.status_for_month(Date.today, 99, 999)
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
  
  context "With an instance of Fred" do
    
    setup do
      Configuration.instance.update_attribute(:activity_id, activities(:vacation).id)
      @user = User.create(:firstname => "Fred", :lastname => "Olsen", :login => "fredo", :email => "fredo@timeflux.com", 
                          :admin => false, :password => "secret", :password_confirmation => "secret")
    end
  
    context "the update_vacation! method" do
    
      setup do        
        @vacation_dates = ["2009-09-01",  "2009-09-02", "2009-09-03"]
        @start_of_month = Date.new(2009, 9, 1)
        @end_of_month = @start_of_month.end_of_month
        @user.update_vacation!(@start_of_month, @end_of_month, @vacation_dates)           
      end
    
      should "create new time_entries for the vacation activity for the month of the given date" do      
        assert_equal(3, @user.time_entries.between(@start_of_month, @end_of_month).for_activity(activities(:vacation).id).count)
      end
    
      should "remove time_entries for dates that are not included in the vacation_dates argument" do
        @user.update_vacation!(@start_of_month, @end_of_month, ["2009-09-03"])      
        assert_equal(1, @user.time_entries.between(@start_of_month, @end_of_month).for_activity(activities(:vacation).id).count)
      end
      
      should "not create duplicates for previously created vacation dates" do
        @user.update_vacation!(@start_of_month, @end_of_month, @vacation_dates)     
        assert_equal(3, @user.time_entries.between(@start_of_month, @end_of_month).for_activity(activities(:vacation).id).count)
      end
        
    end
  
    context "the current_activities method" do
    
      setup do
        p = Project.create(:name => "TestProject")
        hour_type = HourType.create!(:name => "TestHourType")
        p.users << @user
        @a1 = Activity.create(:name => "TestOne", :project_id => p.id)
        @a2 = Activity.create(:name => "TestTwo", :project_id => p.id)
        @a3 = Activity.create(:name => "TestThree", :project_id => p.id)
        @date = Date.today
        @user.time_entries.create!(:hours => 7.5, :hour_type_id => hour_type.id, :notes => "", :activity_id => @a1.id, :date => @date.-(5).to_s)
        @user.time_entries.create!(:hours => 7.5, :hour_type_id => hour_type.id, :notes => "", :activity_id => @a1.id, :date => @date.-(4).to_s)
        @user.time_entries.create!(:hours => 7.5, :hour_type_id => hour_type.id, :notes => "", :activity_id => @a1.id, :date => @date.-(3).to_s)
        @user.time_entries.create!(:hours => 7.5, :hour_type_id => hour_type.id, :notes => "", :activity_id => @a2.id, :date => @date.-(2).to_s)
        @user.time_entries.create!(:hours => 7.5, :hour_type_id => hour_type.id, :notes => "", :activity_id => @a2.id, :date => @date.-(1).to_s)
        @user.time_entries.create!(:hours => 7.5, :hour_type_id => hour_type.id, :notes => "", :activity_id => @a3.id, :date => @date.to_s)
      end
    
      should "return an array of unique activities" do
         assert !@user.current_activities(@date).uniq! # uniq! returns nil if no duplicated are removed    
      end
    
      should "sort activities by most used in the previous week" do
        activities = @user.current_activities(@date)
        assert_equal(@a1.id, activities.shift.id)
        assert_equal(@a2.id, activities.shift.id)
        assert_equal(@a3.id, activities.shift.id)
      end
    end
  
  end
  
end