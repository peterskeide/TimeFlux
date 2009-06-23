class Tag < ActiveRecord::Base
  belongs_to :tag_type
  belongs_to :tag
  has_and_belongs_to_many :activities

  def name_and_type
    "#{self.tag_type.to_s} - #{self.name}"
  end

  def to_s
    "#{self.tag_type.to_s}: #{self.name}"
  end
end
