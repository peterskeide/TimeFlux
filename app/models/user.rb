class User < ActiveRecord::Base
  
  has_many :week_entries
  has_many :assignments
  has_many :activities, :through => :assignments
    
  acts_as_authentic
  
end