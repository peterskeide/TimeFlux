module Reporting
   
  #Used in review and report and holiday controller
  def setup_calender
    if params[:calender]
      year = params[:calender]["date(1i)"].to_i
      month = params[:calender]["date(2i)"].to_i
    else
      year = params[:year].to_i if params[:year] && params[:year] != ""
      month = params[:month].to_i if params[:month] && params[:month] != ""
    end
    relevant_date = Date.today - 7
    @day = Date.new(year ? year : relevant_date.year, month ? month : relevant_date.month, 1)

    @years = (2007..Date.today.year).to_a.reverse
    @months = []
    @month_names = %w{ January Febrary March April May June July August September October November December}
    @month_names.each_with_index { |name, i| @months << [ i+1, name ] }
  end

  # Sets the date to the last in month if the supplied date is higher.
  # Example 2009,2,31 returns Date.civil(2009,2,28)
  #
  def set_date(year, month, day)
    max_day = Date.civil(year,month,1).at_end_of_month.mday
    Date.civil(year,month, day > max_day ? max_day : day)
  end

  # Finds the instance of class <tt>symbol<tt>, with the id of params[symbol]
  # Example for symbol :user -> returns User.find(params[:user]) or nil if param or user does not exsist
  #
  def param_instance(symbol)
    Kernel.const_get(symbol.to_s.camelcase).find(params[symbol])  if params[symbol] && params[symbol] != ""
  end

  # Prawnto arguments for creating a plain A4 page with sensible margins
  #
  def prawn_params
    {
      :page_size => 'A4',
      :left_margin => 50,
      :right_margin => 50,
      :top_margin => 24,
      :bottom_margin => 24 }
  end

  #Used in month and report controller
  #TODO Remove once Ruport is not used
  def respond_with_formatter(table, formatter, title="report", pdf_options={})

    conv = ReportConverter

    respond_to do |format|
      format.html do
        @title = title
        @table = table
      end

      format.pdf do
        send_data(formatter.render_pdf({ :data => conv.convert(table), :title => conv.convert_string(title)}.merge(pdf_options)),
          { :type => "	application/pdf", :disposition  => "inline", :filename => "#{title}.pdf" })
      end
      format.csv do
        send_data formatter.render_csv(:data => conv.convert(table), :title => conv.convert_string(title)),
          { :type => "	text/plain", :disposition  => "inline", :filename => "#{title}.csv" }
      end
      format.text do
        send_data formatter.render(:text, :data => conv.convert(table), :title => conv.convert_string(title)),
          { :type => "	text/plain", :disposition  => "inline", :filename => "#{title}.txt" }
      end
    end
  end

  #month -> calsender and report -> calender
  # TODO move this to month once reports user month´s calender
  def create_activity_summary(day, user=current_user_session.user)
    activities = user.time_entries.between(day,day.at_end_of_month).distinct_activities.map do |t|
      t.activity
    end
    activities.collect do |activity|
      { :name => activity.name,
        :hours => activity.time_entries.for_user(user).between(day,day.at_end_of_month).sum(:hours) }
    end
  end
  
end