require "test_helper"

# Renders the dummy app's home page and component preview pages, catching
# template errors (missing partials, bad strict locals) across the whole
# component tree.
class PreviewsSmokeTest < ActionDispatch::IntegrationTest
  test "home page renders" do
    get "/"
    assert_response :success
  end

  test "component previews render" do
    previews_root = File.expand_path("../dummy/app/views/previews", __dir__)

    Dir.glob("#{previews_root}/*/*.html.erb").each do |file|
      example = File.basename(file, ".html.erb")
      component = File.basename(File.dirname(file))

      get "/previews/#{component}/#{example}"
      assert_response :success, "previews/#{component}/#{example} failed to render"
    end
  end
end
