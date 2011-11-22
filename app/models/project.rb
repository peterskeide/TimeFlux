class Project < ActiveRecord::Base
   
  has_many :activities
  belongs_to :customer
  belongs_to :department
  has_and_belongs_to_many :users
   
  validates_uniqueness_of :name, :scope => :customer_id
  validates_length_of :comment, :maximum => 1024, :allow_nil => true

   
  before_destroy :validate_has_no_activities

  named_scope :for_customer, lambda { |customers|
    customers ? {  :conditions =>  { :customer_id => customers } } : {}
  }

  def <=>(other)
    [customer.name,name] <=> [other.customer.name,other.name]
  end


  private
   
  def validate_has_no_activities
    unless activities.empty?
      errors.add_to_base("Projects with activities cannot be removed")
      return false
    end
  end
   
end
