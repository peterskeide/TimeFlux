class Project < ActiveRecord::Base

   validates_uniqueness_of :name, :scope => :customer_id
   belongs_to :customer

end
