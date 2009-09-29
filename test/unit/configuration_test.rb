require 'test_helper'

class ConfigurationTest < ActiveSupport::TestCase
  
  context "A Configuration instance" do
    subject { Configuration.instance }
    should_validate_presence_of :work_hours, :time_zone
  end
  
  context "When no configuration exists" do
    
    context "the instance method" do
      
      should "return a configuration instance" do
        assert !Configuration.instance.nil?
      end

      should "create new instance with default values for time_zone and work_hours" do
        assert_difference("Configuration.count", 1) { Configuration.instance }
        assert_equal("UTC", Configuration.instance.time_zone)
        assert_equal(7.5, Configuration.instance.work_hours)
      end
      
    end
    
  end
  
  context "When configuration already exists" do
    
    context "The instance method" do

      should "not create a new configuration instance" do
        Configuration.instance
        assert_no_difference("Configuration.count") { Configuration.instance }
      end

    end
    
  end
    
end