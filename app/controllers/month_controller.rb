class MonthController < ApplicationController

  before_filter :check_authentication

  def index
    day = Date.parse(params[:date]) if params[:date]
    day ||= Date.today

    user = current_user_session.user
    @time_entries = user.time_entries.between(day.beginning_of_month, day.end_of_month)
  end
end
