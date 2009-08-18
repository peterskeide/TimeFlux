class TimeEntriesController < ApplicationController
    
  before_filter :check_authentication
    
  def index
    if params[:date].blank?
      @date = Date.today.beginning_of_week
    else
      @date = Date.parse(params[:date])
    end
    @time_entries = []
  end
  
  def new
    @time_entry = TimeEntry.new
    @activity_names_and_ids = []
  end
  
  def create
    @time_entry = TimeEntry.new(params[:time_entry])
    if @time_entry.save
      flash[:notice] = "Time Entry saved"
      redirect_to user_time_entries_url(@current_user)
    else
      @activity_names_and_ids = []
      render :new
    end  
  end
  
  def edit
  end
  
  def update
  end
  
  def destroy
  end
         
end