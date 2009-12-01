class Customer < ActiveRecord::Base

  validates_uniqueness_of :name

  has_many :projects
  has_many :activities, :through => :projects
  
  before_destroy :validate_has_no_projects

  named_scope :billable, lambda { |billable|
    { :conditions => { :billable => billable } }
  }

  named_scope :on_letter, lambda { |letter|
    { :conditions => ["name LIKE ?", letter+"%"] }
  }

  def has_unbilled_hours_between(from,to)
     TimeEntry.between(from,to).for_activities(self.activities).billed(false).count > 0
  end

  def <=>(other)
    name <=> other.name
  end
  
  private
  
  def validate_has_no_projects
    unless projects.empty?
      errors.add_to_base("Cannot remove customer with active projects")
      return false
    end
  end

end
