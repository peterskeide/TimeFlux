class Activity < ActiveRecord::Base

  has_many :time_entries
  has_and_belongs_to_many :users
  has_and_belongs_to_many :tags
  
  validates_presence_of :name
  
  before_destroy :verify_no_time_entries
  
  ACTIVE_OPTIONS = ["any", "true", "false"]
  named_scope :active, lambda { |active|
    if active == "false"
      { :conditions => { :active => false } }
    elsif active == "any"
      { :conditions => {} }
    else
      { :conditions => { :active => true } }
    end
  }
  
  DEFAULT_OPTIONS = ["any", "true", "false"]
  named_scope :default, lambda { |default|
    if default == "false"
      { :conditions => { :default_activity => false } }
    elsif default == "any"
      { :conditions => {} }
    else
      { :conditions => { :default_activity => true } }
    end
  }

  def <=>(other)
    name <=> other.name
  end

  def to_s
    "[Activity: #{name}, id=#{self.id}]"
  end

  private

  def verify_no_time_entries
    unless time_entries.empty?
       errors.add("#{name} has registered hours - could not be removed")
       return false
    end 
  end

end