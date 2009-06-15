require 'test_helper'

class WeekEntriesControllerTest < ActionController::TestCase
  
  context "User logged in:" do
    
    setup do 
      login_as(:bob)
      @today = Date.new(2009, 06, 15)
      Date.stubs(:today).returns(@today) 
    end
    
    context "GET to :index" do
      
      setup do
        get :index
      end
      
      should_respond_with :success
            
      should "find all week entries previously saved by the user" do
        week_entries = assigns(:week_entries)
        assert_equal(2, week_entries.size)
      end
      
      should "assign date and week number for use in view" do
        assert_equal(@today, assigns(:date))
        assert_equal(25, assigns(:week_number))
      end
      
    end
    
    context "Previous Week link" do
      
      should "assign previous weeks date and week number when clicked" do
          get :previous, :date => @today.to_s
          assert_equal(@today.-(7), assigns(:date))
          assert_equal(24, assigns(:week_number))
      end
      
      should "load previous weeks week entries when clicked" do
          get :previous, :date => @today.to_s
          week_entries = assigns(:week_entries)
          assert_equal(2, week_entries.size)
          assert_equal(24, week_entries[0].week_number)
      end
      
      should "assign next weeks date and week number when clicked" do
          get :next, :date => @today.to_s
          assert_equal(@today.+(7), assigns(:date))
          assert_equal(26, assigns(:week_number))
      end
      
      should "load next weeks week entries when clicked" do
          get :next, :date => @today.to_s
          week_entries = assigns(:week_entries)
          assert_equal(2, week_entries.size)
          assert_equal(26, week_entries[0].week_number)
      end
      
    end
        
  end
    
end