class Activity < ActiveRecord::Base
  
  belongs_to :category
  has_many :time_entries
  
end