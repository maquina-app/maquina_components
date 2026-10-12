require "test_helper"

class ToggleGroupRenderTest < ActiveSupport::TestCase
  CONTROLLER_JS = File.expand_path("../../app/javascript/controllers/toggle_group_controller.js", __dir__)

  def view
    @view ||= ApplicationController.new.view_context
  end

  test "disabled group is marked aria-disabled for the controller to disable its items" do
    html = view.render("components/toggle_group", disabled: true) do
      view.render("components/toggle_group/item", value: "left") { "Left" }
    end

    assert_includes html, %(aria-disabled="true")
    assert_includes html, %(data-controller="toggle-group")
    assert_includes html, %(data-toggle-group-target="item")
  end

  test "enabled group has no aria-disabled" do
    html = view.render("components/toggle_group") do
      view.render("components/toggle_group/item", value: "left") { "Left" }
    end

    refute_includes html, "aria-disabled"
    refute_includes html, "disabled=\"disabled\""
  end

  test "helpers render every item disabled in a disabled group" do
    html = view.toggle_group_simple(disabled: true, items: [
      {value: "left", label: "Left"},
      {value: "right", label: "Right"}
    ])

    assert_includes html, %(aria-disabled="true")
    assert_equal 2, html.scan(/<button[^>]*disabled="disabled"/).size
  end

  test "controller disables the items of an aria-disabled group" do
    js = File.read(CONTROLLER_JS)

    assert_includes js, "itemTargetConnected(item)"
    assert_includes js, 'getAttribute("aria-disabled") === "true"'
  end

  test "controller emits toggle-group:change once" do
    js = File.read(CONTROLLER_JS)

    assert_equal 1, js.scan('this.dispatch("change"').size
    refute_includes js, 'new CustomEvent("toggle-group:change"'
  end
end
