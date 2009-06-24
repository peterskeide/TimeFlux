require 'test_helper'
require 'date_extensions'

class TimeEntriesControllerTest < ActionController::TestCase
        
  context "User logged in: " do
    
    setup do
      login_as :bob
      @date = Date.new(2009, 6, 22) # monday in week 26, 2009
      Date.stubs(:today).returns(@date)
      @assert_activity_map_and_options_assigned = lambda {
        activities = assigns(:activities)
        assert_equal(1, activities.size)
        assert_equal(7, activities["TimeFlux"].size)
        activity_options = assigns(:activity_options)
        assert_equal(2, activity_options.size) #should include foobar and status only 
      }
    end
             
    context "GET to :index" do
            
      setup { get :index }
      
      should_respond_with :success
      should_not_set_the_flash
      should_assign_to :date, :user
      should_render_template :index
            
      should "assign activity map and options" do
        @assert_activity_map_and_options_assigned.call
      end
      
    end
    
    context "GET to :previous (Previous Week link)" do
      
      setup { get :previous, :date => @date.to_s }
      
      should_respond_with :success
      should_not_set_the_flash
      should_assign_to :user
      should_render_template :index
      
      should "assing date from previous week" do
        date = assigns(:date)
        assert_equal(25, date.cweek)
      end
      
      should "assign activity map and options" do
        @assert_activity_map_and_options_assigned.call
      end
      
    end
    
    context "GET to :next (Next Week link)" do
      
      setup { get :next, :date => @date.to_s }
      
      should_respond_with :success
      should_not_set_the_flash
      should_assign_to :user
      should_render_template :index
      
      should "assing date from previous week" do
        date = assigns(:date)
        assert_equal(27, date.cweek)
      end
      
      should "assign activity map and options" do
        @assert_activity_map_and_options_assigned.call
      end
      
    end
    
    context "GET to :new" do
      
      setup { get :new, :date => @date.to_s, :activity => {:activity_id => activities(:timeflux).id} }
      
      should_respond_with :success
      should_not_set_the_flash
      should_assign_to :user, :date, :time_entries, :activity
      should_render_template :edit
      
      should "create 7 time entries for given activity and week" do
        assert_difference("TimeEntry.count", 7) { get :new, :date => @date.to_s, :activity => {:activity_id => activities(:timeflux).id} }
        time_entries = assigns(:time_entries)
        time_entries.each { |te| assert_equal(26, te.date.cweek) }
        activity_id = activities(:timeflux).id
        time_entries.each { |te| assert_equal(activity_id, te.activity.id) }       
      end
            
    end
    
    context "GET to :edit" do
      
      setup { get :edit, :id => users(:bob).id, :date => @date.to_s, :activity_id => activities(:timeflux).id }
      
      should_respond_with :success
      should_not_set_the_flash
      should_assign_to :user, :date, :time_entries
      should_render_template :edit
      
      should "find 7 user time entries for given activity and week" do
        time_entries = assigns(:time_entries)
        assert_equal(7, time_entries.size)
        time_entries.each { |te| assert_equal(26, te.date.cweek) }
        activity_id = activities(:timeflux).id
        time_entries.each { |te| assert_equal(activity_id, te.activity.id) }       
      end
      
    end
    
    context "POST to :update" do
      
      setup { 
        put :update, {"user"=>
          {"id"=>users(:bob).id, "time_entries_attributes"=>{
            "0"=>{"date"=>"2009-06-22", "notes"=>"", "id"=>time_entries(:bob_timeflux_26_monday).id, "hours"=>"7.5"}, 
            "1"=>{"date"=>"2009-06-23", "notes"=>"", "id"=>time_entries(:bob_timeflux_26_tuesday).id, "hours"=>"7.5"}, 
            "2"=>{"date"=>"2009-06-24", "notes"=>"", "id"=>time_entries(:bob_timeflux_26_wednesday).id, "hours"=>"7.5"}, 
            "3"=>{"date"=>"2009-06-25", "notes"=>"", "id"=>time_entries(:bob_timeflux_26_thursday).id, "hours"=>"7.5"}, 
            "4"=>{"date"=>"2009-06-26", "notes"=>"", "id"=>time_entries(:bob_timeflux_26_friday).id, "hours"=>"7.5"}, 
            "5"=>{"date"=>"2009-06-27", "notes"=>"", "id"=>time_entries(:bob_timeflux_26_saturday).id, "hours"=>"7.5"},
            "6"=>{"date"=>"2009-06-28", "notes"=>"", "id"=>time_entries(:bob_timeflux_26_sunday).id, "hours"=>"7.5"}
            }}, "date"=>"2009-06-22", "id"=>users(:bob).id}         
         }
              
      should_respond_with :success
      should_not_set_the_flash
      should_redirect_to :action => "index"  
      
    end
        
  end 
  
end