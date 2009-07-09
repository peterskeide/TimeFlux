class Activity < ActiveRecord::Base

  has_many :time_entries
  has_and_belongs_to_many :users
  has_and_belongs_to_many :tags
  
  validates_presence_of :name
  
  before_destroy :verify_no_time_entries



  named_scope :for_tag, lambda { |tag_id|

      { :joins => 'INNER JOIN "activities_tags" ON "tags".id = "activities_tags".tag_id',
      }

  }

  named_scope :filtered, lambda { |filter|
    if filter == :passive then
      { :conditions => { :active => false } }
    elsif filter == :all then
      { :conditions => {} }
    else
      { :conditions => { :active => true } }
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