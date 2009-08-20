class Customer < ActiveRecord::Base

    validates_uniqueness_of :name

    has_many :projects
end
