require 'test_helper'

class CustomerTest < ActiveSupport::TestCase
  
  should "not be destroyed if it has projects" do
    customer = Customer.new(:name => "Foo")
    customer.projects << Project.first
    customer.save
    assert(!customer.destroy)
    assert(customer.errors.entries.flatten.include?("Cannot remove customer with active projects"))
  end
  
end
