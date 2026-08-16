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

  test "a builtin icon an engine component asks for and does not exist raises" do
    with_strict_icons(true) do
      error = assert_raises MaquinaComponents::UnknownIconError do
        icons.builtin_icon_for(:chevron_but_wrong)
      end

      assert_match(/chevron_but_wrong/, error.message)
      assert_match(/will NOT help/, error.message,
        "the message must not send you to main_icon_svg_for, which cannot fix a builtin_icon_for miss")
    end
  end

  test "builtin_icon_for still renders nothing when strict_icons is off" do
    with_strict_icons(false) { assert_nil icons.builtin_icon_for(:chevron_but_wrong) }
  end

  test "builtin_icon_for ignores the host override" do
    host = Class.new do
      include MaquinaComponents::IconsHelper

      def main_icon_svg_for(name)
        "<svg data-from=\"host\"></svg>" if name == :briefcase
      end
    end.new

    assert_includes host.icon_for(:briefcase), "host"
    refute_includes host.builtin_icon_for(:briefcase), "host"
  end

  # Every chevron the engine's own components ask for, by the exact name they
  # ask for it. chevron_down was missing outright, and the combobox trigger
  # asked for the plural chevrons_up_down against a singular built-in, so both
  # triggers rendered no chevron at all.
  test "the chevrons engine components ask for all resolve" do
    %i[chevron_down chevron_up_down chevrons_up_down chevron_left chevron_right select_chevron].each do |name|
      assert_includes icons.builtin_icon_for(name).to_s, "<svg", "#{name} is not in the built-in set"
    end
  end

  test "chevron_down points down" do
    assert_includes icons.builtin_icon_for(:chevron_down), "m6 9 6 6 6-6"
  end

  test "data options reach the svg" do
    svg = '<svg xmlns="http://www.w3.org/2000/svg"></svg>'
    out = apply_icon_options(svg.dup, data: {"dropdown-menu-target": "chevron", other_key: "x"})

    assert_match(/data-dropdown-menu-target="chevron"/, out)
    assert_match(/data-other-key="x"/, out)
  end

  test "data options are escaped and skip nils" do
    svg = '<svg xmlns="http://www.w3.org/2000/svg"></svg>'
    out = apply_icon_options(svg.dup, data: {target: %(a"><script>), missing: nil})

    refute_match(/<script>/, out)
    refute_match(/data-missing/, out)
  end

  # The sweep that would have caught both broken triggers. builtin_icon_for is
  # deliberately isolated from the host's main_icon_svg_for, so a name the
  # engine does not ship is unfixable from an app -- it just renders nothing.
  # Only literal symbol call sites; the dynamic ones (toast's icon:, stats'
  # icon_name) take caller-supplied names and cannot be checked here.
  test "every literal builtin_icon_for call site in the engine's views resolves" do
    views = File.expand_path("../../app/views", __dir__)
    call_sites = Dir.glob(File.join(views, "**/*.erb")).sort.flat_map do |path|
      File.read(path).scan(/builtin_icon_for[(\s]+:([a-z0-9_]+)/).flatten.map do |name|
        [path.delete_prefix("#{views}/"), name.to_sym]
      end
    end

    assert_operator call_sites.size, :>=, 9,
      "the sweep stopped finding call sites -- check the scan pattern against the views"

    # strict_icons off on purpose: we want the whole list in one failure, not a
    # raise on the first miss.
    unresolved = with_strict_icons(false) do
      call_sites.reject { |_file, name| icons.builtin_icon_for(name) }
    end

    assert_empty unresolved.map { |file, name| "#{file} asks for #{name.inspect}" }.uniq,
      "an engine component asks for an icon the engine does not ship; it renders nothing at all"
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
