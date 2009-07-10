class ActivitiesController < ApplicationController
      
  before_filter :check_authentication, :check_admin
  
  def index    
    @tag_types = TagType.find(:all)
    @selected_active_option = params[:active] ? params[:active] : "any"
    @selected_default_option = params[:default] ? params[:default] : "any"
    @tag = tag_selected? ? Tag.find(params[:tag][:id]) : nil
    @tag_type = tag_type_selected? ? TagType.find(params[:tag_type][:id]) : nil
    @activities = Activity.search(@active_selected, @default_selected, @tag, @tag_type, params[:page])
  end
 
  def new
    @activity = Activity.new
  end

  def edit
    @activity = Activity.find(params[:id])
    initialize_unselected_associations_for_activity
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
    attributes = params[:activity]
    if @activity.update_attributes(attributes)
      flash[:notice] = "Activity was successfully updated."
      redirect_to :action => "index"
    else
      initialize_unselected_associations_for_activity
      render :action => "edit"
    end
  end

  def destroy
    @activity = Activity.find_by_id(params[:id])
    if @activity.destroy
      flash[:notice]= "Activity successfully removed"
      redirect_to(activities_url)
    else
      initialize_unselected_associations_for_activity
      render :edit        
    end     
  end

  def add_tag
    activity = Activity.find_by_id(params[:activity][:id])
    tag = Tag.find_by_id(params[:tag])
    activity.tags << tag
    redirect_to(:action => "edit", :id => activity.id)
  end

  def remove_tag
    activity = Activity.find(params[:id])
    tag = Tag.find params["tag"]
    activity.tags.delete tag
    redirect_to(:action => "edit", :id => activity.id)
  end

  def add_user
    activity = Activity.find(params[:activity][:id])
    user = User.find params[:user]
    activity.users << user
    redirect_to(:action => "edit", :id => activity.id)
  end

  def remove_user
    activity = Activity.find(params[:id])
    user = User.find params["user"]
    activity.users.delete user
    redirect_to(:action => "edit", :id => activity.id)
  end
  
  private
  
  def initialize_unselected_associations_for_activity
    @tags = Tag.all - @activity.tags
    @users = User.all - @activity.users
  end
  
  def tag_selected?
    params[:tag] && params[:tag][:id] != ""
  end
  
  def tag_type_selected?
    params[:tag_type] && params[:tag_type][:id] != ""
  end

end