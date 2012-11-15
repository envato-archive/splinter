require 'spec_helper'
require 'test_app/server'
require 'rack/test'

describe Splinter, :type => :feature do
  include Rack::Test::Methods

  def time
    @time ||= Time.now
  end

  def find_result(name)
    find("[data-result-for='#{name}']").text
  end

  def find_selected_option(select_id)
    find("select##{select_id} > option[selected]").value
  end

  before do
    ::Capybara.app = Splinter::TestServer
  end

  describe "#complete_form" do
    before do
      visit "/"

      complete_form :post do |f|
        f.text_field :name, "Josh"
        f.text_area  :content, "Lorem ipsum"
        f.radio      :privacy, "private"
        f.date       :publish_at, time
        f.datetime   :lock_at, time
        f.checkbox   :publish, true
      end
    end

    describe "submitted values" do
      it { find_result(:name).should == "Josh" }
      it { find_result(:content).should == "Lorem ipsum" }
      it { find_result(:privacy).should == "private" }
      it { find_result("publish_at(1i)").should == time.year.to_s }
      it { find_result("publish_at(2i)").should == time.month.to_s }
      it { find_result("publish_at(3i)").should == time.day.to_s }

      it { find_result("lock_at(1i)").should == time.year.to_s }
      it { find_result("lock_at(2i)").should == time.month.to_s }
      it { find_result("lock_at(3i)").should == time.day.to_s }
      it { find_result("lock_at(4i)").should == "%02d" % time.hour }
      it { find_result("lock_at(5i)").should == "%02d" % time.min }

      it { find_result(:publish).should == '1' }
    end
  end

  context "time helpers" do
    let :prefix do
      "post_lock_at"
    end

    before do
      visit "/"
    end

    { :id_prefix => "post_lock_at", :from => "Lock at" }.each do |prefix_key, prefix_val|
      describe "#select_datetime" do
        it "selects all dropdowns by #{prefix_key.inspect}" do
          select_datetime time, prefix_key => prefix_val

          find_selected_option("#{prefix}_1i").should == time.year.to_s
          find_selected_option("#{prefix}_2i").should == time.month.to_s
          find_selected_option("#{prefix}_3i").should == time.day.to_s
          find_selected_option("#{prefix}_4i").should == "%02d" % time.hour.to_s
          find_selected_option("#{prefix}_5i").should == "%02d" % time.min.to_s
        end
      end

      describe "#select_time" do
        it "selects time dropdowns by #{prefix_key.inspect}" do
          select_time time, prefix_key => prefix_val

          find_selected_option("#{prefix}_4i").should == "%02d" % time.hour.to_s
          find_selected_option("#{prefix}_5i").should == "%02d" % time.min.to_s
        end
      end

      describe "#select_date" do
        it "selects date dropdowns by #{prefix_key.inspect}" do
          select_date time, prefix_key => prefix_val

          find_selected_option("#{prefix}_1i").should == time.year.to_s
          find_selected_option("#{prefix}_2i").should == time.month.to_s
          find_selected_option("#{prefix}_3i").should == time.day.to_s
        end
      end
    end
  end
end
