require 'test_helper'

class HourTypeTest < ActiveSupport::TestCase
 
  should "allow only one default activity" do 
    hour_type = HourType.new(:name => "Foo", :default_hour_type => true)
    assert_false hour_type.save
  end
  
end