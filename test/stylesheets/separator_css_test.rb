require "test_helper"
require_relative "css_source"

# The horizontal separator is width: 100%. It used to carry mx-2 from the base
# rule as well, so every horizontal divider overflowed its container by 1rem.
# Only the vertical orientation keeps an inline margin (the gap between the
# items it divides); parents that want an inset divider set their own margin
# together with width: auto.
class SeparatorCssTest < ActiveSupport::TestCase
  def rule(file, selector)
    CssSource.rules(file).find { |r| r.selector == selector } ||
      flunk("#{file} has no #{selector} rule")
  end

  def margin_x?(rule)
    rule.own_declarations.match?(/@apply[^;]*\b-?m[xlr]?-|margin/)
  end

  test "the base and horizontal separator rules set no horizontal margin" do
    base = rule("separator.css", %([data-component="separator"]))
    horizontal = rule("separator.css", %([data-component="separator"]:where([data-orientation="horizontal"])))

    refute margin_x?(base), "the base separator rule must not add a margin (#{base.where})"
    refute margin_x?(horizontal), "a width: 100% separator with a horizontal margin overflows (#{horizontal.where})"
    assert_equal "100%", horizontal.declarations.to_h["width"]&.strip
  end

  test "the vertical separator keeps its inline gap" do
    vertical = rule("separator.css", %([data-component="separator"]:where([data-orientation="vertical"])))

    assert_match(/@apply[^;]*\bmx-2\b/, vertical.own_declarations)
  end

  test "inset separator parts pair their margin with width: auto" do
    {
      "sidebar.css" => %([data-sidebar-part="separator"]),
      "drawer.css" => %([data-drawer-part="separator"])
    }.each do |file, selector|
      part = rule(file, selector)

      assert_match(/@apply[^;]*\bw-auto\b/, part.own_declarations,
        "#{part.where} insets the separator, so it must drop the primitive's width: 100%")
    end
  end
end
