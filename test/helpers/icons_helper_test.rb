require "test_helper"

class IconsHelperTest < ActionView::TestCase
  include MaquinaComponents::IconsHelper

  # The engine's icon_for, without the dummy app's override in the way.
  class EngineIcons
    include MaquinaComponents::IconsHelper
  end

  def icons
    @icons ||= EngineIcons.new
  end

  def with_strict_icons(value)
    previous = MaquinaComponents.strict_icons
    MaquinaComponents.strict_icons = value
    yield
  ensure
    MaquinaComponents.strict_icons = previous
  end

  test "triangle_alert answers to the alert_triangle alias" do
    assert_equal icons.icon_for(:triangle_alert), icons.icon_for(:alert_triangle)
    assert_includes icons.icon_for(:alert_triangle), "<svg"
  end

  test "briefcase is part of the built-in set" do
    svg = icons.icon_for(:briefcase)

    assert_includes svg, "<svg"
    assert_includes svg, %(viewBox="0 0 24 24")
    assert_includes svg, %(stroke="currentColor")
  end

  test "an unknown icon raises when strict_icons is on" do
    with_strict_icons(true) do
      error = assert_raises MaquinaComponents::UnknownIconError do
        icons.icon_for(:briefcase_but_wrong)
      end

      assert_match(/briefcase_but_wrong/, error.message)
    end
  end

  test "an unknown icon renders nothing when strict_icons is off" do
    with_strict_icons(false) do
      assert_nil icons.icon_for(:briefcase_but_wrong)
    end
  end

  test "a nil name is never an error" do
    with_strict_icons(true) { assert_nil icons.icon_for(nil) }
  end

  test "strict_icons defaults to development and test" do
    assert MaquinaComponents.strict_icons, "expected strict icons in the test environment"
  end

  test "adds class when svg has no class attribute" do
    svg = '<svg xmlns="http://www.w3.org/2000/svg"></svg>'
    out = apply_icon_options(svg.dup, class: "foo-test")
    assert_match(/class="foo-test"/, out)
  end

  test "does not merge classes when svg has existing class" do
    svg = '<svg class="existing" xmlns="http://www.w3.org/2000/svg"></svg>'
    out = apply_icon_options(svg.dup, class: "new-test")
    assert_match(/class="new-test"/, out)
    refute_match(/existing/, out)
  end

  test "handles class array and single/double quotes" do
    svg_single = "<svg class='a' xmlns=\"http://www.w3.org/2000/svg\"></svg>"
    out1 = apply_icon_options(svg_single.dup, class: "b c")
    assert_match(/class='b c'/, out1)

    svg_double = '<svg class="a" xmlns="http://www.w3.org/2000/svg"></svg>'
    out2 = apply_icon_options(svg_double.dup, class: "b c")
    assert_match(/class="b c"/, out2)
  end
end
