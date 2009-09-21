class Customer < ActiveRecord::Base

  validates_uniqueness_of :name

  has_many :projects
  has_many :activities,     :through => :projects

  named_scope :billable, lambda { |billable|
    { :conditions => { :billable => billable } }
  }


  def <=>(other)
    name <=> other.name
  end

end
