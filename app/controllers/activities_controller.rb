class ActivitiesController < ApplicationController
      
  before_filter :check_authentication
  before_filter :check_admin, {:except => :show}
  
  def index
    @tags = params[:tag_type_id].blank? ? [] : Tag.find_all_by_tag_type_id(params[:tag_type_id])
    @customer = Customer.find(params[:customer_id])    if params[:customer_id] && params[:customer_id] != ""

    page = params[:page] || 1
    @activities = Activity.search(params[:active], params[:default], params[:tag_id], params[:tag_type_id],
      params[:customer_id], params[:project_id], page)
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
  
#  def update_tag
#    tags = params[:tag_type_id] && params[:tag_type_id] != "" ? TagType.find(params[:tag_type_id]).tags : []
#    render :partial => 'tag', :locals => { :tags => tags, :tag_id => '0' }
#  end

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