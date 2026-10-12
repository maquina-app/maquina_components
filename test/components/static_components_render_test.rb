require "test_helper"

# Regressions for the static components: badge, card, stats and separator.
class StaticComponentsRenderTest < ActiveSupport::TestCase
  def view
    @view ||= ApplicationController.new.view_context
  end

  test "badge omits the class attribute when css_classes is blank" do
    html = view.render("components/badge") { "New" }

    refute_includes html, "class="
  end

  test "card parts accept string values as well as symbols" do
    assert_includes view.render("components/card/header", layout: "row") { "" }, %(data-layout="row")
    assert_includes view.render("components/card/title", size: "sm", text: "T"), %(data-size="sm")
    assert_includes view.render("components/card/content", spacing: "full") { "" }, %(data-spacing="full")

    footer = view.render("components/card/footer", align: "between", spacing: "full") { "" }
    assert_includes footer, %(data-spacing="full")
    assert_includes footer, %(data-align="between")
  end

  test "card parts omit data attributes for default values" do
    header = view.render("components/card/header", layout: "column") { "" }
    footer = view.render("components/card/footer", align: :start) { "" }

    refute_includes header, "data-layout"
    refute_includes footer, "data-align"
    refute_includes footer, "data-spacing"
  end

  # builtin_icon_for never consults the host app, so app-defined icons used to
  # render nothing. :sun is defined only by the dummy app's icon helper.
  test "stats_card renders app-defined icons through icon_for" do
    html = view.render("components/stats/stats_card", title: "Users", value: "42", icon: :sun)

    assert_includes html, "<svg"
    assert_includes html, %(<circle cx="12" cy="12" r="4")
  end

  test "stats_card still maps legacy kebab-case strings to built-in icons" do
    html = view.render("components/stats/stats_card", title: "Tasks", value: "7", icon: "clipboard-list")

    assert_includes html, "<svg"
  end
end
