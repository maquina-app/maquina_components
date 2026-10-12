require "test_helper"

class DrawerRenderTest < ActiveSupport::TestCase
  def view
    @view ||= ApplicationController.new.view_context
  end

  test "drawer trigger applies its variant and size locals" do
    html = view.render("components/drawer/trigger", variant: :outline, size: :sm) { "Open" }

    assert_includes html, %(data-component="button")
    assert_includes html, %(data-variant="outline")
    assert_includes html, %(data-size="sm")
  end

  test "drawer trigger defaults to the default variant and size" do
    html = view.render("components/drawer/trigger") { "Open" }

    assert_includes html, %(data-variant="default")
    assert_includes html, %(data-size="default")
  end

  test "drawer trigger still honors the data: { variant: } workaround" do
    html = view.render("components/drawer/trigger", data: {variant: :ghost}) { "Open" }

    assert_includes html, %(data-variant="ghost")
    assert_equal 1, html.scan("data-variant=").size
  end

  test "drawer close is an icon button without a variant" do
    html = view.render("components/drawer/close")

    assert_includes html, %(data-drawer-part="close")
    refute_includes html, "data-component="
    refute_includes html, "data-variant="
  end

  test "drawer close with a variant renders a styled button and no stray attribute" do
    html = view.render("components/drawer/close", show_icon: false, variant: :outline, size: :sm) { "Cancel" }

    assert_includes html, %(data-component="button")
    assert_includes html, %(data-variant="outline")
    assert_includes html, %(data-size="sm")
    assert_includes html, %(data-action="click-&gt;drawer#close")
    refute_match(/\svariant="/, html)
    refute_match(/\ssize="/, html)
  end

  test "drawer preview renders the footer close as an outline button" do
    html = view.render(template: "previews/drawer/default")

    close = html[/<button[^>]*data-drawer-part="close"[^>]*data-variant="outline"[^>]*>|<button[^>]*data-variant="outline"[^>]*data-drawer-part="close"[^>]*>/]
    assert close, "expected the preview's footer close to be an outline button"
    refute_match(/<button[^>]*\svariant="outline"/, html)
  end

  test "drawer_state treats a missing cookie as closed" do
    helper = DrawerStateHelperHost.new({})

    assert_equal :closed, helper.drawer_state
    assert helper.drawer_closed?
    refute helper.drawer_open?
  end

  test "drawer_state reads the cookie" do
    assert_equal :open, DrawerStateHelperHost.new("drawer_state" => "true").drawer_state
    assert_equal :closed, DrawerStateHelperHost.new("drawer_state" => "false").drawer_state
    assert_equal :open, DrawerStateHelperHost.new("cart" => "true").drawer_state("cart")
  end

  class DrawerStateHelperHost
    include MaquinaComponents::DrawerHelper

    attr_reader :cookies

    def initialize(cookies) = @cookies = cookies
  end
end
