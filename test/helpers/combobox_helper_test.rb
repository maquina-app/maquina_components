require "test_helper"

# combobox_simple used to render a trigger and an empty popover: the shortcuts
# on the outer builder &.-delegated to a content builder that was never
# assigned, so the input, list, options and empty state all vanished silently.
class ComboboxHelperTest < ActiveSupport::TestCase
  def view
    @view ||= ApplicationController.new.view_context
  end

  test "combobox_simple renders search input, every option and the empty state" do
    html = view.combobox_simple(
      name: "framework",
      value: "remix",
      placeholder: "Select framework...",
      search_placeholder: "Find one...",
      empty_text: "Nothing matches.",
      options: [
        {value: "nextjs", label: "Next.js"},
        {value: "remix", label: "Remix"},
        {value: "rails", label: "Rails", disabled: true}
      ]
    )

    assert_includes html, %(data-combobox-part="input")
    assert_includes html, %(placeholder="Find one...")
    assert_includes html, %(data-combobox-part="list")

    assert_includes html, %(data-value="nextjs")
    assert_includes html, "Next.js"
    assert_includes html, %(data-value="remix")
    assert_includes html, "Remix"
    assert_includes html, %(data-value="rails")
    assert_includes html, "Rails"

    assert_includes html, %(data-combobox-part="empty")
    assert_includes html, "Nothing matches."
  end

  test "combobox_simple marks the current value as selected" do
    html = view.combobox_simple(name: "fruit", value: "b",
      options: [{value: "a", label: "Apple"}, {value: "b", label: "Banana"}])

    assert_match(/data-value="b"[^>]*data-selected="true"/, html)
    assert_match(/data-value="a"[^>]*data-selected="false"/, html)
  end

  test "combobox yields nested builders for content, list and groups" do
    html = view.combobox(name: "country", placeholder: "Pick one") do |cb|
      cb.trigger
      cb.content do |content|
        content.input placeholder: "Search countries"
        content.list do |list|
          list.group do |group|
            group.label "North America"
            group.option(value: "mx") { "Mexico" }
          end
          list.separator
          list.option(value: "jp") { "Japan" }
        end
        content.empty
      end
    end

    assert_includes html, %(placeholder="Search countries")
    assert_includes html, %(data-combobox-part="group")
    assert_includes html, "North America"
    assert_includes html, %(data-value="mx")
    assert_includes html, "Mexico"
    assert_includes html, %(data-combobox-part="separator")
    assert_includes html, %(data-value="jp")
  end

  test "the input/list/empty shortcuts on the outer builder still work" do
    html = view.combobox(name: "legacy") do |cb|
      cb.trigger
      cb.content do
        cb.input placeholder: "Legacy search"
        cb.list do |list|
          list.option(value: "one") { "One" }
        end
        cb.empty text: "Nope."
      end
    end

    assert_includes html, %(placeholder="Legacy search")
    assert_includes html, %(data-value="one")
    assert_includes html, "Nope."
  end
end
