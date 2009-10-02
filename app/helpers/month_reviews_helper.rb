module MonthReviewsHelper

  def balance(period)
    html = ""
    html += "Balance: <span class=" + case period.balance when (0..9999) then "ok" when (-9999..0) then "red" end + ">"
    html += "%+.1f" % @period.balance + "</span> hours"
    html += @period.balance_workdays ? " in the first #{@period.balance_workdays} working days" : ''
    html
  end

end
