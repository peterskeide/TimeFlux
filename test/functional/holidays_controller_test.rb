require 'test_helper'

class HolidaysControllerTest < ActionController::TestCase

  context "Logged in as user Bob" do
    setup do
      login_as(:bob)
    end

    context "get holiday index" do
      setup {get :index}
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
      should_redirect_to("Holiday page") { "/holidays" }
    end

    context "get edit" do
      setup{get :edit, :id => holidays(:good_friday).id}
      should_respond_with :success
      should_render_template :edit
    end

    context "update holiday" do
      setup{ put :update, :id => holidays(:good_friday).to_param, :holiday => { } }
      should_assign_to :holiday
      should_redirect_to("Holiday page") { "holidays" }
    end

    context "destroy holiday" do
      setup{ delete :destroy, :id => holidays(:good_friday).id }
      should "remove the holiday" do
        assert_nil Holiday.find_by_id(holidays(:good_friday).id)
      end
      should_redirect_to("Holiday page") { "holidays" }
    end
  end

end
