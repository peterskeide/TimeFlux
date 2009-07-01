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

        pdf.select_font "Times-Roman"
        
        pdf.text options.title, :font_size => 26, :leading => 40, :justification => :center
        pdf.text '__________', :font_size => 12, :justification => :center
        pdf.text "Timeflux Report", :font_size => 10, :justification => :center

        pdf.move_pointer(50)

        if data.is_a? Ruport::Data::Grouping
          render_grouping data, options.to_hash.merge(:formatter => pdf_writer)
        else
          draw_table data
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
