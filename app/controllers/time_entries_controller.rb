class TimeEntriesController < ApplicationController
    
  before_filter :check_authentication, :find_user
  
  WEEKDAYS = %w{ Monday Tuesday Wednesday Thursday Friday Saturday Sunday }
       
  def index 
    @date = params[:date].blank? ? Date.today.beginning_of_week : parse_date
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
      format.js {
        render :update do |page|
          page.select(".new_time_entry_link").each { |element| element.hide }
          page.replace_html "#{@time_entry.weekday}_time_entry_form", :partial => "new_entry"
        end 
        }
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
            page.select(".new_time_entry_link").each { |element| element.show }
            page.remove "new_time_entry"
            day = @time_entry.weekday
            time_entries = TimeEntry.find_all_by_user_id_and_date(@user.id, @time_entry.date)
            page.replace_html "#{day}_time_entries_container", :partial => "time_entries", :locals => { :time_entries => time_entries, :day => day }
            page.replace_html "#{day}_total", "<b>#{TimeEntry.sum_hours_for_user_and_date(@user.id, @time_entry.date)}</b>"
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
            page.replace_html "new_time_entry_error_messages", "<p class='error'>#{@time_entry.errors.full_messages.to_s}</p>"
          end
        }
      end           
    end 
  end
  
  def edit
    @time_entry = @user.time_entries.find(params[:id])
    @editing_id = @time_entry.id
    @activities = @user.current_activities
    respond_to do |format|
      format.html { }
      format.js { 
        render :update do |page|
          day = @time_entry.weekday
          time_entries = TimeEntry.find_all_by_user_id_and_date(@user.id, @time_entry.date)
          page.replace_html "#{day}_time_entries_container", :partial => "edit_time_entry", :locals => { :time_entries => time_entries, :day => day }
        end 
      }
    end
  end
  
  def cancel_edit
    respond_to do |format|
      format.js { 
        render :update do |page|
          time_entry = @user.time_entries.find(params[:id])
          day = params[:day]
          time_entries = TimeEntry.find_all_by_user_id_and_date(@user.id, time_entry.date)
          page.replace_html "#{day}_time_entries_container", :partial => "time_entries", :locals => { :time_entries => time_entries, :day => day }
        end 
      }
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
        format.js {
          render :update do |page|
            day = @time_entry.weekday
            time_entries = TimeEntry.find_all_by_user_id_and_date(@user.id, @time_entry.date)
            page.replace_html "#{day}_time_entries_container", :partial => "time_entries", :locals => { :time_entries => time_entries, :day => day }
            page.replace_html "#{@time_entry.weekday}_total", "<b>#{TimeEntry.sum_hours_for_user_and_date(@user.id, @time_entry.date)}</b>"
          end 
        }
      end     
    else
      @activities = @user.current_activities
      respond_to do |format|
        format.html {
          flash[:error] = "Unable to update time entry"
          render :action => "edit"          
        }
        format.js {
          render :update do |page|
            page.replace_html "#{@time_entry.weekday}_edit_time_entry_error_messages", "<p class='error'>#{@time_entry.errors.full_messages.to_s}</p>"
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
        flash[:notice] = "Time Entry deleted"
        redirect_to user_time_entries_url(@user, :date => @time_entry.date.beginning_of_week)
      }
      format.js {
        render :update do |page|
          day = @time_entry.weekday
          time_entries = TimeEntry.find_all_by_user_id_and_date(@user.id, @time_entry.date)
          page.replace_html "#{day}_time_entries_container", :partial => "time_entries", :locals => { :time_entries => time_entries, :day => day }
          page.replace_html "#{@time_entry.weekday}_total", "<b>#{TimeEntry.sum_hours_for_user_and_date(@user.id, @time_entry.date)}</b>"
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
  
  def parse_date
    if params[:date].is_a? Hash
      return Date.parse("#{params[:date][:year]}-#{params[:date][:month]}-#{params[:date][:day]}").beginning_of_week
    else
      return Date.parse(params[:date])
    end
  end    
         
end