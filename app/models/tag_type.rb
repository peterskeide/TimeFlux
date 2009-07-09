class TagType < ActiveRecord::Base
  
  has_many :tags

  def to_s
    self.name
  end

  #Rails does not support has many :through habtm yet
  def activities
      self.tags.collect { |tag| tag.activities }.flatten
  end

  def activities_filtered(filter=:all)
    if filter == :all then
      self.activities
    elsif filter == :active then
      self.activities.select{ |a| a.active == true }
    elsif filter == :passive then
      self.activities.select{ |a| a.active == false }
    else
      return []
    end
  end
end