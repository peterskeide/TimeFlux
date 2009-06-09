class ActivitiesController < ApplicationController
  
  before_filter :check_authentication
  
  def index
    @activities = Activity.find(:all)
  end
  
  def new
    @activity = Activity.new
  end
  
end