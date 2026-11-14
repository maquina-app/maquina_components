require "test_helper"

class CalendarHelperTest < ActiveSupport::TestCase
  include ActiveSupport::Testing::TimeHelpers

  def view
    @view ||= ApplicationController.new.view_context
  end

  test "the year range defaults to 100 years back and 10 ahead" do
    travel_to Date.new(2026, 11, 14) do
      assert_equal 1926..2036, view.calendar_year_range(2026)
    end
  end

  test "min_date and max_date set the year bounds" do
    range = view.calendar_year_range(2026, min_date: Date.new(1900, 5, 1), max_date: Date.new(2030, 1, 1))

    assert_equal 1900..2030, range
  end

  test "an explicit years range applies, narrowed by min_date and max_date" do
    assert_equal 2000..2010, view.calendar_year_range(2005, years: 2000..2010)
    assert_equal 2003..2008,
      view.calendar_year_range(2005, years: 2000..2010, min_date: Date.new(2003, 1, 1), max_date: Date.new(2008, 1, 1))
  end

  # The year select must be able to show the year the calendar opens on
  test "the displayed year is always in the range" do
    assert_equal 1990..2010, view.calendar_year_range(1990, years: 2000..2010)
    assert_equal 2000..2020, view.calendar_year_range(2020, years: 2000..2010)
  end

  test "month options are abbreviated names, months 1 to 12" do
    options = view.calendar_month_options(2026)

    assert_equal 12, options.size
    assert_equal ["Jan", 1, false], options.first
    assert_equal ["Dec", 12, false], options.last
  end

  test "months wholly outside min_date and max_date are disabled" do
    options = view.calendar_month_options(2026, min_date: Date.new(2026, 3, 31), max_date: Date.new(2026, 10, 1))
    disabled = options.select(&:last).map(&:second)

    assert_equal [1, 2, 11, 12], disabled
  end

  test "dropdown captions render month and year selects, the label caption does not" do
    html = view.render("components/calendar", month: 6, year: 1987, caption_layout: :dropdown, years: 1980..1990)

    assert_includes html, %(data-calendar-part="month-select")
    assert_includes html, %(<option value="6" selected="selected">Jun</option>)
    assert_includes html, %(<option value="1987" selected="selected">1987</option>)
    assert_includes html, %(data-calendar-start-year-value="1980")
    assert_includes html, %(data-calendar-end-year-value="1990")
    refute_includes html, %(data-calendar-part="caption")

    label = view.render("components/calendar", month: 6, year: 1987)
    assert_includes label, %(data-calendar-part="caption")
    refute_includes label, "data-calendar-start-year-value"
  end
end
