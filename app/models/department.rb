class Department < ActiveRecord::Base

  has_many :users
  has_many :projects

  validates_presence_of :internal_id, :name
  validates_uniqueness_of :internal_id, :name

  def <=>(other)
    name <=> other.name
  end

  def to_s
    name
  end

end
