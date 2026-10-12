require "test_helper"

class BreadcrumbsRenderTest < ActiveSupport::TestCase
  def view
    @view ||= ApplicationController.new.view_context
  end

  test "breadcrumbs default their aria-label" do
    html = view.render("components/breadcrumbs") { "" }

    assert_equal 1, html.scan("aria-label=").size
    assert_includes html, %(aria-label="Breadcrumb")
  end

  test "a caller's aria-label replaces the default instead of duplicating it" do
    dashed = view.render("components/breadcrumbs", "aria-label": "You are here") { "" }
    nested = view.render("components/breadcrumbs", aria: {label: "Ruta"}) { "" }

    [[dashed, "You are here"], [nested, "Ruta"]].each do |html, label|
      assert_equal 1, html.scan("aria-label=").size
      assert_includes html, %(aria-label="#{label}")
    end
  end
end
