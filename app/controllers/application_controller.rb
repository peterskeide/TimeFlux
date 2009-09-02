class ApplicationController < ActionController::Base
  
  helper :all
  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  protect_from_forgery # :secret => 'fde529db0c28312f59bd56fca26f2acf'
  filter_parameter_logging :password
  
  helper_method :current_user_session, :current_user

  private
  
  def current_user_session
    return @current_user_session if defined? @current_user_session
    @current_user_session = UserSession.find
  end

  def current_user
    return @current_user if defined? @current_user
    @current_user = current_user_session && current_user_session.user
  end
  
  def check_authentication
     unless current_user
       flash[:notice] = "Please log in first"
       redirect_to new_user_session_url
       return false
     end
  end
  
  def check_admin
    unless current_user.admin
      flash[:notice] = "That page is for admins only"
       redirect_to user_time_entries_url(current_user)
       return false
    end
  end

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