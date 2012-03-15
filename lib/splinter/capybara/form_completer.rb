module Splinter
  module Capybara
    # The FormCompleter is a simple stack that keeps track of Capybara actions
    # to run.
    class FormCompleter
      def initialize(base)
        @base  = base
        @stack = []
      end

      def text_field(id, value)
        @stack << [:fill_in, "#{@base}_#{id}", { :with => value.to_s }]
      end
      alias text_area text_field

      def checkbox(id, value = nil)
        @stack << [value ? :check : :uncheck, "#{@base}_#{id}"]
      end

      def radio(id, value)
        @stack << [:choose, "#{@base}_#{id}_#{value}"]
      end

      def select(id, value)
        @stack << [:find_and_select_option, "#{@base}_#{id}", value]
      end

      def time(id, value)
        @stack << [:select_time, value, { :id_prefix => "#{@base}_#{id}" }]
      end

      def date(id, value)
        @stack << [:select_date, value, { :id_prefix => "#{@base}_#{id}" }]
      end

      def datetime(id, value)
        @stack << [:select_datetime, value, { :id_prefix => "#{@base}_#{id}" }]
      end

      def each_input(&block)
        @stack.each(&block)
      end
    end
  end
end
