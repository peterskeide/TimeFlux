class UsersController < ApplicationController

  before_filter :check_authentication
  before_filter :check_admin, :only => [:new, :create, :destroy, :index]

  def index
    @users = User.paginate :page => params[:page] || 1, :per_page => 25, :order => 'lastname'
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
      redirect_to user_url(@user)
    else
      render :action => "new"
    end
  end

  def update
    @user = User.find(params[:id])
    
    if params[:user][:password] then
       @user.password = params[:user][:password]
       @user.password_confirmation = params[:user][:password_confirmation]
    end
    @user.firstname = params[:user][:firstname]
    @user.lastname = params[:user][:lastname]
    @user.login = params[:user][:login]
    @user.email = params[:user][:email]
    @user.operative_status = params[:user][:operative_status]

    if @current_user.admin
      @user.admin = params[:user][:admin]
    end
    
    if @user.save
      flash[:notice] = 'User was successfully updated.'
      redirect_to user_url(@user)
    else
      render :action => "edit"
    end
  end

  def destroy
    @user = User.find(params[:id])
    if @user.destroy
      flash[:notice] = 'User was removed.'
    else
      flash[:error] = "Could not remove user due to error(s): #{@user.errors.entries[0][1]}"
    end
    redirect_to users_url
  end
end
