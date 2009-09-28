class ConfigurationsController < ApplicationController

  before_filter :check_authentication, :check_admin

  def edit
    @config = Configuration.instance
  end
  
  def update
    if Configuration.instance.update_attributes(params[:configuration])
      flash[:notice] = "Configuration updated"      
    else
      flash[:notice] = "Failed to update configuration"     
    end
    redirect_to edit_configuration_url
  end

end