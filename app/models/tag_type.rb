class TagType < ActiveRecord::Base
  has_many :tags

  def to_s
    self.name
  end 
  
end