class ProjectsController < ApplicationController

  before_filter :check_authentication
  before_filter :check_admin

  def show
    @project = Project.find(params[:id])
  end

  def new
    @project = Project.new
  end

  def edit
    @project = Project.find(params[:id])
  end

  def create
    @project = Project.new(params[:project])

    if @project.save
      flash[:notice] = 'Project was successfully created.'
      redirect_to customer_url(:id => @project.customer.id)
    else
      render :action => "new"
    end
  end

  def update
    @project = Project.find(params[:id])

    if @project.update_attributes(params[:project])
      flash[:notice] = 'Project was successfully updated.'
      redirect_to customer_url(:id => @project.customer.id)
    else
      render :action => "edit"
    end
  end

  def destroy
    @project = Project.find(params[:id])
    @project.destroy
    redirect_to  customer_url(:id => @project.customer.id)
  end

  def assign_to_users
    project = Project.find(params[:project_id])
    params[:users].each do |user_id|
      user = User.find(user_id.to_i)
      project.users << user
    end
    redirect_to project_url(:id => project.id)
  end

  def assign_by_login
    project = Project.find(params[:project_id])
    user = User.find_by_login(params[:login])
    if user
    project.users << user
    else
      flash[:error] = "User #{params[:login]} not found"
    end

    redirect_to project_url(:id => project.id)
  end

  def remove_user_assignment
    project = Project.find(params[:id])
    user = User.find(params[:user])
    project.users.delete user
    redirect_to project_url(:id => project.id)
  end
end
