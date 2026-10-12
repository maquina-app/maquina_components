require "test_helper"

# Every partial takes css_classes: "" by default and must pass it through
# as css_classes.presence, so a caller who adds no classes gets no class
# attribute at all rather than an empty class="".
class EmptyClassAttributeTest < ActiveSupport::TestCase
  PARTIALS_ROOT = MaquinaComponents::Engine.root.join("app/views/components")

  REQUIRED_LOCALS = {
    "components/simple_table" => {collection: [], columns: [{key: :name, label: "Name"}]},
    "components/breadcrumbs/link" => {href: "/"},
    "components/calendar/header" => {month: 1, year: 2026, month_name: "January"},
    "components/calendar/week" => {days: (Date.new(2026, 1, 4)..Date.new(2026, 1, 10)).to_a, display_month: Date.new(2026, 1, 1)},
    "components/combobox/content" => {id: "combo"},
    "components/combobox/option" => {value: "a"},
    "components/combobox/trigger" => {for_id: "combo"},
    "components/pagination/link" => {href: "/"},
    "components/sidebar/group_action" => {label: "Add"},
    "components/sidebar/menu_action" => {label: "More"},
    "components/sidebar/menu_button" => {title: "Home", url: "/"},
    "components/stats/stats_card" => {title: "Users", value: "10"},
    "components/toast/action" => {label: "Undo"},
    "components/toggle_group/item" => {value: "a"}
  }

  # Optional locals that switch on markup carrying its own class hooks
  # (icon_classes, value_classes, the combobox check mark).
  EXTRA_CASES = {
    "components/menu_button" => {title: "Acme", text_icon: "AC"},
    "components/sidebar/menu_link" => {title: "Acme", text_icon: "AC"},
    "components/stats/stats_card" => {title: "Users", value: "10", icon: :check},
    "components/combobox/option" => {value: "a", selected: true}
  }

  def view
    @view ||= ApplicationController.new.view_context
  end

  def self.partial_names
    Dir[PARTIALS_ROOT.join("**/_*.html.erb")].sort.map do |path|
      relative = Pathname(path).relative_path_from(PARTIALS_ROOT).to_s
      "components/" + relative.sub(/(\A|\/)_/, '\1').delete_suffix(".html.erb")
    end
  end

  partial_names.each do |partial|
    test "#{partial} renders no empty class attribute with defaults" do
      assert_no_empty_class partial, REQUIRED_LOCALS.fetch(partial, {})
    end
  end

  EXTRA_CASES.each do |partial, locals|
    test "#{partial} renders no empty class attribute with #{locals.keys.join(", ")}" do
      assert_no_empty_class partial, locals
    end
  end

  test "sidebar and drawer roots keep their loading class without trailing space" do
    assert_includes view.render("components/sidebar") { "" }, %(class="group peer sidebar-loading")
    assert_includes view.render("components/drawer") { "" }, %(class="group peer drawer-loading")
    assert_includes view.render("components/sidebar", css_classes: "x") { "" }, %(class="group peer sidebar-loading x")
  end

  private

  def assert_no_empty_class(partial, locals)
    html = view.render(partial, **locals) { "content" }

    assert_no_match(/class="\s*"/, html, "#{partial} rendered an empty class attribute")
    assert_no_match(/class="[^"]*\s"/, html, "#{partial} rendered a class with trailing whitespace")
  end
end
