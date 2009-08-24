class TimeEntriesController < ApplicationController
    
  before_filter :check_authentication, :find_user
    
  def index 
    @date = params[:date].blank? ? Date.today.beginning_of_week : Date.parse(params[:date])
    @week = UserWorkWeek.new(@user.id, @date)
  end
  
  def change_user
    if @current_user.admin
      redirect_to user_time_entries_url(:user_id => params[:new_user_id])
    else
      redirect_to user_time_entries_url(@current_user)
    end
  end
  
  def new
    @time_entry = TimeEntry.new(:date => params[:date]) 
    @activities = @user.current_activities
    respond_to do |format|
      format.html {}
      format.js { render :partial => "new_entry" }
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
        format.js {
          render :update do |page|
            page.remove "new_entry_form"
            day = UserWorkWeek::DAYNAMES[@time_entry.date.cwday - 1]
            page.insert_html :bottom, "#{day}_time_entries", :partial => "time_entry", :object => @time_entry
            page.replace_html "#{day}_total", TimeEntry.sum_hours_for_user_and_date(@user.id, @time_entry.date)
          end
        }
      end
    else
      @activities = @user.current_activities
      respond_to do |format|
        format.html {
          flash[:error] = "Unable to create time entry"
          render :action => "new"
        }
        format.js {
          render :update do |page|
            page.replace_html :error_messages, "<p class='error'>#{@time_entry.errors.full_messages.to_s}</p>"
          end
        }
      end           
    end 
  end
  
  def edit
    @time_entry = @user.time_entries.find(params[:id])
    respond_to do |format|
      format.html { @activities = @user.current_activities }
      format.js { render :partial => "edit_form" }
    end
  end
  
  def update
    @time_entry = @user.time_entries.find(params[:id])
    if @time_entry.update_attributes(params[:time_entry])
      respond_to do |format|
        format.html {
          flash[:notice] = "Time entry updated"
          redirect_to user_time_entries_url(@user, :date => @time_entry.date.beginning_of_week)
        }
        format.js {
          render :update do |page|
            page.replace "show_#{params[:id]}", :partial => "time_entry", :object => @time_entry
            day = UserWorkWeek::DAYNAMES[@time_entry.date.cwday - 1]
            page.replace_html "#{day}_total", TimeEntry.sum_hours_for_user_and_date(@user.id, @time_entry.date)
          end 
        }
      end     
    else
      respond_to do |format|
        format.html {
          flash[:error] = "Unable to update time entry"
          render :action => "edit"          
        }
        format.js {
          render :update do |page|
            page.replace_html :error_messages, "<p class='error'>#{@time_entry.errors.full_messages.to_s}</p>"
          end
        }
      end
    end
  end
  
  def destroy
    @time_entry = @user.time_entries.find(params[:id])
    @time_entry.destroy
    respond_to do |format|
      format.html {
        flash[:notice] = "Time entry deleted"
        redirect_to user_time_entries_url(@user, :date => @time_entry.date.beginning_of_week)
      }
      format.js {
        render :update do |page|
          page.remove "show_#{@time_entry.id}"
          day = UserWorkWeek::DAYNAMES[@time_entry.date.cwday - 1]
          page.replace_html "#{day}_total", TimeEntry.sum_hours_for_user_and_date(@user.id, @time_entry.date)
        end
      }
    end
  end 
  
  def confirm_destroy
    @date = Date.parse(params[:date])
    @time_entry = @user.time_entries.find(params[:id])
  end
  
  private
  
  def find_user
    @user = User.find(params[:user_id])
  end    
         
end