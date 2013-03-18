module Splinter
  module Capybara
    # The FormCompleter is a simple proxy that delegates actions to a Capybara
    # session.
    class FormCompleter
      attr_reader :submitted

      def initialize(base, page)
        @base = base
        @page = page
      end

      def text_field(id, value)
        @page.send :fill_in, "#{@base}_#{id}", { :with => value.to_s }
      end
      alias text_area text_field

      def checkbox(id, value = nil)
        @page.send value ? :check : :uncheck, "#{@base}_#{id}"
      end

      def radio(id, value)
        @page.send :choose, "#{@base}_#{id}_#{value}"
      end

      def select(id, value)
        @page.send :find_and_select_option, "#{@base}_#{id}", value
      end

      def time(id, value)
        @page.send :select_time, value, { :id_prefix => "#{@base}_#{id}" }
      end

      def date(id, value)
        @page.send :select_date, value, { :id_prefix => "#{@base}_#{id}" }
      end

      def datetime(id, value)
        @page.send :select_datetime, value, { :id_prefix => "#{@base}_#{id}" }
      end

      def submit(selector = "//form[contains(@id,'#{@base}')]//input[@type='submit']")
        @page.send(:find, :xpath, selector).click
        @submitted = true
      end

      # Public: Checks if this form has already been submitted.
      def submitted?
        submitted
      end
    end
  end
end
