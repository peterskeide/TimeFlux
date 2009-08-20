require 'test_helper'

class HolidaysControllerTest < ActionController::TestCase

  context "Logged in as user Bob" do
    setup do
      login_as(:bob)
    end

    context "get index" do
      setup {get :index}
      should_respond_with :success
      should_assign_to :holidays
    end

    context "get new" do
      setup {get :new}
      should_respond_with :success
      should_render_template :edit
    end

    context "creating holiday" do
      setup do
        post :create, :holiday => {:date => Date.new(2009, 6, 22), :repeat => "0", :working_hours => 4, :note =>"gdfg"}
      end

      should_assign_to :holiday
      should_redirect_to("Index page") { "/holidays" }
    end

    context "get edit" do
      setup{get :edit, :id => holidays(:good_friday).id}
      should_respond_with :success
      should_render_template :edit
    end

    context "update holiday" do
      setup{ put :update, :id => holidays(:good_friday).to_param, :holiday => { } }
      should_assign_to :holiday
      should_redirect_to("Index page") { "/holidays" }
    end

    context "destroy holiday" do
      setup{ delete :destroy, :id => holidays(:good_friday).id }
      should "remove the holiday" do
        assert_nil Holiday.find_by_id(holidays(:good_friday).id)
      end
      should_redirect_to("Index page") { "/holidays" }
    end

    context "get vacation" do
      setup{ get :vacation }
      should_render_template :vacation
    end

    context "set vacation" do
      setup { post :set_vacation, :month => "2009-08-1", :user_id =>  users(:bob).id,
        :date => { "2009-08-17" => "1", "2009-08-18"=>"1", "2009-08-19"=>"1"} }
      should_redirect_to("vacation page page") { "/holidays/vacation" }
      should "create a holiday entry on the specified date" do
        entry = TimeEntry.on_day(Date.civil(2009,8,18))
        assert_equal entry[0].activity.name, activities(:vacation).name
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
