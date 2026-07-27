require "test_helper"

# Renders the dummy app's home page and component preview pages, catching
# template errors (missing partials, bad strict locals) across the whole
# component tree.
class PreviewsSmokeTest < ActionDispatch::IntegrationTest
  test "home page renders" do
    get "/"
    assert_response :success
  end

  # Previews that legitimately render no component hook. Keep this empty if you
  # can: a preview with nothing in it is a documentation page that shows the
  # reader nothing.
  COMPONENTLESS_PREVIEWS = [].freeze

  test "component previews render" do
    each_preview do |component, example|
      get "/previews/#{component}/#{example}"
      assert_response :success, "previews/#{component}/#{example} failed to render"
    end
  end

  # A status check cannot tell a real component from a hand-rolled div, which is
  # how previews/sidebar/default shipped for months rendering plain markup that
  # merely looked like the sidebar: the page was green, the docs were wrong, and
  # any CSS change to the real component left the preview untouched. Assert the
  # page actually contains engine components.
  test "every preview renders real components, not hand-rolled markup" do
    empty = []

    each_preview do |component, example|
      next if COMPONENTLESS_PREVIEWS.include?("#{component}/#{example}")

      get "/previews/#{component}/#{example}"
      hooks = response.body.scan(/data-(?:component|[a-z-]+-part)="/).size
      empty << "previews/#{component}/#{example}" if hooks.zero?
    end

    assert_empty empty, <<~MESSAGE
      These previews render without a single data-component or data-*-part
      attribute, so whatever they show is not built from this library. The docs
      site embeds them as the canonical example of each component; a preview that
      hand-rolls its markup keeps looking right while the component it documents
      drifts or breaks.

      #{empty.join("\n")}
    MESSAGE
  end

  private

  def each_preview
    Dir.glob(File.expand_path("../dummy/app/views/previews/*/*.html.erb", __dir__)).sort.each do |file|
      yield File.basename(File.dirname(file)), File.basename(file, ".html.erb")
    end
  end
end
