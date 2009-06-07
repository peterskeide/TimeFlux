class ActivitiesController < ApplicationController
  
  def index
    @activities = Activity.find(:all)
  end
  
  def new
    @activity = Activity.new
  end
  
end