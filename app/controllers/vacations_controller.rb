class VacationsController < ApplicationController

  before_filter :check_authentication
  before_filter :check_parent_user, :only => [:edit, :update]

  def index
    @year = params[:year].blank? ? Date.today.year : params[:year].to_i
  end
  
  def edit
    @day = params[:date].blank? ? Date.today.beginning_of_month : Date.parse(params[:date]).at_beginning_of_month    
    @holidays = Holiday.holidays_in_range(@day, @day.end_of_month)
    @others = User.all(:conditions => ["id != ?", @current_user.id]).sort!
  end

  def update
    month = Date.parse(params.delete(:month))
    @current_user.update_vacation!(month, params[:date])
    flash[:notice] = "Vacation updated"
    redirect_to vacations_url(:year => month.year)
  end
  
end