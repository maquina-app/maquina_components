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

  test "stats_grid renders data-attribute columns" do
    html = view.render("components/stats/stats_grid",
      cards: [{title: "Users", value: "42"}], columns: 4)

    assert_includes html, %(data-component="stats-grid")
    assert_includes html, %(data-columns="4")
    assert_includes html, %(data-stats-part="grid")
    refute_includes html, "sm:grid-cols-#" # regression: interpolated class
  end

  test "stats_grid accepts action_position as symbol or string" do
    sym = view.render("components/stats/stats_grid", cards: [], action: "A", action_position: :start)
    str = view.render("components/stats/stats_grid", cards: [], action: "A", action_position: "start")

    assert_includes sym, %(data-position="start")
    assert_includes str, %(data-position="start")
    assert_includes sym, %(data-with-action="true")
  end

  test "stats_card follows conventions and keeps legacy aliases" do
    legacy = view.render("components/stats/stats_card", title: "Errors", value: "3",
      icon: "exclamation-circle", icon_class: "text-red-500",
      value_class: "text-red-600", container_class: "legacy-extra")
    modern = view.render("components/stats/stats_card", title: "Users", value: "42",
      icon: :users, subtitle: "This month", css_classes: "extra",
      data: {testid: "sc"})

    assert_includes legacy, "<svg" # legacy string icon name maps to a builtin icon
    assert_includes legacy, "text-red-500"
    assert_includes legacy, "text-red-600"
    assert_includes legacy, "legacy-extra"

    assert_includes modern, %(data-component="stats-card")
    assert_includes modern, %(data-testid="sc")
    assert_includes modern, %(data-stats-part="value")
    assert_includes modern, "This month"
    assert_includes modern, "<svg"
    assert_includes modern, "extra"
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

  test "caller data-controller and data-action concatenate with the component's" do
    html = view.render("components/combobox", name: "country",
      data: {controller: "analytics", action: "change->analytics#track", testid: "cb"}) { |_id| "" }

    assert_includes html, %(data-controller="combobox analytics")
    assert_includes html, %(data-testid="cb")

    provider = view.render("components/drawer/provider",
      data: {action: "click->analytics#track"}) { "" }
    assert_match(/data-action="keydown[^"]*closeOnEscape click-&gt;analytics#track"/, provider)

    # component identity keys still win over caller data
    badge = view.render("components/badge", data: {component: "hijack"}) { "B" }
    assert_includes badge, %(data-component="badge")
  end

  test "variant and size vocabulary aliases normalize across components" do
    badge_size = view.render("components/badge", size: :default) { "B" }
    badge_variant = view.render("components/badge", variant: :error) { "B" }
    alert = view.render("components/alert", variant: :error) { "A" }
    toast = view.render("components/toast", variant: :destructive, title: "Boom")

    assert_includes badge_size, %(data-size="md")
    assert_includes badge_variant, %(data-variant="destructive")
    assert_includes alert, %(data-variant="destructive")
    assert_includes toast, %(data-variant="error")
    assert_includes toast, "<svg" # error icon auto-selected for the alias
  end

  test "server-rendered toast icons and dismiss button render" do
    %i[success info warning error].each do |variant|
      html = view.render("components/toast", variant: variant, title: "T")
      icon_area = html[/data-toast-part="icon".*?<\/div>/m]
      assert_includes icon_area.to_s, "<svg", "missing icon for #{variant} toast"
    end

    close_area = view.render("components/toast", title: "T")[/data-toast-part="close".*?<\/button>/m]
    assert_includes close_area.to_s, "<svg", "missing dismiss icon"
  end

  test "sidebar menu_link styles via data parts instead of inline utilities" do
    html = view.render("components/sidebar/menu_link", url: "/settings",
      title: "Settings", subtitle: "Workspace")

    assert_includes html, %(data-sidebar-part="menu-link-text")
    assert_includes html, %(data-sidebar-part="menu-link-title")
    assert_includes html, %(data-sidebar-part="menu-link-subtitle")
    refute_includes html, "flex flex-col gap-0.5"
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

  test "remaining leaf partials accept the content parameter" do
    combobox_empty = view.render("components/combobox/empty", content: "<b>Nothing</b>".html_safe)
    dd_label = view.render("components/dropdown_menu/label", content: "<i>Group</i>".html_safe)
    dd_shortcut = view.render("components/dropdown_menu/shortcut", text: "⌘K")

    assert_includes combobox_empty, "<b>Nothing</b>"
    assert_includes dd_label, "<i>Group</i>"
    assert_includes dd_shortcut, "⌘K"
  end

  test "table variant lands on the container as a real data attribute" do
    html = view.render("components/table", variant: :bordered, table_variant: :striped) { "rows" }

    assert_includes html, %(data-table-part="container")
    assert_includes html, %(data-variant="bordered")
    assert_includes html, %(data-variant="striped")
    # regression: the attribute string used to be HTML-escaped into the markup
    refute_includes html, "&quot;"
    refute_includes html, %(data-variant=\\")
  end

  test "table without a container renders the bare table" do
    html = view.render("components/table", container: false) { "rows" }

    assert_includes html, %(data-component="table")
    refute_includes html, %(data-table-part="container")
  end

  test "calendar week emits real state, aria-selected and aria-current attributes" do
    selected = Date.new(2026, 7, 15)
    html = view.render("components/calendar/week",
      days: [selected, Date.current, Date.new(2026, 6, 30)],
      display_month: 7, selected_date: selected)

    assert_includes html, %(data-state="selected")
    assert_includes html, %(aria-selected="true")
    assert_includes html, %(aria-current="date")
    assert_includes html, %(data-today="true")
    assert_includes html, %(data-outside="true")
    refute_includes html, "&quot;" # regression: escaped attribute strings
  end

  test "calendar week marks a range start, middle and end" do
    html = view.render("components/calendar/week",
      days: [Date.new(2026, 7, 6), Date.new(2026, 7, 7), Date.new(2026, 7, 8)],
      display_month: 7, mode: :range,
      selected_date: Date.new(2026, 7, 6), selected_end_date: Date.new(2026, 7, 8))

    assert_includes html, %(data-state="range-start")
    assert_includes html, %(data-state="range-middle")
    assert_includes html, %(data-state="range-end")
  end

  test "calendar week disables days outside the allowed range" do
    html = view.render("components/calendar/week", days: [Date.new(2026, 7, 1)],
      display_month: 7, min_date: Date.new(2026, 7, 5))

    assert_includes html, %(disabled="disabled")
  end

  test "sidebar items expose their active state to assistive tech" do
    active_button = view.render("components/sidebar/menu_button", title: "Home", url: "/", active: true)
    idle_button = view.render("components/sidebar/menu_button", title: "Home", url: "/")
    active_link = view.render("components/sidebar/menu_link", title: "Team", url: "/team", active: true)
    idle_link = view.render("components/sidebar/menu_link", title: "Team", url: "/team")

    assert_includes active_button, %(data-active="true")
    assert_includes active_button, %(aria-current="page")
    assert_includes active_link, %(data-active="true")
    assert_includes active_link, %(aria-current="page")

    # regression: data-active="false" used to be emitted on every inactive row
    refute_includes idle_button, %(data-active="false")
    refute_includes idle_button, "aria-current"
    refute_includes idle_link, %(data-active="false")
    refute_includes idle_link, "aria-current"
  end

  test "drawer trigger targets one drawer with for_id and the whole page without" do
    scoped = view.render("components/drawer/trigger", for_id: "drawer-provider-filters") { "Filters" }
    with_for = view.render("components/drawer/trigger", for: "drawer-provider-filters") { "Filters" }
    selector = view.render("components/drawer/trigger", for_id: "[data-outlet='drawer'][data-drawer-name='cart']") { "Cart" }
    default = view.render("components/drawer/trigger") { "Menu" }

    assert_includes scoped, %(data-drawer-trigger-drawer-outlet="#drawer-provider-filters")
    assert_includes with_for, %(data-drawer-trigger-drawer-outlet="#drawer-provider-filters")
    refute_includes with_for, %( for=) # for: must not leak onto the button
    assert_includes selector, "data-drawer-name="
    assert_includes default, "data-drawer-trigger-drawer-outlet="
    assert_includes default, "data-outlet="
  end

  test "drawer provider derives a deterministic id from name" do
    first = view.render("components/drawer/provider", name: "Filters") { "" }
    second = view.render("components/drawer/provider", name: "Filters") { "" }
    other = view.render("components/drawer/provider", name: "Cart") { "" }

    assert_includes first, %(id="drawer-provider-filters")
    assert_equal first, second
    assert_includes other, %(id="drawer-provider-cart")
    assert_includes view.render("components/drawer/provider") { "" }, %(id="drawer-provider")
  end

  # drawer.css styled these two parts from the start, but no partial emitted
  # them, so the documented usage was a hand-rolled <h2 class="text-lg
  # font-semibold"> duplicating a rule it could not reach.
  test "drawer title and description emit their styling hooks" do
    title = view.render("components/drawer/title", text: "Filters")
    description = view.render("components/drawer/description", text: "Narrow the results")

    assert_includes title, %(data-drawer-part="title")
    assert_includes title, "Filters"
    assert_includes title, "<h2"
    assert_includes description, %(data-drawer-part="description")
    assert_includes description, "Narrow the results"
    assert_includes description, "<p"
  end

  test "drawer title accepts a different heading level and extra data" do
    rendered = view.render("components/drawer/title",
      text: "Filters", tag: :h3, css_classes: "truncate", data: {testid: "drawer-title"})

    assert_includes rendered, "<h3"
    assert_includes rendered, %(class="truncate")
    assert_includes rendered, %(data-testid="drawer-title")
    assert_includes rendered, %(data-drawer-part="title")
  end

  test "label renders required indicator hook and for attribute" do
    required = view.render("components/label", text: "Email", for_id: "user_email", required: true)
    plain = view.render("components/label", text: "Name")
    block = view.render("components/label") { "Blocky" }

    assert_includes required, %(data-component="label")
    assert_includes required, %(data-required="true")
    assert_includes required, %(for="user_email")
    assert_includes required, "Email"

    refute_includes plain, "data-required"
    assert_includes block, "Blocky"
  end

  test "callers can override non-identity data attributes" do
    trigger = view.render("components/drawer/trigger",
      data: {drawer_trigger_drawer_outlet: "#my-drawer", testid: "t"}) { "" }

    assert_includes trigger, %(data-drawer-trigger-drawer-outlet="#my-drawer")
    assert_includes trigger, %(data-testid="t")

    # identity keys are still the component's
    badge = view.render("components/badge", variant: :success,
      data: {component: "hijack", variant: "hijack"}) { "B" }
    assert_includes badge, %(data-component="badge")
    assert_includes badge, %(data-variant="success")

    part = view.render("components/sidebar/menu_link", url: "/",
      data: {sidebar_part: "hijack"})
    assert_includes part, %(data-sidebar-part="menu-link")
  end

  test "merge_component_data drops nils and keeps string keys working" do
    merged = view.merge_component_data({data: {"testid" => "x", :extra => nil}},
      component: :thing, gone: nil)

    assert_equal({component: :thing, testid: "x"}, merged)
  end

  test "empty title and description accept text, content, and block" do
    text = view.render("components/empty/title", text: "Nothing here")
    content = view.render("components/empty/description", content: "<em>Try again</em>".html_safe)
    block = view.render("components/empty/title") { "Block title" }

    assert_includes text, "Nothing here"
    assert_includes content, "<em>Try again</em>"
    assert_includes block, "Block title"
  end

  # These six parts were styled by the engine with no partial emitting the
  # hook, so the rules read as API that nothing could reach. See
  # test/stylesheets/css_hooks_test.rb.
  test "drawer section and separator emit their styling hooks" do
    section = view.render("components/drawer/section") { "Body" }
    separator = view.render("components/drawer/separator")

    assert_includes section, %(data-drawer-part="section")
    assert_includes section, "Body"
    assert_includes separator, %(data-drawer-part="separator")
    # the divider is the separator primitive, so it keeps its 1px track
    assert_includes separator, %(data-component="separator")
    assert_includes separator, %(data-orientation="horizontal")
  end

  test "sidebar separator renders the separator primitive with the sidebar part" do
    separator = view.render("components/sidebar/separator",
      css_classes: "my-1", data: {testid: "sep"})

    assert_includes separator, %(data-sidebar-part="separator")
    assert_includes separator, %(data-component="separator")
    assert_includes separator, %(data-testid="sep")
    assert_includes separator, "my-1"
    refute_includes separator, "{" # regression: options hash rendered as content
  end

  test "sidebar menu_badge renders its text and hook" do
    text = view.render("components/sidebar/menu_badge", text: "24")
    block = view.render("components/sidebar/menu_badge") { "9+" }

    assert_includes text, %(data-sidebar-part="menu-badge")
    assert_includes text, "24"
    assert_includes block, "9+"
  end

  test "sidebar menu_action renders a button by default and a link with url" do
    button = view.render("components/sidebar/menu_action", label: "More options")
    link = view.render("components/sidebar/menu_action", label: "More options", url: "/settings")

    assert_includes button, %(data-sidebar-part="menu-action")
    assert_includes button, %(<button)
    assert_includes button, %(type="button")
    assert_includes button, %(aria-label="More options")
    assert_includes button, "More options</span>"
    refute_includes button, "<a "

    assert_includes link, %(<a )
    assert_includes link, %(href="/settings")
    assert_includes link, %(data-sidebar-part="menu-action")
  end

  test "sidebar menu_action opts into hover-only visibility" do
    hover = view.render("components/sidebar/menu_action", label: "More", show_on_hover: true)
    always = view.render("components/sidebar/menu_action", label: "More")

    assert_includes hover, %(data-show-on-hover="true")
    refute_includes always, "data-show-on-hover"
  end

  test "sidebar group_action renders a button by default and a link with url" do
    button = view.render("components/sidebar/group_action", label: "Add project")
    link = view.render("components/sidebar/group_action", label: "Add project", url: "/projects/new")

    assert_includes button, %(data-sidebar-part="group-action")
    assert_includes button, %(<button)
    assert_includes button, %(aria-label="Add project")
    refute_includes button, "<a "

    assert_includes link, %(<a )
    assert_includes link, %(href="/projects/new")
    assert_includes link, %(data-sidebar-part="group-action")
  end
end
