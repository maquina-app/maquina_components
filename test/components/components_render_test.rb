require "test_helper"

# Renders component partials directly and asserts the conventions every
# component must honor: data-component attributes, variant/size data
# attributes, css_classes passthrough, and merging of the caller's data:
# hash. Also locks in regressions fixed on the audit branch.
class ComponentsRenderTest < ActiveSupport::TestCase
  def view
    @view ||= ApplicationController.new.view_context
  end

  test "badge exposes component data attributes and merges user data" do
    html = view.render("components/badge", variant: :success, size: :sm,
      css_classes: "extra", data: {testid: "b"}) { "Done" }

    assert_includes html, %(data-component="badge")
    assert_includes html, %(data-variant="success")
    assert_includes html, %(data-size="sm")
    assert_includes html, %(data-testid="b")
    assert_includes html, "extra"
    assert_includes html, "Done"
  end

  test "card container renders block and title accepts text parameter" do
    html = view.render("components/card") do
      view.render("components/card/title", text: "Projects")
    end

    assert_includes html, %(data-component="card")
    assert_includes html, "Projects"
  end

  test "alert renders variant and role" do
    html = view.render("components/alert", variant: :destructive) { "Careful" }

    assert_includes html, %(role="alert")
    assert_includes html, %(data-variant="destructive")
    assert_includes html, "Careful"
  end

  test "table cell and head accept text parameter and keep block path" do
    with_text = view.render("components/table/cell", text: "Param")
    with_block = view.render("components/table/cell") { "Block" }
    head = view.render("components/table/head", text: "Name")

    assert_includes with_text, "Param"
    assert_includes with_block, "Block"
    assert_includes head, "Name"
    assert_includes head, %(scope="col")
  end

  test "simple_table renders empty state" do
    html = view.render("components/simple_table", collection: [],
      columns: [{key: :name, label: "Name"}])

    assert_includes html, "No data available"
  end

  test "separator renders data attributes and merges user data" do
    html = view.render("components/separator", orientation: :vertical,
      css_classes: "mx-4", data: {testid: "sep"})

    assert_includes html, %(data-component="separator")
    assert_includes html, %(data-orientation="vertical")
    assert_includes html, %(data-testid="sep")
    assert_includes html, "mx-4"
    refute_includes html, "{" # regression: options hash rendered as content
  end

  test "menu_button renders valid markup with aria state" do
    html = view.render("components/menu_button", title: "Acme Inc", subtitle: "Pro") { "" }

    assert_includes html, %(data-component="menu-button")
    assert_includes html, %(id="menu-button-acme-inc-trigger")
    assert_includes html, %(aria-haspopup="menu")
    assert_includes html, %(aria-expanded="false")
    refute_includes html, "}" # regression: stray brace inside the button tag
  end

  test "dropdown panel wires aria to the menu_button trigger" do
    html = view.render("components/menu_button", title: "Acme") do |menu_id|
      view.render("components/dropdown", id: menu_id) { "Items" }
    end

    assert_includes html, %(id="menu-button-acme-content")
    assert_includes html, %(aria-labelledby="menu-button-acme-trigger")
    assert_includes html, %(role="menu")
    assert_includes html, "hidden"
  end

  test "combobox falls back to a deterministic id" do
    first = view.render("components/combobox", name: "user[country]") { |id| "id:#{id}" }
    second = view.render("components/combobox", name: "user[country]") { |id| "id:#{id}" }

    assert_includes first, "id:combobox-user-country"
    assert_equal first, second
  end

  test "date_picker falls back to a deterministic id" do
    first = view.render("components/date_picker", input_name: "event[due_on]")
    second = view.render("components/date_picker", input_name: "event[due_on]")

    assert_includes first, %(id="date-picker-event-due_on")
    assert_equal first, second
  end

  test "stats_grid emits literal responsive column classes" do
    html = view.render("components/stats/stats_grid",
      cards: [{title: "Users", value: "42"}], columns: 4)

    assert_includes html, "sm:grid-cols-4"
    refute_includes html, "sm:grid-cols-#" # regression: interpolated class
  end

  test "stats_grid accepts action_position as symbol or string" do
    sym = view.render("components/stats/stats_grid", cards: [], action: "A", action_position: :start)
    str = view.render("components/stats/stats_grid", cards: [], action: "A", action_position: "start")

    assert_includes sym, "justify-start"
    assert_includes str, "justify-start"
  end

  test "closed drawer panel is a hidden, inert dialog" do
    html = view.render("components/drawer") { "Body" }

    assert_includes html, %(role="dialog")
    assert_includes html, %(aria-modal="true")
    assert_includes html, %(aria-label="Drawer")
    assert_includes html, "aria-hidden"
    assert_includes html, "inert"
  end

  test "open drawer panel is exposed to assistive tech" do
    html = view.render("components/drawer", state: :open, aria_label: "Filters") { "Body" }

    assert_includes html, %(aria-label="Filters")
    refute_includes html, "aria-hidden"
    refute_includes html, "inert"
  end

  test "toaster renders a polite live region" do
    html = view.render("components/toaster")

    assert_includes html, %(role="region")
    assert_includes html, %(aria-live="polite")
  end

  test "empty media renders icon or explicit content" do
    icon = view.render("components/empty/media", icon: :search)
    content = view.render("components/empty/media", content: "<img>".html_safe)

    assert_includes icon, "<svg"
    assert_includes content, "<img>"
  end
end
