class ActivitiesController < ApplicationController
  
  PAGINATION_OPTIONS = { :page => 1, :per_page => 10, :order => "name" }
    
  before_filter :check_authentication, :check_admin
  before_filter :set_current_page_for_pagination, :only => [:index, :filter_by_tag_type, :filter_by_tag]
  
  def index
    @tag_types = TagType.find(:all)

    if params[:active] then
      @active_selected = params[:active][:active].intern
    else
      @active_selected = :active
    end

    if params[:tag] && params[:tag][:id] != "" && params[:tag_type][:id] != "" then
      @tag = Tag.find_by_id(params[:tag][:id])
      @tag_type = @tag.tag_type
      @activities = @tag.activities_filtered(@active_selected).paginate(PAGINATION_OPTIONS)
    elsif params[:tag_type] && params[:tag_type][:id] != "" then
      @tag_type = TagType.find_by_id(params[:tag_type][:id])
      @activities = @tag_type.activities_filtered(@active_selected).paginate(PAGINATION_OPTIONS)
    else
      @activities = Activity.filtered(@active_selected).paginate(PAGINATION_OPTIONS)
    end
  end
  
  def filter_by_tag_type(active)
    @tag_types = TagType.find(:all)
    @tag_type = TagType.find_by_id(params[:tag_type][:id])
    @activities = @tag_type.activities_filtered(active).paginate(PAGINATION_OPTIONS)
    render :index
  end
  
  def filter_by_tag(active)
    @tag_types = TagType.find(:all)
    @tag = Tag.find_by_id(params[:tag][:id])
    @tag_type = @tag.tag_type
    @activities = @tag.activities_filtered(active).paginate(PAGINATION_OPTIONS)
    render :index
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
  
  def set_current_page_for_pagination
    PAGINATION_OPTIONS[:page]= params[:page] if params[:page]
  end
  
  def initialize_unselected_associations_for_activity
    @tags = Tag.all - @activity.tags
    @users = User.all - @activity.users
  end

end