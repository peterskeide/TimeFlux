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

  named_scope :between_letters, lambda { |from,to|
    { :conditions => { :name => (from..to)} }
  }

  def self.find_by_letter_range(from, to, options = {})
    conditions = case from 
      when "*" then {}
      when nil then {:name => ('A'..'E')}
      else {:name => (from..(to.next))}
    end
    paginate :per_page => options[:per_page], :page => options[:page],
       :order => 'name',
       :conditions => conditions.merge(:billable => true)
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
