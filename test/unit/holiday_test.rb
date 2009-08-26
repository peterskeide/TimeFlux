require 'test_helper'

class HolidayTest < ActiveSupport::TestCase

  should "calculate Expected working hours between two dates" do
    expected_hours = Holiday.expected_between(Date.civil(2009,12,22), Date.civil(2009,12,26))
    assert_equal (7.5 * 3) + 4, expected_hours
  end

end
