class TimeEntriesController < ApplicationController
    
  before_filter :check_authentication
    
  def index 
    @date = params[:date].blank? ? Date.today.beginning_of_week : Date.parse(params[:date])
    @week = UserWorkWeek.new(@current_user.id, @date)
  end
  
  def new
    @time_entry = @current_user.time_entries.build(:date => params[:date]) 
    @activities = @current_user.current_activities
    respond_to do |format|
      format.html {
        # TODO: standard html handling
      }
      format.js { 
        render :partial => "new_entry" 
      }
    end
  end
  
  def create
    @time_entry = TimeEntry.new(params[:time_entry])
    if @time_entry.save
      respond_to do |format|
        format.html {
          flash[:notice] = "Time Entry saved"
          redirect_to user_time_entries_url(@current_user)
        }
        format.js {
          render :update do |page|
            page.remove "new_entry_form"
            element_id = UserWorkWeek::DAYNAMES[@time_entry.date.cwday - 1]
            page.insert_html :bottom, element_id, :partial => "time_entry", :object => @time_entry
            page.replace_html "#{element_id}_total", TimeEntry.sum_hours_for_user_and_date(@time_entry.user.id, @time_entry.date)
          end
        }
      end
    else
      respond_to do |format|
        format.html {
          # TODO: standard html handling
        }
        format.js {
          @activities = @current_user.current_activities
          render :update do |page|
            page.replace_html :error_messages, "<p class='error'>#{@time_entry.errors.full_messages.to_s}</p>"
          end
        }
      end           
    end 
  end
  
  def edit
    @time_entry = TimeEntry.find(params[:id])
    respond_to do |format|
      format.html {
        # TODO: standard html handling
      }
      format.js {
          render :partial => "edit_form"
      }
    end
  end
  
  def update
    @time_entry = TimeEntry.find(params[:id])
    if @time_entry.update_attributes(params[:time_entry])
      respond_to do |format|
        format.html {
          flash[:notice] = "Time entry updated"
          redirect_to user_time_entries_url(:user_id => params[:user_id], :date => @time_entry.date.beginning_of_week)
        }
        format.js {
          render :update do |page|
            page.replace "show_#{params[:id]}", :partial => "time_entry", :object => @time_entry
            day = UserWorkWeek::DAYNAMES[@time_entry.date.cwday - 1]
            page.replace_html "#{day}_total", TimeEntry.sum_hours_for_user_and_date(@time_entry.user.id, @time_entry.date)
          end 
        }
      end     
    else
      respond_to do |format|
        format.html {
          flash[:error] = @time_entry.errors.full_messages.to_s
          redirect_to user_time_entries_url(:user_id => params[:user_id], :date => @time_entry.date.beginning_of_week)          
        }
        format.js {}
      end
    end
  end
  
  def destroy
  end    
         
end