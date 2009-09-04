require 'test_helper'

class HolidaysControllerTest < ActionController::TestCase

  context "Logged in as user Bob" do
    setup do
      login_as(:bob)
    end

    context "get holidays" do
      setup {get :holiday}
      should_respond_with :success
      should_assign_to :holidays
    end

    context "get new" do
      setup {get :new}
      should_respond_with :success
      should_render_template :new
    end

    context "creating holiday" do
      setup do
        post :create, :holiday => {:date => Date.new(2009, 6, 22), :repeat => "0", :working_hours => 4, :note =>"gdfg"}
      end

      should_assign_to :holiday
      should_redirect_to("Holiday page") { "/holidays/holiday" }
    end

    context "get edit" do
      setup{get :edit, :id => holidays(:good_friday).id}
      should_respond_with :success
      should_render_template :edit
    end

    context "update holiday" do
      setup{ put :update, :id => holidays(:good_friday).to_param, :holiday => { } }
      should_assign_to :holiday
      should_redirect_to("Holiday page") { "/holidays/holiday" }
    end

    context "destroy holiday" do
      setup{ delete :destroy, :id => holidays(:good_friday).id }
      should "remove the holiday" do
        assert_nil Holiday.find_by_id(holidays(:good_friday).id)
      end
      should_redirect_to("Holiday page") { "/holidays/holiday" }
    end

    context "get vacation" do
      setup{ get :vacation }
      should_render_template :vacation
    end

    context "set vacation" do
      setup { post :set_vacation, :month => "2009-08-1", :user_id =>  users(:bob).id,
        :date => { "2009-08-17" => "1", "2009-08-18"=>"1", "2009-08-19"=>"1"} }
      should_redirect_to("vacation page page") { "/holidays/vacation?date=2009-08-01" }
      should "create vacation time_entries on the checked dates" do
        entry = TimeEntry.on_day(Date.civil(2009,8,18))
        assert_equal entry[0].activity.name, activities(:vacation).name
      end
    end
    
    context "remove vacation" do
      setup do
        TimeEntry.create(:user => users(:bob), :hours => 4, :date => Date.parse("2009-08-3"), :activity => activities(:vacation))
        post :set_vacation, :month => "2009-08-1", :user_id =>  users(:bob).id, :date => { }
      end
      should_redirect_to("vacation page page") { "/holidays/vacation?date=2009-08-01" }
      should "remove unchecked vacation dates" do
        assert TimeEntry.on_day(Date.civil(2009,8,3)).empty?
      end
    end  
  end

  context "Logged in as user Bill, trying to update bob´s vacations" do
    setup do
      login_as(:bill)
      post :set_vacation, :month => "2009-08-1", :user_id =>  users(:bob).id,
        :date => { "2009-08-17" => "1", "2009-08-18"=>"1", "2009-08-19"=>"1"}
      should_set_the_flash_to(/No permission/i)
    end
  end
end
