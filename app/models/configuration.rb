class Configuration < ActiveRecord::Base
  
  belongs_to :activity, :readonly => true
  
  validates_presence_of :work_hours, :time_zone
  
  alias_method :vacation_activity, :activity
  
  def self.instance
    self.first || self.create(:time_zone => "UTC", :work_hours => 7.5)    
  end
  
end