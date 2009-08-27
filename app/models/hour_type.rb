class HourType < ActiveRecord::Base
  
  has_many :time_entries
  
  validates_uniqueness_of :default_hour_type, :if => lambda { |hour_type| hour_type.default_hour_type == true }
  
end