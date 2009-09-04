class UsersController < ApplicationController

  before_filter :check_authentication, :check_admin

  def index
    @users = User.paginate :page => params[:page] || 1, :per_page => 15, :order => 'lastname'
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
    @user.admin = params[:user][:admin]
    @user.operative_status = params[:user][:operative_status]

    if @user.save
      flash[:notice] = 'User was successfully updated.'
      redirect_to(:controller => 'users', :action => 'show', :id => @user.id)
    else
      render :action => "edit"
    end
  end

  def destroy
    @user = User.find(params[:id])
    errors = []
    if @user.admin && User.find_all_by_admin(true).size == 1 then
      errors << 'Cannot not remove last admin user'
    end
    if @user.activities.size > 0 then
      errors << 'User is assigned to activities'
    end
    if @user.time_entries.size > 0 then
      errors << 'User has time_entries registrered'
    end

    if errors.empty?
      @user.destroy
      flash[:notice] = 'User was removed.'
    else
      flash[:error] = "Could not remove user due to error(s): #{errors.join(', ')}"
    end
    redirect_to(users_url)
  end
end
