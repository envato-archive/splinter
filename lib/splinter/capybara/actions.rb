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
        unless example.metadata[:js]
          warn "Screenshots can only be captured when an example is tagged with :js => true"
          return
        end

        if path = Splinter.screenshot_directory
          file = File.join(path, "#{name}.png")
          page.driver.render(file)
          puts "Saved screenshot to #{file}"
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
      def complete_form(base)
        form = FormCompleter.new(base)
        yield form
        form.each_input { |method, *args| send(method, *args) }
        submit_form
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
        select_err = "cannot select option, no select box with id '##{select_id}' found"
        option_err = "cannot select option, no option with text '#{value}' in select box '##{select_id}'"

        select = find(:css, "##{select_id}", :message => select_err)
        path = ".//option[contains(./@value, '#{value}')]"

        select.find(:xpath, path, :message => option_err).select_option
      end

      private

      def select_prefix_from_options(options)
        unless options[:id_prefix] || options[:from]
          raise ArgumentError, "You must supply either :from or :id_prefix option"
        end

        select_prefix   = options[:id_prefix]
        select_prefix ||= find_prefix_by_label(options[:from])

        select_prefix
      end

      def find_prefix_by_label(label)
        message = "cannot select option, select with label '#{label}' not found"
        path    = "//label[contains(normalize-space(string(.)), '#{label}')]/@for"

        find(:xpath, path, :message => message).text.sub(/_\di$/, '')
      end

      def submit_form
        find("form input[type='submit']").click
      end

    end
  end
end
