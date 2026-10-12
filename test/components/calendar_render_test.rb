require "test_helper"

class CalendarRenderTest < ActiveSupport::TestCase
  CONTROLLER_JS = File.expand_path("../../app/javascript/controllers/calendar_controller.js", __dir__)

  def view
    @view ||= ApplicationController.new.view_context
  end

  # Month navigation rebuilds the grid client-side, so the controller needs the
  # same disabled dates and outside-day setting the server used.
  test "disabled dates and show_outside_days reach the controller as values" do
    html = view.render("components/calendar", month: 3, year: 2026,
      disabled_dates: [Date.new(2026, 3, 10), "2026-04-02"], show_outside_days: false)

    assert_includes html, %(data-calendar-disabled-dates-value="[&quot;2026-03-10&quot;,&quot;2026-04-02&quot;]")
    assert_includes html, %(data-calendar-show-outside-days-value="false")
  end

  test "disabled dates given as strings disable the day on the server too" do
    html = view.render("components/calendar", month: 3, year: 2026, disabled_dates: ["2026-03-10"])

    assert_match(/<button[^>]*disabled="disabled"[^>]*data-date="2026-03-10"/, html)
  end

  # Skipping outside days used to shift the month's first day into Sunday's column.
  test "hidden outside days keep their grid column" do
    # March 2026 starts on a Sunday and ends on a Tuesday: 4 trailing outside days
    html = view.render("components/calendar", month: 3, year: 2026, show_outside_days: false)

    assert_equal 4, html.scan(%(data-calendar-part="outside-day")).size
    refute_includes html, "data-outside"
  end

  test "a caller style and cell_size both land on the style attribute" do
    html = view.render("components/calendar", cell_size: "2.5rem", style: "max-width: 20rem;")

    assert_includes html, %(style="--cell-size: 2.5rem; max-width: 20rem;")
    assert_equal 1, html.scan("style=").size
  end

  test "calendar:change is dispatched once, through Stimulus" do
    source = File.read(CONTROLLER_JS)

    refute_match(/new CustomEvent\(\s*["']calendar:/, source,
      "this.dispatch already emits a bubbling calendar:* event; a manual CustomEvent doubles it")
    assert_match(/this\.dispatch\("change"/, source)
  end

  test "calendar_to_date coerces dates and ISO strings, and tolerates junk" do
    assert_equal Date.new(2026, 3, 5), view.calendar_to_date("2026-03-05")
    assert_equal Date.new(2026, 3, 5), view.calendar_to_date(Time.zone.local(2026, 3, 5, 12))
    assert_nil view.calendar_to_date("not a date")
    assert_nil view.calendar_to_date("")
    assert_nil view.calendar_to_date(nil)
  end
end
