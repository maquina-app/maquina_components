require "test_helper"

class ToastRenderTest < ActiveSupport::TestCase
  CONTROLLERS_DIR = File.expand_path("../../app/javascript/controllers", __dir__)

  def view
    @view ||= ApplicationController.new.view_context
  end

  test "action button is wired to toast#handleAction" do
    html = view.render("components/toast/action", label: "Undo")

    assert_includes html, %(<button type="button")
    assert_includes html, %(data-toast-part="action")
    assert_includes html, %(data-action="toast#handleAction")
  end

  test "action button keeps the caller's data-action alongside handleAction" do
    html = view.render("components/toast/action", label: "Undo",
      data: {action: "click->undo#perform"})

    assert_includes html, %(data-action="toast#handleAction click-&gt;undo#perform")
  end

  test "action link navigates instead of handling the action" do
    html = view.render("components/toast/action", label: "View", href: "/events", method: :post)

    assert_includes html, %(href="/events")
    assert_includes html, %(data-turbo-method="post")
    refute_includes html, "toast#handleAction"
  end

  test "action link keeps a caller-provided data-action" do
    html = view.render("components/toast/action", label: "View", href: "/events",
      data: {action: "click->tracker#log"})

    assert_includes html, %(data-action="click-&gt;tracker#log")
  end

  test "JS-built toasts set the toast controller's actionCallback value" do
    toaster_js = File.read(File.join(CONTROLLERS_DIR, "toaster_controller.js"))
    toast_js = File.read(File.join(CONTROLLERS_DIR, "toast_controller.js"))

    assert_match(/actionCallback:/, toast_js)
    assert_includes toaster_js, "data-toast-action-callback-value="
    refute_match(/data-toast-action-callback=/, toaster_js)
  end

  test "JS API runs action.onClick when the toast action fires" do
    toaster_js = File.read(File.join(CONTROLLERS_DIR, "toaster_controller.js"))

    assert_includes toaster_js, 'addEventListener("toast:action"'
    assert_includes toaster_js, "action.onClick"
  end
end
