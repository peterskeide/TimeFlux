class MonthController < ApplicationController
  
  include Reporting

  before_filter :check_authentication

  def index
    redirect_to(:action => 'calender')
  end

  def listing
    setup_calender
    @user=current_user_session.user
    @from_day = @day
    @to_day = @day.at_end_of_month
    @time_entries = @user.time_entries.between(@from_day,@to_day).group_by(&:activity)
  end

  def update_listing
    day = Date.new(params[:calender]["date(1i)"].to_i, params[:calender]["date(2i)"].to_i,1)
    user = current_user_session.user
    time_entries = user.time_entries.between(day,day.at_end_of_month).group_by(&:activity)
    render :partial => 'listing_content', :locals => { :time_entries => time_entries}
  end


  def calender
    setup_calender
    @user=current_user_session.user
    @activities_summary = create_activity_summary(@day,@user)
  end

  def update_calender
    day = Date.new(params[:calender]["date(1i)"].to_i, params[:calender]["date(2i)"].to_i,1)
    user = current_user_session.user
    activities_summary = create_activity_summary(day,user)
    render :partial => 'calender_content', :locals => { :day => day, :user => user, :activities_summary => activities_summary }
  end

end
