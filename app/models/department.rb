class Department < ActiveRecord::Base

  has_many :users

  validates_presence_of :internal_id, :name
  validates_uniqueness_of :internal_id, :name

end
