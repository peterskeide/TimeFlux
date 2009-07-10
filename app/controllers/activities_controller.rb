class ActivitiesController < ApplicationController
  
  PAGINATION_OPTIONS = { :page => 1, :per_page => 10, :order => "name" }
    
  before_filter :check_authentication, :check_admin
  before_filter :set_current_page_for_pagination, :only => [:index, :filter_by_tag_type, :filter_by_tag]
  
  def index    
    @tag_types = TagType.find(:all)
    @active_selected = params[:active] ? params[:active] : "any"
    @default_selected = params[:default] ? params[:default] : "any"
    if tag_selected?
      @tag = Tag.find_by_id(params[:tag][:id])
      @tag_type = @tag.tag_type
      @activities = filter_activity(@tag.activities, @active_selected, @default_selected).paginate(PAGINATION_OPTIONS)
    elsif tag_type_selected?
      @tag_type = TagType.find_by_id(params[:tag_type][:id])
      @activities =  filter_activity(@tag_type.activities, @active_selected, @default_selected).paginate(PAGINATION_OPTIONS)
    else
      @activities = Activity.active(@active_selected).default(@default_selected).paginate(PAGINATION_OPTIONS)
    end
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
  
  def tag_selected?
    params[:tag] && params[:tag][:id] != "" && params[:tag_type][:id] != ""
  end
  
  def tag_type_selected?
    params[:tag_type] && params[:tag_type][:id] != ""
  end

  def filter_activity(list, active = "any", default = "any")
    list = list.select{ |a| a.active == (active == "true") } unless active == "any"    
    list = list.select{ |a| a.default_activity == (default == "true") } unless default == "any"
    list
  end
  
  def set_current_page_for_pagination
    PAGINATION_OPTIONS[:page]= params[:page] if params[:page]
  end
  
  def initialize_unselected_associations_for_activity
    @tags = Tag.all - @activity.tags
    @users = User.all - @activity.users
  end

end