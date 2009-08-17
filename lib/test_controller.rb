require "ruport"

class TestController < Ruport::Controller

  stage :report

  #required_option :title

  formatter :html do
    build :report do
      output << textile("h1. #{options.title}")
      output << data.to_html(:style => :justified)
    end
  end

  formatter :csv do
    build :report do
      output << data.to_csv
    end
  end

  formatter :pdf do
    build :report do

      pdf = pdf_writer
      pdf.right_margin = 82
      pdf.select_font "Times-Roman"

      draw_hours_header(pdf)

      if data.is_a? Ruport::Data::Grouping
        start = true
        data.each do |name,group|
          if start 
            start = false
          elsif options.page_break
            pdf.start_new_page
            draw_hours_header(pdf)
          else
            pdf.move_pointer(40)
          end

          pdf.text name, :font_size => 16, :leading => 20
          pdf.move_pointer(10)
          draw_hours_table group
          draw_hours_summary group, pdf
        end
      else
        draw_hours_table data
        draw_hours_summary data, pdf
      end
    end

    def draw_hours_header(pdf)
      pdf.text options.title, :font_size => 26, :leading => 40, :justification => :center
      pdf.text '__________', :font_size => 12, :justification => :center
      #pdf.text "Timeflux Report", :font_size => 10, :justification => :center
      pdf.image "public/images/timeflux_logo.jpg", :justification => :center, :resize => 0.3
      pdf.move_pointer(50)
    end

    def draw_hours_table(data)
      draw_table data, :position => :left, :orientation => :right, :show_lines => :none, :split_rows => true, :width => 500
    end

    def draw_hours_summary(group, pdf)
      if group.column_names.include? 'Hours'
          pdf.move_pointer(20)
          pdf.text "Total hours : #{group.sum('Hours')}", :font_size => 12, :justification => :right
      end
    end
  end

  formatter :text do
    build :report do
      output << "#{options.title}\n\n"
      output << data.to_text
    end
  end



end
