class Customer < ActiveRecord::Base

  validates_uniqueness_of :name

  has_many :projects
  has_many :activities, :through => :projects
  
  before_destroy :validate_has_no_projects

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
