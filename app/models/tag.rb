class Tag < ActiveRecord::Base 
  
  belongs_to :tag_type
  has_and_belongs_to_many :activities
  
  validates_presence_of :tag_type, :name
  validates_uniqueness_of :name, :scope => :tag_type_id

  def name_and_type
    "#{tag_type.name} - #{name}"
  end

  def to_s
    #"#{self.tag_type.to_s}: #{self.name}"
    name
  end

  def <=>(other)
    [tag_type.name, name] <=> [other.tag_type.name, other.name]
  end

end