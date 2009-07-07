require 'test_helper'

class MonthControllerTest < ActionController::TestCase
  
  context "Logged in as user Bill" do
    setup do
      login_as(:bill)
    end
    
    context "on GET to :index" do
      setup { get :index }
      should_redirect_to("Week view") { "/month/week" }
    end

    pages = [:week,:month,:summary,:listing]
    pages.each do |page|  
      context "on GET to #{page}" do
        setup { get page }
        should_respond_with :success
      end
    end
  end
  
  context "As the user Bill calling GET to :index" do
    setup {
      login_as(:bill)
      get :index
    }
    should_redirect_to("Week view") { "/month/week" }
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
