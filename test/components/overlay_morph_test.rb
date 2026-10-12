require "test_helper"

# Guards the page-refresh behaviour of the sidebar and drawer controllers. There
# is no JS runner in this repo, so these read the controller source; the
# behaviour itself is verified in a browser (see CLAUDE.md, Testing & Browser
# Verification). A same-URL morph used to close an open mobile sidebar and strip
# the trigger's aria-expanded.
class OverlayMorphTest < ActiveSupport::TestCase
  CONTROLLERS = File.expand_path("../../app/javascript/controllers", __dir__)

  %w[sidebar drawer].each do |name|
    test "#{name} controller treats a same-path replace visit as a page refresh" do
      js = controller_source(name)

      assert_includes js, %(document.addEventListener("turbo:visit", this.boundTrackVisit))
      assert_match(/action === "replace" &&\s+new URL\(url, window\.location\.href\)\.pathname === window\.location\.pathname/, js)
    end

    test "#{name} controller teardown only releases the scroll lock during a page refresh" do
      teardown = method_body(controller_source(name), "teardown")

      assert_match(/if \(this\._refreshing\) \{\s+this\.unlockScroll\(\)\s+return\s+\}/, teardown)
    end

    test "#{name} controller keeps its owned attributes out of the morph" do
      js = controller_source(name)

      assert_includes js, %(document.addEventListener("turbo:before-morph-attribute", this.boundPreserveAttribute))
      assert_includes js, "event.preventDefault()"
      assert_includes js, %(["data-#{name}-open-value"])
    end

    test "#{name} controller re-applies state and re-syncs the trigger after a morph" do
      handle_morph = method_body(controller_source(name), "handleMorph")

      assert_includes handle_morph, "this.updateState()"
      assert_includes handle_morph, "this.dispatchStateChange()"
      refute_includes handle_morph, "this.openValue = false"
    end

    test "#{name} controller drops the synchronous _morphing guard" do
      refute_includes controller_source(name), "_morphing"
    end

    test "#{name} controller scroll lock is idempotent and only released by its owner" do
      js = controller_source(name)

      assert_match(/lockScroll\(\) \{\s+if \(!this\._scrollLocked\) \{/, js)
      assert_match(/unlockScroll\(\) \{\s+if \(!this\._scrollLocked\) return/, js)
    end

    test "#{name}-trigger controller keeps aria-expanded across morphs" do
      js = File.read(File.join(CONTROLLERS, "#{name}_trigger_controller.js"))

      assert_includes js, %(this.element.addEventListener("turbo:before-morph-attribute", this.preserveAttribute))
      assert_match(/\["aria-expanded", "aria-controls"/, js)
    end
  end

  test "sidebar closes when crossing into mobile whatever its collapsible state" do
    body = method_body(controller_source("sidebar"), "handleScreenSizeChange")

    refute_includes body, %(=== "none")
    assert_match(/else if \(!wasMobile && isMobile\) \{\s+this\.openValue = false/, body)
  end

  private

  def controller_source(name)
    File.read(File.join(CONTROLLERS, "#{name}_controller.js"))
  end

  # The body of a class method: from its signature to the next method at the
  # same two-space indentation.
  def method_body(js, name)
    js[/^  #{name}\([^)]*\) \{\n.*?^  \}\n/m] or flunk "#{name}() not found"
  end
end
