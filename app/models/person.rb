class Person < ActiveRecord::Base
  
  has_many :time_entries
  has_many :assignments
  has_many :projects, :through => :assignments
  
  accept_nested_attributes_for :time_entries
  
end