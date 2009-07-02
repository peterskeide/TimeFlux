require 'net/ldap'

class User < ActiveRecord::Base
  
  TimeFlux.configure self
    
  has_many :time_entries
  has_and_belongs_to_many :activities
     
  validates_presence_of :firstname, :lastname, :login
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

  def hours_on_day(day)
    entries = self.time_entries.on_day day
    hours = entries.collect{|t| t.hours}.sum
    if hours > 0 then hours.to_s else '-' end
  end

  def <=>(other)
    lastname <=> other.lastname
  end

  def to_s
    "#{self.fullname} (id=#{self.object_id})"
  end

end