class ActivitiesController < ApplicationController
  
  before_filter :check_authentication
  
  def index
    @activities = Activity.find(:all)
  end
  
  def new
    @activity = Activity.new(:default_activity => false, :active=> true)
    @categories = Category.find(:all)
  end

  def edit
    @categories = Category.find(:all) 
    @activity = Activity.find(params[:id])
  end

  def create
    @activity = Activity.new(params[:activity])
    if @activity.save
      flash[:notice] = "New Activity was created"
      redirect_to(:action => 'index', :id => @activity.id)
    else
      @activity = User.new(params[:activity])
      render :action => "new"
    end
  end

  def update
    @activity = Activity.find(params[:id])
    @activity.active = !@activity.active
    if @activity.save
      flash[:notice] = 'Activity was successfully updated.'
      redirect_to(:action => 'index', :id => @activity.object_id)
    else
      render :action => "edit"
    end
  end


  def destroy
    @activity = Activity.find(params[:id])
    begin
      @activity.destroy
    rescue
      flash[:notice] = "#{$!}"
    end
    redirect_to(activities_url)
  end

  
end