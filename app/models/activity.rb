class Activity < ActiveRecord::Base

  has_many :time_entries
  belongs_to :project
  has_and_belongs_to_many :users
  has_and_belongs_to_many :tags
  
  validates_presence_of :name, :tags
  
  before_destroy :verify_no_time_entries
  
  named_scope :active, lambda { |active| { :conditions => { :active => active } } }
  named_scope :shared, lambda { |shared| { :conditions => { :shared => shared } } }
  named_scope :default, lambda { |default| { :conditions => { :default_activity => default } } }
  named_scope :for_tag, lambda { |tag_id| { :joins => :tags, :conditions => ["tags.id = ?", tag_id] } }  
  named_scope :for_tag_type, lambda { |tag_type_id| { :joins => :tags, :conditions => ["tags.tag_type_id = ?", tag_type_id] } }
   
  def self.search(active, default, tag_id, tag_type_id, page)
    search = ["Activity"]
    search << "active(#{active})" unless active.blank?
    search << "default(#{default})" unless default.blank?
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
#
#  def to_s
#    "[Activity: #{name}, id=#{self.id}]"
#  end

  private

  def verify_no_time_entries
    unless time_entries.empty?
       errors.add("#{name} has registered hours - could not be removed")
       return false
    end 
  end

end