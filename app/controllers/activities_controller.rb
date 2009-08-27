class ActivitiesController < ApplicationController
      
  before_filter :check_authentication
  before_filter :check_admin, { :except => :show }
  
  def index
    @activities = Activity.all
  end
  
  def show
    begin
      @activity = Activity.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      handle_missing_resource
    end
  end
  
  def new
    @activity = Activity.new
  end
  
  def create
    @activity = Activity.new(params[:activity])
    if @activity.save
      flash[:notice] = "Activity created"
      redirect_to activities_url
    else
      flash[:error] = "Unable to create activity"
      render :new
    end
  end
  
  def edit
    begin
      @activity = Activity.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      handle_missing_resource
    end
  end
  
  def update
    begin
      @activity = Activity.find(params[:id])
      if @activity.update_attributes(params[:activity])
        flash[:notice] = "Activity updated"
        redirect_to activities_url
      else
        flash[:error] = "Unable to update activity"
        render :edit
      end
    rescue ActiveRecord::RecordNotFound
      handle_missing_resource
    end
  end
  
  def destroy
    @activity = Activity.find_by_id(params[:id])
    if @activity.destroy
      flash[:notice] = "Activity deleted"
    else
      flash[:error] = @activity.errors.entries[0][0]    
    end
    redirect_to activities_url 
  end
  
  private
  
  def handle_missing_resource
    flash[:error] = "The requested resource does not exist"
    redirect_to activities_url
  end
  
end