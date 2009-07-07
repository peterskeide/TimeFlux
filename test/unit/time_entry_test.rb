require 'test_helper'

class TimeEntryTest < ActiveSupport::TestCase
  
  test 'should find 1 time_entry on day 1. july, 2009' do
    entries = TimeEntry.on_day( Date.new(2009,7,1) )
    assert_equal entries.size, 1
  end

  test 'should find 2 time_entries between 1st and 2nd of july, 2009' do
    entries = TimeEntry.between( Date.new(2009,7,1), Date.new(2009,7,2) )
    assert_equal entries.size, 2
  end

  test 'should find hours for activity' do
    entries = TimeEntry.for_activity(activities(:timeflux_development).id)
    assert_operator entries.size, :>, 0
    assert_equal entries.size, activities(:timeflux_development).time_entries.size
  end

  test 'should find Bob´s hours' do
    entries = TimeEntry.for_user(users(:bob).id)
    assert_operator entries.size, :>, 0
    assert_equal entries.size, users(:bob).time_entries.size
  end
  
end