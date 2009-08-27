class HourType < ActiveRecord::Base
  
  has_many :time_entries
  
  validates_presence_of :name
  
  before_save :reset_existing_default
  
  private
  
  def reset_existing_default
    if default_hour_type
      HourType.find_by_default_hour_type(true).update_attribute(:default_hour_type, false) 
    end
  end
  
end