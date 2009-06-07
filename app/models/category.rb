class Category < ActiveRecord::Base
  
  has_many :activities
  
  validates_presence_of :name, :message => "can not be empty"
  validates_uniqueness_of :name, :case_sensitive => false, :message => "must be unique"
  
end