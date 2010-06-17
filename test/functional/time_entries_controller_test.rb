require File.dirname(__FILE__) + '/../test_helper'

class TimeEntriesControllerTest < ActionController::TestCase
        
  context "User logged in: " do
    
    setup do
      login_as :bob
      @date = Date.new(2009, 6, 22) # monday in week 26, 2009
      Date.stubs(:today).returns(@date)
    end
  
  end
   
end