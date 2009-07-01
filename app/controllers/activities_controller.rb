class ActivitiesController < ApplicationController
  
  before_filter :check_authentication, :check_admin

  def index
    @tag_types = TagType.find(:all)
    @activities = []
    if params[:tag_type] && !params[:tag_type][:id].empty?
      @tag_type = TagType.find_by_id(params[:tag_type][:id])
      @tag_type.tags.each { |tag| @activities += tag.activities }
    elsif params[:tag]
      unless params[:tag][:id].empty?
        @tag = Tag.find_by_id(params[:tag][:id])
        @activities += @tag.activities
        @tag_type = @tag.tag_type 
      else
        @tag_type = TagType.find_by_id(params[:tag_type_id])
      end
    else
      @activities = Activity.all
    end
  end
  
  def new
    @activity = Activity.new
    @tags = Tag.find(:all)
  end

  def edit
    @tags = Tag.find(:all)
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
    attributes = params[@activity.class.name.underscore]
    if @activity.update_attributes(attributes)
      flash[:notice] = 'Activity was successfully updated.'
      redirect_to(:action => 'index', :id => @activity.id)
    else
      render :action => "edit"
    end
  end

  def destroy
    @activity = Activity.find(params[:id])
    begin
      if @activity.time_entries.empty?
        @activity.destroy
      else
        raise "Activity has hours registered - could not delete"
      end
    rescue
      flash[:error] = "#{$!}"
    end
    redirect_to(activities_url)
  end

  def add_tag
    activity = Activity.find(params["activity"]['id'])
    tag = Tag.find params["tag"]
    
    if activity.tags.include? tag then
      flash[:error] = 'Tag already added to this activity'
    else
      activity.tags << tag
    end

    redirect_to(:action => 'edit', :id => activity.id)
  end

  def remove_tag
    activity = Activity.find(params[:id])
    tag = Tag.find params["tag"]
    activity.tags.delete tag
    redirect_to(:action => 'edit', :id => activity.id)
  end

  def add_user
    activity = Activity.find(params["activity"]['id'])
    user = User.find params["user"]

    if activity.users.include? user then
      flash[:error] = 'User already assigned to this activity'
    else
      activity.users << user
    end

    redirect_to(:action => 'edit', :id => activity.id)
  end

  def remove_user
    activity = Activity.find(params[:id])
    user = User.find params["user"]
    activity.users.delete user
    redirect_to(:action => 'edit', :id => activity.id)
  end

end