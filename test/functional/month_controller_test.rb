require 'test_helper'

class MonthControllerTest < ActionController::TestCase

  setup do
    @date = Date.new(2009, 6, 22) # monday in week 26, 2009
    Date.stubs(:today).returns(@date)
  end

  context "Logged in as user Bob" do
    setup do
      login_as(:bob)
    end
    
    context "on GET to :index" do
      setup { get :index }
      should_redirect_to("Week view") { "/month/week" }
    end

    pages = [:week,:month,:summary,:listing,:update_listing,:update_week]
    pages.each do |page|  
      context "on GET to #{page}" do
        setup { get page }
        should_respond_with :success
      end
    end
  end
  
  context "As the user Bill" do
    setup {
      login_as(:bill)
      get :week
    }
    should_respond_with :success
  end

  context "Not logged in" do
    pages = [:week,:month,:listing]
    pages.each do |page|
      context "a GET to :#{page}" do
        setup { get page }
        should_redirect_to("Login page") { "/user_sessions/new" }
      end
    end
  end
end
