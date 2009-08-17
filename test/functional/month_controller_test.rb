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
      should_redirect_to("Calender view") { "/month/calender" }
    end

    pages = [:calender,:month,:listing,:shared]
    pages.each do |page|  
      context "on GET to #{page}" do
        setup { get page }
        should_respond_with :success
      end
    end

    context "AJAX updating listing" do
      setup { post :update_listing, :calender => { "date(1i)" => 2009, "date(2i)" => 6, "date(3i)" => 1 } }
        should_render_template :listing_content
    end

    context "AJAX updating calender" do
      setup { post :update_calender, :calender => { "date(1i)" => 2009, "date(2i)" => 6, "date(3i)" => 1 } }
        should_render_template :calender_content
    end

  end
  
  context "logged in as a regular user" do
    setup {
      login_as(:bill)
      get :calender
    }
    should_respond_with :success
  end

  context "Not logged in" do
    pages = [:calender,:month,:listing]
    pages.each do |page|
      context "a GET to :#{page}" do
        setup { get page }
        should_redirect_to("Login page") { "/user_sessions/new" }
      end
    end
  end
end
