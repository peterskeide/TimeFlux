class Configuration < ActiveRecord::Base
  
  belongs_to :activity, :readonly => true  
  validates_presence_of :work_hours, :time_zone
  
  alias_method :vacation_activity, :activity
  private_class_method :new, :create, :find, :first, :last, :all
  
  # Returns the first (and only) row from the configurations table.
  # If no configuration exists, a new row will be created with default
  # values for time_zone and work_hours.
  #
  # This is the only method that should be used to access the TimeFlux
  # configuration. Some of the common methods of accessing or creating an
  # ActiveRecord model have been declared private to make it a little bit
  # more dificult to break this rule.
  def self.instance
    first || create(:time_zone => "UTC", :work_hours => 7.5)    
  end
   
end