class Activity < ActiveRecord::Base

  has_many :time_entries
  has_and_belongs_to_many :users
  has_and_belongs_to_many :tags
  
  validates_presence_of :name
  
  before_destroy :verify_no_time_entries

  named_scope :active, lambda { |active|
    if active == :passive then
      { :conditions => { :active => false } }
    elsif active == :all then
      { :conditions => {} }
    else
      { :conditions => { :active => true } }
    end
  }

  named_scope :default, lambda { |default|
    if default == :default then
      { :conditions => { :default_activity => true } }
    elsif default == :all then
      { :conditions => {} }
    else
      { :conditions => { :default_activity => false } }
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