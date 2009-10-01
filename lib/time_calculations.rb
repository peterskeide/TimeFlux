module TimeFlux
  module Time
        
    class Month
      
      attr_reader :month, :year, :start, :end
                  
      def initialize(month, year)
        @month, @year = month, year
        @start = Date.new(@month, 1, 1)
        @end = @start.end_of_month
      end
      
      def week_numbers
        temp = @start
        week_numbers = []
        while temp < @end
          week_numbers << temp.cweek
          temp = temp.+(7).at_beginning_of_week
        end
        week_numbers
      end     
    end
        
  end
end