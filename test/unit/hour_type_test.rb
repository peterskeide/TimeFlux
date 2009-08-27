require 'test_helper'

class HourTypeTest < ActiveSupport::TestCase
    
  should_validate_presence_of :name
  
  should "reset the existing default hour type if a new hour type is flagged as default" do
    hour_type = HourType.new(:name => "Foo", :default_hour_type => true)
    hour_type.save
    old_default = HourType.find(hour_types(:normaltid).id)
    assert_false(old_default.default_hour_type)
  end
  
end