require "test_helper"

class EmptyHelperTest < ActiveSupport::TestCase
  def view
    @view ||= ApplicationController.new.view_context
  end

  # The default used to be :folder_open, which the engine does not ship: the
  # list state rendered no icon at all, or raised under strict_icons.
  test "empty_list_state renders a built-in default icon" do
    previous = MaquinaComponents.strict_icons
    MaquinaComponents.strict_icons = true

    html = view.empty_list_state(resource_name: "projects", new_path: "/projects/new")

    assert_includes html, %(data-empty-part="media")
    assert_includes html, "<svg"
    assert_includes html, "No projects yet"
    assert_includes html, "Create Project"
  ensure
    MaquinaComponents.strict_icons = previous
  end
end
