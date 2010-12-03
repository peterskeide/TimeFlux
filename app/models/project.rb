class Project < ActiveRecord::Base
   
  has_many :activities
  belongs_to :customer
  has_and_belongs_to_many :users
   
  validates_uniqueness_of :name, :scope => :customer_id
   
  before_destroy :validate_has_no_activities


  def <=>(other)
    customer.name <=> other.customer.name
  end


  private
   
  def validate_has_no_activities
    unless activities.empty?
      errors.add_to_base("Projects with activities cannot be removed")
      return false
    end
  end
   
end
