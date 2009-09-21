class ConfigurationsController < ApplicationController

  before_filter :check_authentication, :check_admin

  def index

  end

end
