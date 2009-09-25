require 'test_helper'

class ProjectTest < ActiveSupport::TestCase
  
  context "A Project instance" do
    
    setup { @project = Project.create(:name => "TestProject") }
    
    context "with activities" do
      
      setup {
        @project.activities.create(:name => "ActivityOne")
        @project.activities.create(:name => "ActivityTwo")
      }
      
      should "not be destroyed" do
        assert(!@project.destroy)
        assert_equal("Projects with activities cannot be removed", @project.errors.entries[0][1])
      end
      
    end
    
  end
    
end