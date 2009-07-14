class Tag < ActiveRecord::Base 
  
  belongs_to :tag_type
  belongs_to :tag
  has_and_belongs_to_many :activities
  
  validates_presence_of :tag_type, :name
  validates_uniqueness_of :name, :scope => :tag_type_id

  def name_and_type
    "#{self.tag_type.to_s} - #{self.name}"
  end

  def tag_type_name
    if self.tag_type
      self.tag_type.name
    else
      "no type"
    end
  end

  def to_s
    "#{self.tag_type.to_s}: #{self.name}"
  end

end