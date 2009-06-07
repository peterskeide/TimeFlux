class User < ActiveRecord::Base
  
  has_many :week_entries
  has_many :assignments
  has_many :activities, :through => :assignments
  
  accept_nested_attributes_for :time_entries
  
end