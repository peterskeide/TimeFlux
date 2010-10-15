require 'test_helper'

class DepartmentsControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:departments)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create department" do
    assert_difference('Department.count') do
      post :create, :department => { :name => "Vedlikehold", :internal_id => 100 }
    end

    assert_redirected_to department_path(assigns(:department))
  end

  test "should show department" do
    get :show, :id => departments(:one).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => departments(:one).to_param
    assert_response :success
  end

  test "should update department" do
    put :update, :id => departments(:one).to_param, :department => { :name => "Salgsstøtte", :internal_id => 200 }
    assert_redirected_to department_path(assigns(:department))
  end

  test "should destroy department" do
    assert_difference('Department.count', -1) do
      delete :destroy, :id => departments(:one).to_param
    end

    assert_redirected_to departments_path
  end
end
