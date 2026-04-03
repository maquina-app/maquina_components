require "test_helper"

class IconsHelperTest < ActionView::TestCase
  include MaquinaComponents::IconsHelper

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
