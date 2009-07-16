require 'test_helper'

class TimeEntriesControllerTest < ActionController::TestCase
        
  context "User logged in: " do
    
    setup do
      login_as :bob
      @date = Date.new(2009, 6, 22) # monday in week 26, 2009
      Date.stubs(:today).returns(@date)
    end
             
    context "GET to :index with no date param" do
            
      setup { get :index }
      
      should_respond_with :success
      should_not_set_the_flash
      should_assign_to :date, :activities, :time_entries, :activity_options
      should_render_template :index
                
    end
    
    context "GET to :index with date from previous week" do
      
      setup { get :index, :date => @date.-(7).to_s }
      
      should_respond_with :success
      should_not_set_the_flash
      should_assign_to :activities, :time_entries, :activity_options
      should_render_template :index
      
      should "assign date from previous week" do
        date = assigns(:date)
        assert_equal(25, date.cweek)
      end
      
    end
    
    context "GET to :index with date from next week" do
      
      setup { get :index, :date => @date.+(7).to_s }
      
      should_respond_with :success
      should_not_set_the_flash
      should_assign_to :activities, :time_entries, :activity_options
      should_render_template :index
      
      should "assign date from next week" do
        date = assigns(:date)
        assert_equal(27, date.cweek)
      end
      
    end
    
    context "POST to :create_multiple" do
      
      setup { post :create_multiple, :date => @date.to_s, :activity => {:activity_id => activities(:timeflux_development).id} }
      
      should_render_template :edit_multiple
      should_not_set_the_flash
      should_assign_to :date, :time_entries
      should_change "TimeEntry.count", :by => 7
      
      should "create 7 time entries for given activity and week" do
        time_entries = assigns(:time_entries)
        time_entries.each { |te| assert_equal(26, te.date.cweek) }
        activity_id = activities(:timeflux_development).id
        time_entries.each { |te| assert_equal(activity_id, te.activity.id) }       
      end
            
    end
    
    context "POST to :edit_multiple" do
      
      setup { post :edit_multiple, :ids => [
        time_entries(:bob_timeflux_development_26_monday).id, 
        time_entries(:bob_timeflux_development_26_tuesday).id, 
        time_entries(:bob_timeflux_development_26_wednesday).id, 
        time_entries(:bob_timeflux_development_26_thursday).id, 
        time_entries(:bob_timeflux_development_26_friday).id, 
        time_entries(:bob_timeflux_development_26_saturday).id, 
        time_entries(:bob_timeflux_development_26_sunday).id
        ], :date => @date.to_s }
      
      should_respond_with :success
      should_not_set_the_flash
      should_assign_to :date, :time_entries
      should_render_template :edit_multiple
      
      should "find 7 user time entries for given activity and week" do
        time_entries = assigns(:time_entries)
        assert_equal(7, time_entries.size)
        time_entries.each { |te| assert_equal(26, te.date.cweek) }
        activity_id = activities(:timeflux_development).id
        time_entries.each { |te| assert_equal(activity_id, te.activity.id) }       
      end
            
    end
    
    context "successful PUT to :update_multiple" do
      
      setup do        
        put :update_multiple, {"date"=>"2009-06-22", 
          "time_entry"=>{
          time_entries(:bob_timeflux_development_26_monday).id    =>{"date"=>"2009-06-22", "notes"=>"Foobar", "hours"=>"5"}, 
          time_entries(:bob_timeflux_development_26_tuesday).id   =>{"date"=>"2009-06-23", "notes"=>"Foobar", "hours"=>"5"}, 
          time_entries(:bob_timeflux_development_26_wednesday).id =>{"date"=>"2009-06-24", "notes"=>"Foobar", "hours"=>"5"}, 
          time_entries(:bob_timeflux_development_26_thursday).id  =>{"date"=>"2009-06-25", "notes"=>"Foobar", "hours"=>"5"}, 
          time_entries(:bob_timeflux_development_26_friday).id    =>{"date"=>"2009-06-26", "notes"=>"Foobar", "hours"=>"5"}, 
          time_entries(:bob_timeflux_development_26_saturday).id  =>{"date"=>"2009-06-27", "notes"=>"Foobar", "hours"=>"5"}, 
          time_entries(:bob_timeflux_development_26_sunday).id    =>{"date"=>"2009-06-28", "notes"=>"Foobar", "hours"=>"5"}}}       
      end
                  
      should_respond_with :redirect
      should_set_the_flash_to("Time entries successfully updated")
      should_redirect_to("Selected weeks time entries") { time_entries_url(:date => @date) }
    
      # All time entry fixtures should have 7.5 hours and no notes before update
      should "update hours and notes for changed timed entries" do
        activity_id = activities(:timeflux_development).id 
        time_entries = users(:bob).time_entries.for_activity(activity_id).between(@date, @date.+(6))
        time_entries.each do |te|
          assert_equal(5, te.hours)
          assert_equal("Foobar", te.notes)
        end
      end
      
     end
      
    context "unsuccessful PUT to :update_multiple" do
      
      setup do
        @time_entry = TimeEntry.find_by_id(time_entries(:bob_timeflux_development_24_monday).id)
        @time_entry.stubs(:update_attributes!).with(any_parameters).returns(false)
        TimeEntry.stubs(:find_by_id).with(any_parameters).raises(StandardError)
        put :update_multiple, {"date"=>"2009-06-08", 
          "time_entry"=>{
          time_entries(:bob_timeflux_development_24_monday).id => {"date"=>"2009-06-08", "notes"=>"Foobar", "hours"=>"5"}}}
      end
        
      should_assign_to :date, :time_entries
      should_render_template :edit_multiple
      
      should "set an error message in flash" do
        assert_not_nil flash[:error]
      end 
                  
    end
    
    context "PUT to :update_multiple for locked time entries" do
      
      setup do
        put :update_multiple, {"date"=>"2009-06-08", 
          "time_entry"=>{
          time_entries(:bob_timeflux_development_24_monday).id    =>{"date"=>"2009-06-08", "notes"=>"Foobar", "hours"=>"5"}, 
          time_entries(:bob_timeflux_development_24_tuesday).id   =>{"date"=>"2009-06-09", "notes"=>"Foobar", "hours"=>"5"}, 
          time_entries(:bob_timeflux_development_24_wednesday).id =>{"date"=>"2009-06-10", "notes"=>"Foobar", "hours"=>"5"}, 
          time_entries(:bob_timeflux_development_24_thursday).id  =>{"date"=>"2009-06-11", "notes"=>"Foobar", "hours"=>"5"}, 
          time_entries(:bob_timeflux_development_24_friday).id    =>{"date"=>"2009-06-12", "notes"=>"Foobar", "hours"=>"5"}, 
          time_entries(:bob_timeflux_development_24_saturday).id  =>{"date"=>"2009-06-13", "notes"=>"Foobar", "hours"=>"5"}, 
          time_entries(:bob_timeflux_development_24_sunday).id    =>{"date"=>"2009-06-14", "notes"=>"Foobar", "hours"=>"5"}}}
      end
        
      should_assign_to :date, :time_entries
      should_render_template :edit_multiple
      
      should "not save updates to locked entries" do
        date = Date.new(2009, 6, 8)
        time_entries = users(:bob).time_entries.for_activity(activities(:timeflux_development).id).between(date, date.+(6))
        time_entries.each do |te| 
          assert_equal(7.5, te.hours)
          assert_nil(te.notes)
        end
      end
                  
    end
    
    context "POST to :destroy_multiple" do
      
      setup do
        @time_entries_before_delete = TimeEntry.count 
        post :destroy_multiple, { :ids => [
          time_entries(:bob_timeflux_development_26_monday).id, 
          time_entries(:bob_timeflux_development_26_tuesday).id, 
          time_entries(:bob_timeflux_development_26_wednesday).id, 
          time_entries(:bob_timeflux_development_26_thursday).id, 
          time_entries(:bob_timeflux_development_26_friday).id, 
          time_entries(:bob_timeflux_development_26_saturday).id, 
          time_entries(:bob_timeflux_development_26_sunday).id
          ], :date => @date.to_s } 
      end
                 
      should_respond_with :redirect
      should_redirect_to("Selected weeks time entries") { time_entries_url(:date => @date) }
      should_change "TimeEntry.count", :by => -7
      
    end
        
  end
  
  context "User not logged in: " do
    
    context "GET to :index" do            
      setup { get :index }            
      should_redirect_to("Login page") { "/user_sessions/new" }          
    end
    
    context "GET to :previous (Previous Week link)" do      
      setup { get :previous }      
      should_redirect_to("Login page") { "/user_sessions/new" }           
    end
    
    context "GET to :next (Next Week link)" do      
      setup { get :next }      
      should_redirect_to("Login page") { "/user_sessions/new" }           
    end
    
    context "GET to :new" do      
      setup { get :new }      
      should_redirect_to("Login page") { "/user_sessions/new" }           
    end
    
    context "GET to :edit" do      
      setup { get :edit }      
      should_redirect_to("Login page") { "/user_sessions/new" }                  
    end
    
    context "successful POST to :update" do      
      setup { put :update }              
      should_redirect_to("Login page") { "/user_sessions/new" }      
     end
      
    context "unsuccessful POST to :update" do      
      setup { put :update }      
      should_redirect_to("Login page") { "/user_sessions/new" }                          
    end
    
    context "POST to :update for locked time entries" do      
      setup { put :update }      
      should_redirect_to("Login page") { "/user_sessions/new" }                  
    end
    
    context "DELETE to :destroy" do      
      setup { delete :destroy }      
      should_redirect_to("Login page") { "/user_sessions/new" }      
    end
    
  end 
  
end