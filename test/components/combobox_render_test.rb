require "test_helper"

class ComboboxRenderTest < ActiveSupport::TestCase
  CONTROLLER_JS = File.expand_path("../../app/javascript/controllers/combobox_controller.js", __dir__)

  def view
    @view ||= ApplicationController.new.view_context
  end

  # name: used to submit nothing: no input carried the selection.
  test "name renders a hidden input carrying the value" do
    html = view.render("components/combobox", name: "project[framework]", value: "rails") { |_id| "" }

    assert_match(/<input[^>]*type="hidden"[^>]*name="project\[framework\]"[^>]*value="rails"[^>]*data-combobox-target="hiddenInput"/, html)
  end

  test "the hidden input submits an empty value until something is selected" do
    html = view.render("components/combobox", name: "framework") { |_id| "" }

    assert_match(/<input[^>]*type="hidden"[^>]*name="framework"/, html)
  end

  test "no name, no hidden input" do
    html = view.render("components/combobox") { |_id| "" }

    refute_includes html, %(type="hidden")
  end

  test "combobox_simple submits its value through the hidden input" do
    html = view.combobox_simple(name: "fruit", value: "b",
      options: [{value: "a", label: "Apple"}, {value: "b", label: "Banana"}])

    assert_match(/<input[^>]*name="fruit"[^>]*value="b"/, html)
  end

  test "the controller writes the hidden input whenever the value changes" do
    source = File.read(CONTROLLER_JS)

    assert_includes source, %("hiddenInput")
    assert_match(/valueValueChanged\(\)\s*\{[^}]*updateHiddenInput\(\)/m, source)
    # valueValueChanged runs from an attribute observer, after combobox:change;
    # select() writes the input itself so listeners read the new value
    assert_match(/select\(event\)\s*\{.*?updateHiddenInput\(\).*?this\.dispatch\("change"/m, source)
  end
end
