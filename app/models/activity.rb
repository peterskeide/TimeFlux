class Activity < ActiveRecord::Base

  has_many :time_entries

  belongs_to :project, :include => :customer
  delegate :customer, :customer=, :to => :project

  has_and_belongs_to_many :users
  has_and_belongs_to_many :tags
  
  validates_presence_of :name, :tags
  
  before_destroy :verify_no_time_entries
  
  named_scope :active, lambda { |active| { :conditions => { :active => active } } }
  named_scope :shared, lambda { |shared| { :conditions => { :shared => shared } } }
  named_scope :default, lambda { |default| { :conditions => { :default_activity => default } } }
  named_scope :for_tag, lambda { |tag_id| { :joins => :tags, :conditions => ["tags.id = ?", tag_id] } }  
  named_scope :for_tag_type, lambda { |tag_type_id| { :joins => :tags, :conditions => ["tags.tag_type_id = ?", tag_type_id] } }
  named_scope :for_project, lambda { |project_id| { :conditions => { :project_id => project_id } } }

  named_scope :for_customer, lambda { |customer_id|
    { :include => :project, :conditions => ["projects.customer_id = ?", customer_id] }
  }

  def self.find_by_filter(tag_type_id, tag_id, customer_id, project_id)
    search = ["Activity"]
    unless tag_id.blank?
      search << "for_tag(#{tag_id})" 
    else
      search << "for_tag_type(#{tag_type_id})" unless tag_type_id.blank?
    end
    
    unless project_id.blank?
      search << "for_project(#{project_id})"
    else
      search << "for_customer(#{customer_id})" unless customer_id.blank?
    end

    search << "all" if search.size == 1

    query = search.join(".")
    logger.debug("Activity filter Query: #{query}")
    eval query
  end

  def self.search(active, default, tag_id, tag_type_id, customer_id, project_id, page)
    search = ["Activity"]
    search << "active(#{active})" unless active.blank?
    search << "default(#{default})" unless default.blank?
    unless project_id.blank?
      search << "for_project(#{project_id})"
    else
      search << "for_customer(#{customer_id})" unless customer_id.blank?
    end

    unless tag_id.blank?
      search << "for_tag(#{tag_id})" 
    else
      search << "for_tag_type(#{tag_type_id})" unless tag_type_id.blank?
    end
    search << "paginate(:page => #{page}, :per_page => 10, :order => 'activities.name')"
    query = search.join(".")
    logger.debug("Activity Search Query: #{query}")
    eval query
  end
  
  def <=>(other)
    name <=> other.name
  end

  def customer_project_name
    if project == nil
      name
    else
      "#{customer.name} > #{project.name} > #{name}"
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