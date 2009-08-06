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
       redirect_to time_entries_url
       return false
    end
  end


  #Used in month and report controller
  def setup_calender
    @day = first_in_month(params[:year], params[:month])
    @selected_year = @day.year
    @selected_month = @day.month

    @years = (2007..Date.today.year).to_a.reverse
    @months = []
    @month_names = %w{ January Febrary March April May June July August September October November December}
    @month_names.each_with_index { |name, i| @months << [ i+1, name ] }
  end

   #Used in month and report controller
  def first_in_month(year, month)
    year ||= Date.today.year
    month ||= Date.today.month
    return Date.new(year.to_i, month.to_i, 1)
  end

  #Used in month and report controller
  def respond_with_formatter(table, formatter, title="report")

    conv = ReportConverter

    respond_to do |format|
      format.html do
        @title = title
        @table = table
      end

      format.pdf do
        remove_billed_column!(table)
        send_data formatter.render_pdf(:data => conv.convert(table), :title => conv.convert_string(title)),
          { :type => "	application/pdf", :disposition  => "inline", :filename => "#{title}.pdf" }
      end
      format.csv do
        remove_billed_column!(table)
        send_data formatter.render_csv(:data => conv.convert(table), :title => conv.convert_string(title)),
          { :type => "	text/plain", :disposition  => "inline", :filename => "#{title}.csv" }
      end
      format.text do
        remove_billed_column!(table)
        send_data formatter.render(:text, :data => conv.convert(table), :title => conv.convert_string(title)),
          { :type => "	text/plain", :disposition  => "inline", :filename => "#{title}.txt" }
      end
    end
  end

  def remove_billed_column!(table)
    if table.is_a? Ruport::Data::Grouping
      table.each do |name,group|
        group.remove_column('Billed')
      end
    elsif table.is_a? Ruport::Data::Table
      table.remove_column('Billed')
    end

  end
  
end