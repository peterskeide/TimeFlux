class TimeEntriesController < ApplicationController
    
  before_filter :check_authentication
  before_filter :check_parent_user, :except => :change_user
  before_filter :find_user, :except => :add_tag
  
  WEEKDAYS = %w{ Monday Tuesday Wednesday Thursday Friday Saturday Sunday }
       
  def index 
    @date = params[:date].blank? ? Date.today.beginning_of_week : Date.parse(params[:date]).beginning_of_week
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
    date = Date.parse(params[:date])
    @time_entry = TimeEntry.new(:date => date)
    @activities = @user.current_activities(date)
    respond_to do |format|
      format.html {}
      format.js { render :template => "/time_entries/time_entries_with_form.rjs" }
    end
  end
    
  def create
    @time_entry = @user.time_entries.build(params[:time_entry])
    if params[:tags].respond_to? :each
      params[:tags].each { |id, value| @time_entry.tags << Tag.find(id.to_i) if value == 'true'}
    end
    if @time_entry.save
      respond_to do |format|
        format.html {
          flash[:notice] = "Time Entry saved"
          redirect_to user_time_entries_url(@user, :date => @time_entry.date.beginning_of_week)
        }
        format.js { render :template => "/time_entries/time_entries.rjs" }
      end
    else
      @activities = @user.current_activities(@time_entry.date)
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
    @activities = @user.current_activities(@time_entry.date)
    respond_to do |format|
      format.html { }
      format.js { render :template => "/time_entries/time_entries_with_form.rjs" }
    end
  end
    
  def update
    @time_entry = @user.time_entries.find(params[:id])

    if params[:tags].respond_to? :each
      tags = []
      params[:tags].each { |id, value| tags << Tag.find(id.to_i) if value == 'true'}
      @time_entry.tags = tags
    end
    if @time_entry.update_attributes(params[:time_entry])
      respond_to do |format|
        format.html {
          flash[:notice] = "Time Entry updated"
          redirect_to user_time_entries_url(@user, :date => @time_entry.date.beginning_of_week)
        }
        format.js { render :template => "/time_entries/time_entries.rjs" }
      end     
    else
      @activities = @user.current_activities(@time_entry.date)
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
  
  def lock
    @start = Date.parse(params[:start_date])
    @end = Date.parse(params[:end_date])
    @user.time_entries.between(@start, @end).each { |te| te.update_attribute(:status, TimeEntry::LOCKED) }
    redirect_to user_month_review_url(:user_id => params[:user_id], :id => :calendar)
  end

  private
  
  def find_user
    @user = User.find(params[:user_id])
  end
           
end