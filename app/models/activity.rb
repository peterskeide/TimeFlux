class Activity < ActiveRecord::Base

  has_many :time_entries
  has_and_belongs_to_many :users
  has_and_belongs_to_many :tags
  
  validates_presence_of :name
  
  before_destroy :verify_no_time_entries
  
  PAGINATION_OPTIONS = { :per_page => 10, :order => "activities.name" }
  BOOLEAN_OPTIONS = ["any", "true", "false"]
  
  named_scope :active, lambda { |active|
    if active == "false"
      { :conditions => { :active => false } }
    elsif active == "any"
      { :conditions => {} }
    else
      { :conditions => { :active => true } }
    end
  }
  
  named_scope :default, lambda { |default|
    if default == "false"
      { :conditions => { :default_activity => false } }
    elsif default == "any"
      { :conditions => {} }
    else
      { :conditions => { :default_activity => true } }
    end
  }
  
  named_scope :for_tag, lambda { |tag_id|
     {:joins => :tags, :conditions => ["tags.id = ?", tag_id]}
  }
  
  named_scope :for_tag_type, lambda { |tag_type_id|
     {:joins => :tags, :conditions => ["tags.tag_type_id = ?", tag_type_id]}
  }
    
  def self.search(active_option = "any", default_option = "any", tag = nil, tag_type = nil, page = 1)
    PAGINATION_OPTIONS[:page]= page
     if tag
       return self.for_tag(tag.id).active(active_option).default(default_option).paginate(PAGINATION_OPTIONS)
     elsif tag_type
       return self.for_tag_type(tag_type.id).active(active_option).default(default_option).paginate(PAGINATION_OPTIONS)
     else
       return self.active(active_option).default(default_option).paginate(PAGINATION_OPTIONS)
     end
  end
  
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