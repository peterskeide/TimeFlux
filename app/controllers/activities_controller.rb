class ActivitiesController < ApplicationController
  
  before_filter :check_authentication, :check_admin

  def index
    @tag_types = TagType.find(:all)
    if params[:tag_type] && !params[:tag_type][:id].empty?
      @tag_type = TagType.find_by_id(params[:tag_type][:id]) 
      @activities = @tag_type.activities.flatten.paginate( :page => params[:page] || 1, :per_page => 10, :order => 'name' )
    elsif params[:tag]
      unless params[:tag][:id].empty?
        @tag = Tag.find_by_id(params[:tag][:id])
        @activities = @tag.activities.paginate( :page => params[:page] || 1, :per_page => 10, :order => 'name' )
        @tag_type = @tag.tag_type 
      else
        @tag_type = TagType.find_by_id(params[:tag_type_id])
      end
    else
      @activities = Activity.paginate( :page => params[:page] || 1, :per_page => 10, :order => 'name' )
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
      render :action => "new"
    end
  end

  def update
    @activity = Activity.find(params[:id])
    attributes = params[:activity]
    if @activity.update_attributes(attributes)
      flash[:notice] = 'Activity was successfully updated.'
      redirect_to(:action => 'index', :id => @activity.id)
    else
      @tags = Tag.find(:all)
      render :action => "edit"
    end
  end

  def destroy
    @activity = Activity.find_by_id(params[:id])
    if @activity.time_entries.empty?
      if @activity.destroy
        flash[:notice]= "Activity successfully removed"
        redirect_to(activities_url)
      else
        @tags = Tag.find(:all)
        render :edit        
      end
    else
      flash[:error]= "Activity has hours registered - could not delete"
      @tags = Tag.find(:all)
      render :edit
    end      
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