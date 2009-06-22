class User < ActiveRecord::Base
  
  has_many :time_entries
  has_and_belongs_to_many :activities
    
  acts_as_authentic
  acts_as_reportable 
   
  validates_presence_of :firstname, :lastname, :login, :password
  validates_uniqueness_of :login

  def fullname
    "#{self.firstname} #{self.lastname}"
  end

  def self.status_values
    %w(active retired m.i.a.)
  end

  def hours_total
    total = "hours:"
    self.time_entries.each { |i| puts i.hours }
    return total
  end

end