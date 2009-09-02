class ActivitiesController < ApplicationController
      
  before_filter :check_authentication
  before_filter :check_admin, {:except => :show}
  
  def index
    @activities = Activity.templates.paginate :page => params[:page] || 1, :per_page => 15, :order => 'name'
  end
 
  def new
    @activity = Activity.new
  end

  def edit
    @activity = Activity.find(params[:id])
  end

  def show
    @activity = Activity.find(params[:id])
  end
  
  def create
    if params[:activity][:name].is_a? Array
      project = Project.find(params[:activity][:project_id])
      params[:activity][:name].each do |name|
        template = Activity.templates.find_by_name(name)
        @activity = template.clone
        @activity.project = project
        @activity.template = false
        @activity.save
      end
      redirect_to project_url(:id => @activity.project.id)
    else
      @activity = Activity.new(params[:activity])
      if @activity.save
        flash[:notice] = "New Activity was created"
        redirect_to :action => "index"
      else
        render :action => "new"
      end
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
    project = @activity.project
    if @activity.destroy
      flash[:notice]= "Activity successfully removed"
      if project
        redirect_to(project_url :id => project.id)
      else
        redirect_to activities_url
      end
    else
      render :edit        
    end     
  end

  def update_form
    tags = params[:tag_type_id] && params[:tag_type_id] != "" ? TagType.find(params[:tag_type_id]).tags : []
    customer = Customer.find(params[:customer_id]) if params[:customer_id] && params[:customer_id] != ""
    render :partial => 'form', :locals => { :tags => tags, :customer => customer, :params => params }
  end

  def update_activities
    if !params[:tag_type_id] || params[:tag_type_id] = ""
      params[:tag_id] = nil
    end
    activities = Activity.search(params[:active], params[:default], params[:tag_id], params[:tag_type_id], 1)
    render :partial => 'activities', :locals => { :activities => activities }
  end
end