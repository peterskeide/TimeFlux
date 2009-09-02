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

  #Used in month and report controller
  def respond_with_formatter(table, formatter, title="report", pdf_options={})

    conv = ReportConverter

    respond_to do |format|
      format.html do
        @title = title
        @table = table
      end

      format.pdf do
        remove_sensitive_columns!(table)
        send_data( formatter.render_pdf( {:data => conv.convert(table), :title => conv.convert_string(title)}.merge pdf_options ),
          { :type => "	application/pdf", :disposition  => "inline", :filename => "#{title}.pdf" } )
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
  def create_activity_summary(day, user=current_user_session.user)
    activities = user.time_entries.between(day,day.at_end_of_month).distinct_activities.map do |t|
      t.activity
    end
    activities.collect do |activity|
      { :name => activity.name,
        :hours => activity.time_entries.for_user(user).between(day,day.at_end_of_month).sum(:hours) }
    end
  end

  def remove_sensitive_columns!(table)
    if table.is_a? Ruport::Data::Grouping
      table.each do |name,group|
        group.remove_column('Locked')
        group.remove_column('Billed')
      end
    elsif table.is_a? Ruport::Data::Table
      table.remove_column('Locked')
      table.remove_column('Billed')
    end
  end
  
end