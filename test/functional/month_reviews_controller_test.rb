require 'test_helper'

class MonthReviewsControllerTest < ActionController::TestCase

  setup do
    @date = Date.new(2009, 6, 22) # monday in week 26, 2009
    Date.stubs(:today).returns(@date)
  end

  context "Logged in as user Bob" do
    setup do
      login_as(:bob)
    end
    
    context "on GET to :show for calendar report" do      
      setup { get :show, :user_id => users(:bob).id, :id => "calendar" }
      
      should_render_template "month_reviews/calendar.html.erb"
      should_respond_with :success
      should_assign_to :user, :period, :activities_summary
    end
    
    context "on GET to :show for listing report" do
      setup { get :show, :user_id => users(:bob).id, :id => "listing" }
      
      should_render_template "month_reviews/listing.html.erb"
      should_respond_with :success
      should_assign_to :user, :beginning_of_month, :end_of_month, :time_entries
    end
    
    context "on GET to :show for listing report in pdf format" do
      setup { get :show, :user_id => users(:bob).id, :id => "listing", :format => "pdf" }
      
      should_render_template "month_reviews/listing.pdf.prawn"
      should_respond_with :success
      should_assign_to :user, :beginning_of_month, :end_of_month, :time_entries
    end
  end

  context "Not logged in" do
    setup { get :show, :user_id => users(:bob).id, :id => "listing" }
    should_redirect_to("Login page") { new_user_session_url }
  end
  
  context "When logged in as Bill" do 
    
    setup { login_as :bill }
    
    context "a GET request to :show with a different user id" do
      
      setup { get :show, :id => users(:bob).id.to_s }
      
      should_redirect_to("Login page") { new_user_session_url }
      should_set_the_flash_to "You do not have access to this page"
      
    end
    
  end
  
end