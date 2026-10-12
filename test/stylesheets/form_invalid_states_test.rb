require "test_helper"
require_relative "css_source"

# Every form control shows the same invalid state, keyed on both aria-invalid
# (server-side errors) and :user-invalid (native constraint validation after
# interaction), with the destructive halo gated to :focus-visible like input.
class FormInvalidStatesTest < ActiveSupport::TestCase
  CONTROLS = %w[input textarea select checkbox radio switch].freeze

  def rules
    @rules ||= CssSource.rules("form.css")
  end

  test "every control reacts to aria-invalid and :user-invalid with the destructive border" do
    CONTROLS.each do |control|
      rule = rules.find { |r|
        r.selector == %([data-component="#{control}"]:where([aria-invalid="true"], :user-invalid))
      }

      assert rule, "form.css has no aria-invalid/:user-invalid rule for #{control}"
      assert_includes rule.own_declarations, "var(--destructive", "#{control} invalid state must use the destructive token"
      refute_match(/outline-width/, rule.own_declarations,
        "#{control} paints a resting outline when invalid; the halo belongs to :focus-visible")
    end
  end

  test "every control rings destructive on focus when invalid" do
    CONTROLS.each do |control|
      selector = %([data-component="#{control}"]:where([aria-invalid="true"], :user-invalid):where(:focus-visible))

      assert rules.any? { |r| r.selector == selector && r.own_declarations.include?("outline-color") },
        "form.css has no focus-visible halo for an invalid #{control}"
    end
  end
end
