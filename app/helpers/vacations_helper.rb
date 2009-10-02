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
    iterator.step(@day.at_end_of_month, 7) do |d|
      days_left = @day.at_end_of_month - d
      content << content_tag(:th, d.cweek, :colspan => "#{days_left >= 5 ? 5 : days_left + 1}", :class => "week")
      content << tag(:td)
	    content << tag(:td)
    end
    content
  end
  
  def day_headings
    content = tag(:td)
    @day.upto @day.at_end_of_month do |d|
      if @holidays.include? d
        content << content_tag(:th, d.day, :class => "error")
      else
        content << content_tag(:th, d.day)
      end
    end
    content
  end
  
  def days_of_month_for_user(user)
    vacation_entries = user.time_entries.for_activity(Configuration.instance.vacation_activity).between(@day, @day.at_end_of_month)
    @dates_and_entries = {}
    vacation_entries.each do |te|
      @dates_and_entries[te.date] = te
    end
    @days_of_month ||= (@day..@day.at_end_of_month)
  end
  
  def check_box_tag_unless_holiday_or_weekend(day)
    unless @holidays.include? day
      check_box_tag "dates[#{ day }]", '1', @dates_and_entries.keys.include?(day), :disabled => @dates_and_entries[day] && @dates_and_entries[day].locked
    end
  end
  
  def disabled_check_box_or_dash_unless_holiday_or_weekend(day)
    if @dates_and_entries.keys.include?(day)
      tag(:input, {:type => "checkbox", :checked => "1", :disabled => "true"})
    elsif !@holidays.include? day
      content_tag(:span, "-", :class => "disabled")
    end
  end
  
  def vacation_overview_for_user(user, &block)
    concat("<tr style='background-color: #{ user == @current_user ? '#BBCCFF' : cycle('#FFFFFF', '#DDDDDD') }'>")
    yield
    concat("</tr>")
  end

end