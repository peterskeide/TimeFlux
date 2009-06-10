class User < ActiveRecord::Base
  
  has_many :week_entries
  has_many :assignments
  has_many :activities, :through => :assignments
  has_many :time_entries, :through => :week_entries
    
  acts_as_authentic
  acts_as_reportable 
   
  validates_presence_of :firstname, :lastname, :username, :password
  validates_uniqueness_of :username

  def fullname
    "#{self.firstname} #{self.lastname}"
  end

  def self.status_values
    %w(active retired m.i.a.)
  end

end