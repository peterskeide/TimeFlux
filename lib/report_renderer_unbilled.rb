require "ruport"

 class ReportRendererUnbilled < Ruport::Controller

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

        pdf.select_font "Times-Roman"
        
        pdf.text options.title, :font_size => 26, :leading => 40, :justification => :center
        pdf.text '__________', :font_size => 12, :justification => :center
        pdf.text "Timeflux Report", :font_size => 10, :justification => :center

        pdf.move_pointer(50)

        if data.is_a? Ruport::Data::Grouping
          #render_grouping data, options.to_hash.merge(:formatter => pdf_writer)
          data.each do |name,group|
            #pdf.move_pointer(30)
            pdf.start_new_page
            pdf.text name, :font_size => 16, :leading => 20
            pdf.move_pointer(10)
            draw_table group, :position => :left, :orientation => :right
            pdf.move_pointer(20)
#
            if group.column_names.include? 'Hours'
              sum = group.sum('Hours')
              pdf.text "Total hours: #{sum}", :font_size => 12
            end
          end
        else
          draw_table data
          if data.column_names.include? 'Hours'
            pdf.text "Total hours : #{data.sum('Hours')}", :font_size => 12
          end
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
