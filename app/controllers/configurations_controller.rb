class ConfigurationsController < ApplicationController

  before_filter :check_authentication, :check_admin

  def index
  end
  
  def update
    TIMEFLUX_CONFIG["time_zone"] = params[:time_zone]
    TIMEFLUX_CONFIG["work_hours"] = params[:work_hours].to_f
    TIMEFLUX_CONFIG["vacation_activity_id"] = params[:vacation_activity_id].to_i
    File.open("config/timeflux.yml", "w") { |f| f.puts TIMEFLUX_CONFIG.to_yaml }
    flash[:notice] = "Configuration updated"
    redirect_to :action => "index"
  end

end