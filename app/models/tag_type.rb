class TagType < ActiveRecord::Base
  has_many :tags
  #has_many :activities, :through => :tags

  def to_s
    self.name
  end

  #Rails does not support has many :through habtm yet
  def activities
    self.tags.collect { |tag| tag.activities }
  end

  private

  
end
