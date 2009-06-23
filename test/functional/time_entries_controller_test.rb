require 'test_helper'

class TimeEntriesControllerTest < ActionController::TestCase
    
  context "User logged in: " do
    
    setup do
      login_as :bob
      @date = Date.new(2009, 6, 22) # monday in week 26, 2009
      Date.stubs(:today).returns(@date)
      @assert_index_assigns = lambda {
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
      should_assign_to :date
      should_assign_to :user
      should_render_template :index
      
      should "assign instance variables for use in the view" do
        @assert_index_assigns.call
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
      
      should "assign instance variables for use in the view" do
        @assert_index_assigns.call
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
      
      should "assign instance variables for use in the view" do
        @assert_index_assigns.call
      end
      
    end
        
  end 
  
end