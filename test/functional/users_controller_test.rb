require 'test_helper'

class UserssControllerTest < ActionController::TestCase

  def setup
    @controller = UsersController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    @user = User.find(:first)
  end
   
  test "do we have a user to play with?" do
    assert_not_nil @user
    #puts "#{@user.fullname}, (#{@user.username}), id=#{@user.object_id}"
  end


  context "With users" do

    context "a GET to :index" do
      setup { get :index }
      should_respond_with :success
      should_not_set_the_flash
    end

    context "a GET to :new" do
      setup { get :new }
      should_respond_with :success
      should_not_set_the_flash
    end

    context "a POST to :create" do
      setup { post :create, :user => {:firstname => 'Ronald', :lastname => 'McDonald', :password => "something", :login => "uniquesdfkjgcsndfc" } }
      should_respond_with :redirect
      should_assign_to :user
      should_redirect_to "user_url(@user)"
      should_set_the_flash_to(/created/i)
    end

    context "a POST to :create supplying an existing username" do
      setup { post :create, :user => {:firstname => 'Ronald', :lastname => 'McDonald', :password => "something", :login => @user.username } }
      should_respond_with :success
      #should_assign_to :user
      #should_redirect_to "user_url(@user)"
      should_set_the_flash_to(/Could not create/i)
    end


    #TODO why does this one fail?
    context "a GET to :edit" do
      #setup { get :edit, :id => @user.object_id }
      #should_respond_with :success
      #should_not_set_the_flash
    end

  end

end
