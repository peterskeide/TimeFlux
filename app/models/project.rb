class Project < ActiveRecord::Base

   validates_uniqueness_of :name, :scope => :customer_id
   has_many :activities
   belongs_to :customer

end
