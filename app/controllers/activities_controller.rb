class ActivitiesController < ApplicationController
  
  before_filter :check_authentication

  def index
    activities = []
    no_data = 0
    TagType.all.each do |tt| 
      type = tt.name.to_sym
      if params[type] 
        unless params[type] =~ /all|none/
          tag = Tag.find params[type]
          activities += tag.activities
        end
        if params[type] == 'all'
          activities += tt.activities
        end
        no_data += 1 if params[type] == 'none'
      else
        no_data += 1
      end
    end
    
    if no_data == TagType.all.size then
      @activities = Activity.paginate( :page => params[:page] || 1, :per_page => 10 )
    else
      @activities = activities.flatten.uniq.paginate( :page => params[:page] || 1, :per_page => 10 )
    end
    @tag_types = TagType.find(:all)
  end
  
  def new
    @activity = Activity.new(:default_activity => false, :active=> true)
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