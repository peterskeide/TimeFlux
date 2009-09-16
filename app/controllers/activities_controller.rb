class ActivitiesController < ApplicationController
      
  before_filter :check_authentication
  before_filter :check_admin, { :except => :show }
  
  def index
    @activities = Activity.templates.paginate :page => params[:page] || 1, :per_page => 15, :order => 'name'
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
    if params[:activity][:name].is_a? Array
      project = Project.find(params[:activity][:project_id])
      params[:activity][:name].each do |name|
        template = Activity.templates.find_by_name(name)
        @activity = template.clone
        @activity.project = project
        @activity.template = false
        @activity.tags = template.tags
        @activity.save
      end
      redirect_to project_url(:id => @activity.project.id)
    else
      @activity = Activity.new(params[:activity])
      @activity.tags = Tag.find(params[:tags]) if params[:tags]
      if @activity.save
        flash[:notice] = "New Activity was created"
        redirect_to_activity(@activity)
      else
        flash[:notice] = "Unable to create activity"
        render :action => "new"
      end
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
        redirect_to_activity(@activity)
      else
        flash[:error] = "Unable to update activity"
        render :edit
      end
      @activity.tags = Tag.find(params[:tags]) if params[:tags]

    rescue ActiveRecord::RecordNotFound
      handle_missing_resource
    end
  end
  
  def destroy
    @activity = Activity.find_by_id(params[:id])
    @activity.tags = []
    project = @activity.project
    if @activity.destroy

      flash[:notice]= "Activity successfully removed"
      redirect_to_activity(@activity)
    else
      flash[:error] = @activity.errors.entries[0][0]
      redirect_to project_url(:id => project.id)
    end
  end
  
  private

  def redirect_to_activity(activity)
    if activity.project
      redirect_to project_url(:id => activity.project.id)
    else
      redirect_to activities_url
    end
  end

  def handle_missing_resource
    flash[:error] = "The requested resource does not exist"
    redirect_to activities_url
  end

  def update_form

    customer = Customer.find(params[:customer_id]) if params[:customer_id] && params[:customer_id] != ""
    render :partial => 'form', :locals => { :customer => customer, :params => params }
  end

  def update_activities

    activities = Activity.search(params[:active], params[:default], 1)
    render :partial => 'activities', :locals => { :activities => activities }
  end
  
end