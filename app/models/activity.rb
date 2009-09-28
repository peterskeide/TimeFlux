class Activity < ActiveRecord::Base

  has_many :time_entries

  has_and_belongs_to_many :tags

  belongs_to :project, :include => :customer
  delegate :customer, :customer=, :to => :project
  
  validates_presence_of :name
  
  before_destroy :verify_no_time_entries
  
  named_scope :active, lambda { |active| 
    active ? { :conditions => { :active => active } } : {}
  }
  
  named_scope :shared, lambda { |shared| 
    shared ? { :conditions => { :shared => shared } } : {}
  }
  
  named_scope :default, lambda { |default| 
    default ? { :conditions => { :default_activity => default } }  : {}
  }

  named_scope :for_tag, lambda { |tag_id| 
    tag_id ? { :joins => :tags, :conditions => ["tags.id = ?", tag_id] } : {}
  }
  
  named_scope :for_tag_type, lambda { |tag_type_id| 
    tag_type_id ? { :joins => :tags, :conditions => ["tags.tag_type_id = ?", tag_type_id] } : {}
  }
  
  named_scope :for_project, lambda { |project_id| 
    project_id ? { :conditions => { :project_id => project_id } } : {}
  }

  named_scope :for_customer, lambda { |customer_id|
    customer_id ? { :include => :project, :conditions => ["projects.customer_id = ?", customer_id] } : {}
  }

  named_scope :templates, :conditions => { :template => true }

  
  def <=>(other)
    name <=> other.name
  end

  def customer_project_name(max_length=999)
    if template
      "#{name} (Template)"
    elsif project == nil
      name
    else
      if customer.name.length + project.name.length + self.name.length < max_length
        "#{customer.name} > #{project.name} > #{name}"
      else
        "#{project.name} > #{name}"
      end
    end
  end

  def to_s
    customer_project_name
  end

  def status
    list = []
    list << "shared" if self.default_activity
    list << "disabled" unless self.active
    return list.join(', ')
  end

  def truncated_name_path(max_characters=29)
    project_characters = max_characters - self.name.size;
    if project != nil
      if project.name.size > project_characters
        "#{project.name.first(project_characters).strip}.. > #{self.name.first(22)}"
      else
        "#{project.name} > #{self.name}"
      end
    else
      self.name
    end
  end

  private

  def verify_no_time_entries
    unless time_entries.empty?
      errors.add("Activities with time entries cannot be removed")
      return false
    end 
  end

end