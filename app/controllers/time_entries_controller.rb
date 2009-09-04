class TimeEntriesController < ApplicationController
    
  before_filter :check_authentication, :find_user
  
  WEEKDAYS = %w{ Monday Tuesday Wednesday Thursday Friday Saturday Sunday }
       
  def index 
    @date = params[:date].blank? ? Date.today.beginning_of_week : Date.parse(params[:date])
  end
  
  def change_user
    if @current_user.admin
      redirect_to user_time_entries_url(:user_id => params[:new_user_id], :date => params[:date])
    else
      flash[:error] = "Mind your own business"
      redirect_to user_time_entries_url(@current_user, :date => params[:date])
    end
  end
  
  def new
    @time_entry = TimeEntry.new(:date => params[:date])
    @activities = @user.current_activities
    respond_to do |format|
      format.html {}
      format.js { render :template => "/time_entries/time_entries_with_form.rjs" }
    end
  end
    
  def create
    @time_entry = @user.time_entries.build(params[:time_entry])    
    if @time_entry.save
      respond_to do |format|
        format.html {
          flash[:notice] = "Time Entry saved"
          redirect_to user_time_entries_url(@user, :date => @time_entry.date.beginning_of_week)
        }
        format.js { render :template => "/time_entries/time_entries.rjs" }
      end
    else
      @activities = @user.current_activities
      respond_to do |format|
        format.html {
          flash[:error] = "Unable to create time entry"
          render :action => "new"
        }
        format.js { render :template => "/time_entries/time_entries_with_form.rjs" }
      end           
    end 
  end
  
  def edit
    @time_entry = @user.time_entries.find(params[:id])
    @activities = @user.current_activities
    respond_to do |format|
      format.html { }
      format.js { render :template => "/time_entries/time_entries_with_form.rjs" }
    end
  end
    
  def update
    @time_entry = @user.time_entries.find(params[:id])
    if @time_entry.update_attributes(params[:time_entry])
      respond_to do |format|
        format.html {
          flash[:notice] = "Time Entry updated"
          redirect_to user_time_entries_url(@user, :date => @time_entry.date.beginning_of_week)
        }
        format.js { render :template => "/time_entries/time_entries.rjs" }
      end     
    else
      @activities = @user.current_activities
      respond_to do |format|
        format.html {
          flash[:error] = "Unable to update time entry"
          render :action => "edit"          
        }
        format.js { render :template => "/time_entries/time_entries_with_form.rjs" }
      end
    end
  end
  
  def destroy
    @time_entry = @user.time_entries.find(params[:id])
    @time_entry.destroy
    respond_to do |format|
      format.html {
        flash[:notice] = "Time Entry deleted"
        redirect_to user_time_entries_url(@user, :date => @time_entry.date.beginning_of_week)
      }
      format.js { render :template => "/time_entries/time_entries.rjs" }
    end
  end 
  
  def confirm_destroy
    @date = Date.parse(params[:date])
    @time_entry = @user.time_entries.find(params[:id])
  end
  
  def lock_time_entries
    params[:time_entries].each do |id, empty|
      TimeEntry.find(id).update_attribute(:locked, true)
    end
    redirect_to user_month_review_url(:user_id => params[:user_id], :id => :calendar)
  end
  
  private
  
  def find_user
    @user = User.find(params[:user_id])
  end
           
end