class ActivitiesController < ApplicationController
  
  before_filter :check_authentication
  
  def index
    @debug = ''
    activities = []
    TagType.all.each do |tt| 
      type = tt.name.to_sym
      if params[type] 
        unless params[type] =~ /all|none/
          tag = Tag.find_by_id(params[type])
          puts "Tag: #{tag}, Activities: #{tag.activities}"
          activities << tag.activities
        end
        if params[type] == 'all'
          activities << tt.activities
        end
        if params[type] == 'none'
          #TODO
          #1. find tags where type = tt
          #2. select the inverse
          #Activity.all.each{|a| activities << a if a.tags.empty? }
        end
      end
    end
    @activities = activities.flatten
#    if params[:Project]
#      project = Tag.find params[:Project]
#      @activities << project.activities
#    end
    
    #@activities = Activity.find(:all)
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