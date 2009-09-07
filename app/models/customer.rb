class Customer < ActiveRecord::Base

  validates_uniqueness_of :name

  has_many :projects
  has_many :activities,     :through => :projects

  def <=>(other)
    name <=> other.name
  end

end
