class HourTypesController < ApplicationController
  
  before_filter :check_authentication, :check_admin
  
  def index
    @hour_types = HourType.all(:order => "default_hour_type DESC")
  end
    
  def new
    @hour_type = HourType.new
  end
  
  def create
    @hour_type = HourType.new(params[:hour_type])
    if @hour_type.save
      flash[:notice] = "Hour Type created"
      redirect_to hour_types_url
    else
      flash[:error] = "Unable to create Hour Type"
      render :new
    end
  end
  
  def edit
    begin
      @hour_type = HourType.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      flash[:error] = "The requested resource does not exist"
      redirect_to hour_types_url  
    end
  end
  
  def update
    begin
      @hour_type = HourType.find(params[:id])
      if @hour_type.update_attributes(params[:hour_type])
        flash[:notice] = "Hour Type updated"
        redirect_to hour_types_url
      else
        flash[:error] = "Unable to update Hour Type"
        render :edit
      end
    rescue ActiveRecord::RecordNotFound
      flash[:error] = "The requested resource does not exist"
      redirect_to hour_types_url  
    end
  end
  
  def destroy
    @hour_type = HourType.find_by_id(params[:id])
    @hour_type.destroy
    flash[:notice] = "Hour Type deleted"
    redirect_to hour_types_url
  end
  
end