class ActivitiesController < ApplicationController
      
  before_filter :check_authentication, :check_admin
  
  def index
    @tags = params[:tag_type_id].blank? ? [] : Tag.find_all_by_tag_type_id(params[:tag_type_id])
    page = params[:page] || 1
    @activities = Activity.search(params[:active], params[:default], params[:tag_id], params[:tag_type_id], page)
  end
 
  def new
    @activity = Activity.new
  end

  def edit
    @activity = Activity.find(params[:id])
  end
  
  def create
    @activity = Activity.new(params[:activity])
    if @activity.save
      flash[:notice] = "New Activity was created"
      redirect_to :action => "index"
    else
      render :action => "new"
    end
  end

  def update
    @activity = Activity.find(params[:id])
    if @activity.update_attributes(params[:activity])
      flash[:notice] = "Activity was successfully updated."
      redirect_to :action => "index"
    else
      render :action => "edit"
    end
  end

  def destroy
    @activity = Activity.find_by_id(params[:id])
    if @activity.destroy
      flash[:notice]= "Activity successfully removed"
      redirect_to(activities_url)
    else
      render :edit        
    end     
  end

end