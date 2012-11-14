module Splinter
  module Capybara
    # The FormCompleter is a simple proxy that delegates actions to a Capybara
    # session.
    class FormCompleter
      def initialize(base, page)
        @base = base
        @page = page
      end

      def text_field(id, value)
        @page.fill_in "#{@base}_#{id}", { :with => value.to_s }
      end
      alias text_area text_field

      def checkbox(id, value = nil)
        @page.send value ? :check : :uncheck, "#{@base}_#{id}"
      end

      def radio(id, value)
        @page.choose "#{@base}_#{id}_#{value}"
      end

      def select(id, value)
        @page.find_and_select_option "#{@base}_#{id}", value
      end

      def time(id, value)
        @page.select_time value, { :id_prefix => "#{@base}_#{id}" }
      end

      def date(id, value)
        @page.select_date value, { :id_prefix => "#{@base}_#{id}" }
      end

      def datetime(id, value)
        @page.select_datetime value, { :id_prefix => "#{@base}_#{id}" }
      end
    end
  end
end
