class UsersController < ApplicationController

  before_filter :check_authentication

  def index
    @users = User.find(:all)
  end

  def show
    @user = User.find(params[:id])
  end

  def new
    @user = User.new
  end

  def edit
    @user = User.find(params[:id])
  end

  def create
    @user = User.new(params[:user])
    if @user.save
      flash[:notice] = "New user was created"
      redirect_to(:action => 'show', :id => @user.id) 
    else
      flash[:notice] = 'Could not create user.'
      @user = User.new(params[:user])
      render :action => "new"
    end
  end

  def update
    @user = User.find(params[:id])

    #attributes = params[@user.class.name.underscore]
    #if @user.update_attributes(attributes)

    if params[:user][:password] then
       @user.password = params[:user][:password]
       @user.password_confirmation = params[:user][:password_confirmation]
    end
    @user.firstname = params[:user][:firstname]
    @user.lastname = params[:user][:lastname]
    @user.login = params[:user][:login]
    @user.email = params[:user][:email]


    if @user.save
      flash[:notice] = 'User was successfully updated.'
      redirect_to(:controller => 'users', :action => 'show', :id => @user.id)
    else
      render :action => "edit"
    end
  end


  def destroy
    @user = User.find(params[:id])
    @user.destroy
    redirect_to(users_url)
  end
end
