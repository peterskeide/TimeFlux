class ProjectsController < ApplicationController

  before_filter :check_authentication
  before_filter :check_admin

  def index
    @projects = Project.paginate :page => params[:page] || 1, :per_page => 15, :order => 'name'
  end

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
      redirect_to(projects_url)
    else
      render :action => "new"
    end
  end

  def update
    @project = Project.find(params[:id])

    if @project.update_attributes(params[:project])
      flash[:notice] = 'Project was successfully updated.'
      redirect_to(projects_url)
    else
      render :action => "edit"
    end
  end

  def destroy
    @project = Project.find(params[:id])
    @project.destroy
    redirect_to(projects_url)
  end
end
