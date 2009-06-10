class ReportsController < ApplicationController

  def index

  end

  def user_report

    Table @table = User.report_table(:all,
      :only       => %w[firstname lastname username email operative_status updated_at],
      :group      => "lastname")

    respond_to do |format|
      format.html
      format.pdf { send_data @table.to_pdf }
      format.csv { send_data @table.to_csv,{ :type => "	text/plain", :disposition  => "inline", :filename => "#user_report.csv" } }
    end

  end
end
