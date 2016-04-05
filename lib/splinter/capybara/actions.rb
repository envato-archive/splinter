require 'splinter/capybara/form_completer'
require 'capybara/dsl'

module Splinter
  module Capybara
    # Additional actions for Capybara.
    module Actions
      # Take a screenshot of the current page
      #
      # name - The name of the screenshot. Uses the current time by default.
      def take_screenshot!(name = "#{Time.now.strftime('%Y%m%d%H%M%S%L')}")
        if path = Splinter.screenshot_directory
          args = [File.join(path, "#{name}.png"), Splinter.screenshot_options].compact
          page.driver.render(*args)
          puts "Saved screenshot to #{args.first}"
        else
          warn "Splinter.screenshot_directory doesn't exist!"
        end
      end

      # Complete and submit a form
      #
      # base - The name of the form, (eg: :post for form_for @post)
      #
      # A required block is yielded to a FormCompleter object. The form will
      # be completed and submitted upon execution of the block.
      #
      # Example:
      #
      #   complete_form :post do |f|
      #     f.text_field :author, "Joshua Priddle"
      #     f.text_area  :bio, "Lorem ipsum"
      #     f.checkbox   :admin, true
      #     f.select     :group, 'admins'
      #     f.radio      :autosave, false
      #     f.date       :publish_at, Time.now
      #     f.datetime   :publish_at, Time.now
      #     t.time       :publish_at, Time.now
      #   end
      #
      # You can also manually submit in case your submit input field requires
      # a custom selector:
      #
      #   complete_form :post do |f|
      #     ...
      #     f.submit "//custom/xpath/selector"
      #   end
      #
      def complete_form(base)
        yield form = FormCompleter.new(base, self)
        form.submit unless form.submitted?
      end

      # Selects hour and minute dropdowns for a time attribute.
      #
      # time    - A Time object that will be used to choose options.
      # options - A Hash containing one of:
      #           :id_prefix - the prefix of each dropdown's CSS ID (eg:
      #                        :post_publish_at for #post_publish_at_1i, etc)
      #           :from      - The text in a label for this dropdown (eg:
      #                        "Publish At" for <label for="#publish_at_1i">)
      def select_datetime(time, options = {})
        select_prefix = select_prefix_from_options(options)

        select_time time, :id_prefix => select_prefix
        select_date time, :id_prefix => select_prefix
      end

      # Selects hour and minute dropdowns for a time attribute.
      #
      # time    - A Time object that will be used to choose options.
      # options - A Hash containing one of:
      #           :id_prefix - the prefix of each dropdown's CSS ID (eg:
      #                        :post_publish_at for #post_publish_at_1i, etc)
      #           :from      - The text in a label for this dropdown (eg:
      #                        "Publish At" for <label for="#publish_at_1i">)
      def select_time(time, options = {})
        id = select_prefix_from_options(options)

        find_and_select_option "#{id}_4i", "%02d" % time.hour
        find_and_select_option "#{id}_5i", "%02d" % time.min
      end

      # Selects hour and minute dropdowns for a time attribute.
      #
      # time    - A Time object that will be used to choose options.
      # options - A Hash containing one of:
      #           :id_prefix - the prefix of each dropdown's CSS ID (eg:
      #                        :post_publish_at for #post_publish_at_1i, etc)
      #           :from      - The text in a label for this dropdown (eg:
      #                        "Publish At" for <label for="#publish_at_1i">)
      def select_date(time, options={})
        id = select_prefix_from_options(options)

        find_and_select_option "#{id}_1i", time.year
        find_and_select_option "#{id}_2i", time.month
        find_and_select_option "#{id}_3i", time.day
      end

      # Finds and selects an option from a dropdown with the given ID.
      #
      # select_id - CSS ID to check, do *not* include #
      # value     - The value to select.
      def find_and_select_option(select_id, value)
        select = find(:css, "##{select_id}")
        path = ".//option[contains(./@value, '#{value}')][1]"

        select.find(:xpath, path).select_option
      end

      # Simulates a javascript alert confirmation. You need to pass in a block that will
      # generate the alert. E.g.:
      #
      #    javascript_confirm        { click_link "Destroy" }
      #    javascript_confirm(false) { click_link "Destroy" }
      def javascript_confirm(result = true)
        raise ArgumentError, "Block required" unless block_given?
        result = !! result

        page.evaluate_script("window.original_confirm = window.confirm; window.confirm = function() { return #{result.inspect}; }")
        yield
        page.evaluate_script("window.confirm = window.original_confirm;")
      end

      # Finds a link inside a row and clicks it.
      #
      # lookup - the link text to look for
      # row_content - the text to use when looking for a row
      def click_link_inside_row(lookup, row_content)
        find(:xpath, "//tr[contains(.,'#{row_content}')]/td/a", :text => lookup).click
      end

      private

      def select_prefix_from_options(options)
        unless options[:id_prefix] || options[:from]
          raise ArgumentError, "You must supply either :from or :id_prefix option"
        end

        options[:id_prefix] || find_prefix_by_label(options[:from])
      end

      def find_prefix_by_label(label)
        path = "//label[contains(normalize-space(string(.)), '#{label}')]/@for"
        find(:xpath, path).text(:all).sub(/_\di$/, '')
      end
    end
  end
end
