require "test_helper"

# dropdown_menu_simple used to raise NoMethodError on its first non-empty item:
# the block it passed to menu.content took no parameters, so the item/label/
# separator calls landed on the outer builder, which has none of them.
class DropdownMenuHelperTest < ActiveSupport::TestCase
  def view
    @view ||= ApplicationController.new.view_context
  end

  test "dropdown_menu_simple renders trigger, items, labels and separators" do
    html = view.dropdown_menu_simple("Actions", items: [
      {label: "Section"},
      {label: "Edit", href: "/edit", icon: :pencil},
      {separator: true},
      {label: "Delete", href: "/delete", method: :delete, destructive: true}
    ])

    assert_includes html, %(data-component="dropdown-menu")
    assert_includes html, "Actions"
    assert_includes html, %(data-dropdown-menu-part="label")
    assert_includes html, "Section"
    assert_includes html, %(href="/edit")
    assert_includes html, "Edit"
    assert_includes html, %(data-dropdown-menu-part="separator")
    assert_includes html, %(href="/delete")
    assert_includes html, %(data-variant="destructive")
  end

  test "dropdown_menu_simple passes trigger and content options through" do
    html = view.dropdown_menu_simple("Menu",
      items: [{label: "One", href: "/one"}],
      trigger_options: {variant: :ghost},
      content_options: {align: :end, width: :md})

    assert_includes html, %(data-variant="ghost")
    assert_includes html, %(data-align="end")
    assert_includes html, %(data-width="md")
  end

  test "dropdown_menu yields a content builder for items" do
    html = view.dropdown_menu do |menu|
      menu.trigger { "Open" }
      menu.content do |content|
        content.item "Profile", href: "/profile"
        content.separator
        content.item "Sign out", href: "/logout", method: :delete
      end
    end

    assert_includes html, "Open"
    assert_includes html, %(href="/profile")
    assert_includes html, %(href="/logout")
    assert_includes html, %(data-dropdown-menu-part="separator")
  end
end
