require "test_helper"

class DatePickerRenderTest < ActiveSupport::TestCase
  def view
    @view ||= ApplicationController.new.view_context
  end

  # The wrapper used to be hand-written: merged_data was built and thrown away,
  # so a caller's data:/attributes vanished and data-size/data-full-width (which
  # date_picker.css styles) could never be set.
  test "wrapper applies caller html_options and data" do
    html = view.render("components/date_picker", input_name: "due_on",
      css_classes: "w-64", title: "Due date",
      data: {testid: "dp", controller: "analytics", action: "date-picker:change->analytics#track"})

    root = html[/<div [^>]*data-component="date-picker"[^>]*>/]
    assert root, "no date-picker root rendered"
    assert_includes root, %(id="date-picker-due_on")
    assert_includes root, %(class="w-64")
    assert_includes root, %(title="Due date")
    assert_includes root, %(data-testid="dp")
    assert_includes root, %(data-controller="date-picker analytics")
    assert_includes root, %(data-action="date-picker:change-&gt;analytics#track")
  end

  test "size and full_width reach the styled data attributes" do
    default = view.render("components/date_picker")
    sized = view.render("components/date_picker", size: :sm, full_width: true)

    assert_includes default, %(data-size="default")
    refute_includes default, "data-full-width"
    assert_includes sized, %(data-size="sm")
    assert_includes sized, %(data-full-width="true")
  end

  # Without these values connect() rewrote a custom placeholder to "Select date".
  test "emits the placeholder values the controller reads on connect" do
    single = view.render("components/date_picker", placeholder: "Pick a day")
    range = view.render("components/date_picker", mode: :range, placeholder: "Pick a stay")
    fallback = view.render("components/date_picker", mode: :range)

    assert_includes single, %(data-date-picker-placeholder-value="Pick a day")
    assert_includes single, %(<span data-date-picker-target="display">Pick a day</span>)
    assert_includes range, %(data-date-picker-placeholder-range-value="Pick a stay")
    assert_includes fallback, %(data-date-picker-placeholder-range-value="Select date range")
  end

  # The controller formats with the same I18n patterns and names, so the
  # server-rendered text survives connect() unchanged.
  test "display text comes from the shared helpers and the locale data is emitted" do
    date = Date.new(2026, 3, 5)
    single = view.render("components/date_picker", selected: date)
    range = view.render("components/date_picker", mode: :range,
      selected: date, selected_end: date + 4)

    assert_includes single, ">#{view.date_picker_format(date)}</span>"
    assert_includes range, ">#{view.date_picker_format_range(date, date + 4)}</span>"

    locale = JSON.parse(CGI.unescapeHTML(single[/data-date-picker-locale-value="([^"]*)"/, 1]))
    assert_equal I18n.t("date.formats.long"), locale.dig("formats", "long")
    assert_equal I18n.t("date.formats.short"), locale.dig("formats", "short")
    assert_equal "March", locale["month_names"][3]
    assert_equal "Mar", locale["abbr_month_names"][3]
  end
end
