require File.dirname(__FILE__) + '/../test_helper'

class TimeEntriesControllerTest < ActionController::TestCase
        
  context "User logged in: " do
    
    setup do
      login_as :bob
      @date = Date.new(2009, 6, 22) # monday in week 26, 2009
      Date.stubs(:today).returns(@date)
    end
             
    context "GET to :index with no date param" do
            
      setup { get :index, :user_id => users(:bob).id }
      
      should_respond_with :success
      should_not_set_the_flash
      should_assign_to :date, :user
      should_render_template :index
                
    end
    
    context "GET to :index with date from previous week" do
      
      setup { get :index, :user_id => users(:bob).id, :date => @date.-(7).to_s }
      
      should_respond_with :success
      should_not_set_the_flash
      should_assign_to :user
      should_render_template :index
      
      should "assign date from previous week" do
        date = assigns(:date)
        assert_equal(25, date.cweek)
      end
      
    end
    
    context "GET to :index with date from next week" do
      
      setup { get :index, :user_id => users(:bob).id, :date => @date.+(7).to_s }
      
      should_respond_with :success
      should_not_set_the_flash
      should_assign_to :user
      should_render_template :index
      
      should "assign date from next week" do
        date = assigns(:date)
        assert_equal(27, date.cweek)
      end
      
    end
              
    context "GET to :new" do
      
      setup { xhr :get, :new, :user_id => users(:bob).id, :date => @date.to_s, :day => "Monday" }
      
      should_respond_with :success
      should_not_set_the_flash
      should_assign_to :time_entry, :activities, :user
      should_render_template "time_entries/time_entries_with_form.rjs"
           
    end
    
    context "GET to :edit" do
      
      setup { xhr :get, :edit, :user_id => users(:bob).id, :id => time_entries(:bob_timeflux_development_26_monday).id }
      
      should_respond_with :success
      should_not_set_the_flash
      should_assign_to :time_entry, :user, :activities
      should_render_template "time_entries/time_entries_with_form.rjs"
     
    end
           
    context "successful POST to :create" do
      
      setup { 
        xhr :post, :create, :user_id => users(:bob).id, 
        :time_entry => { :date => @date.to_s, :activity_id => activities(:timeflux_development).id, :notes =>"Foo", :hours => 3.0, :hour_type_id => hour_types(:normaltid).id } 
      }
      
      should_assign_to :user
      should_change("the number of time entries", :by => 1) { TimeEntry.count }     
      should_respond_with :success
            
      should "refresh time entries for the relevant day" do
        assert_select_rjs :replace_html, "Monday_time_entries_container"
      end

      should "refresh week total" do
        assert_select_rjs :replace_html, "week_total" do
          assert_select "b", "55.5"
        end
      end

      should "update the day total hours field" do 
        assert_select_rjs :replace_html, "Monday_total" do
          assert_select "b", "10.5"
        end
      end
            
    end
    
    context "unsuccessful POST to :create" do
      
      setup {
        xhr :post, :create, :user_id => users(:bob).id, 
        :time_entry => { :date => @date.to_s, :activity_id => activities(:timeflux_development).id, :notes =>"Foo", :hours => 0.0, :hour_type_id => hour_types(:normaltid).id } 
      }
      
      should_assign_to :time_entry, :activities, :user
      should_not_change("the number of time entries") { TimeEntry.count }
      
      should "display error messages" do
        assert_select_rjs :replace_html, "Monday_time_entry_error_messages" do
          assert_select "p.error", assigns(:time_entry).errors.full_messages.to_s 
        end
      end
      
    end
                
    context "successful PUT to :update" do
      
      setup { 
        xhr :put, :update, :user_id => users(:bob).id, :id => time_entries(:bob_timeflux_development_26_monday).id, 
        :time_entry => { :notes => "Foo", :hours => 3.0 } 
      }
      
      should_respond_with :success
      should_assign_to :time_entry, :user
      
      should "refresh time entries for the relevant day" do
        assert_select_rjs :replace_html, "Monday_time_entries_container"
      end

      should "refresh week total" do
        assert_select_rjs :replace_html, "week_total" do
          assert_select "b", "48.0"
        end
      end
      
      should "update the day total hours field" do 
        assert_select_rjs :replace_html, "Monday_total" do
          assert_select "b", "3.0"
        end
      end
            
    end
    
    context "unsuccessful PUT to :update" do
      
      setup {
        @id = time_entries(:bob_timeflux_development_26_monday).id 
        xhr :put, :update, :user_id => users(:bob).id, :id => @id, 
        :time_entry => { :notes => "Foo", :hours => 0.0 } 
      }
      
      should_assign_to :time_entry, :activities, :user
      
      should "display error messages" do
        assert_select_rjs :replace_html, "Monday_time_entry_error_messages" do
          assert_select "p.error", assigns(:time_entry).errors.full_messages.to_s 
        end
      end
    
    end
        
    context "DELETE to :destroy" do
      
      setup { xhr :delete, :destroy, :user_id => users(:bob).id, :id => time_entries(:bob_timeflux_development_26_monday).id }
      
      should_respond_with :success
      should_change("the number of time entries", :by => -1) { TimeEntry.count }
      
      should "refresh time entries for the relevant day" do
        assert_select_rjs :replace_html, "Monday_time_entries_container"
      end

      should "refresh week total" do
        assert_select_rjs :replace_html, "week_total" do
          assert_select "b", "45.0"
        end
      end
      
      should "update the day total hours field" do 
        assert_select_rjs :replace_html, "Monday_total" do
          assert_select "b", "0.0"
        end
      end
      
    end
    
    context "POST to :change_user for administrator" do
      
      setup { post :change_user, :user_id => users(:bob).id, :new_user_id => users(:bill).id, :date => @date.to_s }
      
      should_respond_with :redirect
      should_redirect_to("Index") { user_time_entries_url(:user_id => users(:bill).id, :date => @date.to_s) }
      
    end
    
    context "POST to :change_user for regular user" do
      
      setup {
        login_as :bill 
        post :change_user, :user_id => users(:bill).id, :new_user_id => users(:bob).id, :date => @date.to_s 
        }
      
      should_set_the_flash_to "Mind your own business"
      should_respond_with :redirect
      should_redirect_to("Index") { user_time_entries_url(:user_id => users(:bill).id, :date => @date.to_s) }
      
    end
    
  end
  
  context "When logged in as Bill" do
    
    setup { login_as :bill }
    
    context "a GET request to TimeEntriesController :index with different user id" do
      
      setup { get :index, :user_id => users(:bob).id.to_s }
      
      should_redirect_to("Login page") { new_user_session_url }
      should_set_the_flash_to "You do not have access to this page"
      
    end
    
    context "a PUT request to TimeEntriesController :update with different user id" do
      
      setup { put :update, :user_id => users(:bob).id.to_s }
      
      should_redirect_to("Login page") { new_user_session_url }
      should_set_the_flash_to "You do not have access to this page"
      
    end
        
    context "a POST request to TimeEntriesController :create with different user id" do
      
      setup { post :create, :user_id => users(:bob).id.to_s }
      
      should_redirect_to("Login page") { new_user_session_url }
      should_set_the_flash_to "You do not have access to this page"
      
    end
    
    context "a GET request to TimeEntriesController :new with different user id" do
      
      setup { get :new, :user_id => users(:bob).id.to_s }
      
      should_redirect_to("Login page") { new_user_session_url }
      should_set_the_flash_to "You do not have access to this page"
      
    end
    
    context "a DELETE request to TimeEntriesController :destroy with different user id" do
      
      setup { delete :destroy, :user_id => users(:bob).id.to_s }
      
      should_redirect_to("Login page") { new_user_session_url }
      should_set_the_flash_to "You do not have access to this page"
      
    end
    
    context "a POST request to TimeEntriesController :lock with different user id" do
      
      setup { post :lock, :user_id => users(:bob).id.to_s }
      
      should_redirect_to("Login page") { new_user_session_url }
      should_set_the_flash_to "You do not have access to this page"
      
    end
    
  end
  
  context "User not logged in: " do
    
    context "GET to :index" do            
      setup { get :index }            
      should_redirect_to("Login page") { new_user_session_url }          
    end
    
    context "GET to :previous (Previous Week link)" do      
      setup { get :previous }      
      should_redirect_to("Login page") { new_user_session_url }           
    end
    
    context "GET to :next (Next Week link)" do      
      setup { get :next }      
      should_redirect_to("Login page") { new_user_session_url }           
    end
    
    context "GET to :new" do      
      setup { get :new }      
      should_redirect_to("Login page") { new_user_session_url }           
    end
    
    context "GET to :edit" do      
      setup { get :edit }      
      should_redirect_to("Login page") { new_user_session_url }                  
    end
    
    context "successful POST to :update" do      
      setup { put :update }              
      should_redirect_to("Login page") { new_user_session_url }      
     end
      
    context "unsuccessful POST to :update" do      
      setup { put :update }      
      should_redirect_to("Login page") { new_user_session_url }                          
    end
    
    context "POST to :update for locked time entries" do      
      setup { put :update }      
      should_redirect_to("Login page") { new_user_session_url }                  
    end
    
    context "DELETE to :destroy" do      
      setup { delete :destroy }      
      should_redirect_to("Login page") { new_user_session_url }      
    end
    
  end 
  
end