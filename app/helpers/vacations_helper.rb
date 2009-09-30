module VacationsHelper
  
  def week_headings
    iterator = @day
    content = tag(:td)
    if iterator.cwday > 5
      (8 - iterator.cwday).times do
        iterator = iterator + 1
        content << tag(:td)
      end
    end
    days_in_first_week = 8-iterator.cwday
    content << content_tag(:th, iterator.cweek, :colspan => "#{days_in_first_week - 2}", :class => "week")
    content << tag(:td)
    content << tag(:td)
    iterator = iterator + days_in_first_week
    iterator.step( @day.at_end_of_month, 7) do |d|
      days_left = @day.at_end_of_month - d
      content << content_tag(:th, d.cweek, :colspan => "#{days_left >= 5 ? 5 : days_left + 1}", :class => "week")
      content << tag(:td)
	    content << tag(:td)
    end
    content
  end
  
  def day_headings
    content = tag(:td)
    @day.at_beginning_of_month.upto @day.at_end_of_month do |d|
      if @is_holiday[d]
        content << content_tag(:th, d.day, :class => "error")
      else
        content << content_tag(:th, d.day)
      end
    end
    content
  end
  
  def days_of_month_for_user(user)
    @vacation_dates = user.time_entries.for_activity(Configuration.instance.vacation_activity).between(@day.at_beginning_of_month, @day.at_end_of_month).collect{|entry| entry.date}
    @days_of_month ||= (@day.at_beginning_of_month..@day.at_end_of_month)
  end
  
  def check_box_tag_unless_holiday_or_weekend(day)
    unless @is_holiday[day]
      check_box_tag  "date[#{ day }]", '1', @vacation_dates.include?(day)
    end
  end
  
  def disabled_check_box_or_dash_unless_holiday_or_weekend(day)
    if @vacation_dates.include?(day)
      tag(:input, {:type => "checkbox", :checked => "1", :disabled => "true"})
    elsif !@is_holiday[day]
      content_tag(:span, "-", :class => "disabled")
    end
  end

end