require "test_helper"
require_relative "css_source"

# Every structural hook the CSS styles — data-component="…" and
# data-*-part="…" — has to be written by something: an engine partial, an engine
# helper, an engine Stimulus controller, or the caller following the docs.
# A hook that nothing writes is dead CSS that reads as a feature: 0.5.1 styled
# [data-required] for months with no partial that emitted it, until the 0.6.0
# label partial finally did.
#
# The check runs CSS -> emitter only. The reverse direction (an attribute nobody
# styles) is noisy by design — components carry hooks for JavaScript and for
# host CSS.
class CssHooksTest < ActiveSupport::TestCase
  ENGINE_ROOT = File.expand_path("../../app", __dir__)
  REPO_ROOT = File.expand_path("../..", __dir__)

  # Where a hook may legitimately be written. Docs count: the form primitives
  # are CSS-only by design — the caller writes data-component="input" by hand,
  # so the documentation *is* the emitter.
  EMITTER_GLOBS = {
    "partials" => "#{ENGINE_ROOT}/views/components/**/*.erb",
    "helpers" => "#{ENGINE_ROOT}/helpers/**/*.rb",
    "controllers" => "#{ENGINE_ROOT}/javascript/**/*.js",
    "docs" => "#{REPO_ROOT}/docs/*.md",
    "skill" => "#{REPO_ROOT}/skill/**/*.md",
    "previews" => "#{REPO_ROOT}/test/dummy/app/views/**/*.erb"
  }.freeze

  # Hooks that are styled and written nowhere — dead rules kept only so this
  # guard can pass while it blocks new ones. Empty as of 0.6.0: every inherited
  # entry either gained the partial that emits it or had its rule deleted.
  # This list may shrink; it must never grow. Deleting the rule (or adding the
  # partial that emits it) is the fix.
  KNOWN_DEAD_HOOKS = [].freeze

  test "every styled component and part hook is emitted somewhere" do
    orphans = styled_hooks.reject { |attribute, value| emitted?(attribute, value) } - KNOWN_DEAD_HOOKS

    assert_empty orphans, <<~MESSAGE
      These hooks are styled by the engine but written by no partial, helper,
      Stimulus controller, preview or documented snippet — so the rules can never
      match anything. Either emit the attribute or delete the CSS. (If you are
      deliberately adding a caller-applied hook like the CSS-only form
      primitives, document it and the check will find it there.)

      #{orphans.map { |attribute, value| %(  [data-#{attribute}="#{value}"]) }.join("\n")}
    MESSAGE
  end

  test "the dead hook list has not grown and every entry is still dead" do
    revived = KNOWN_DEAD_HOOKS.select { |attribute, value| emitted?(attribute, value) }

    assert_empty revived, <<~MESSAGE
      These hooks now have an emitter, so they are no longer dead — remove them
      from KNOWN_DEAD_HOOKS so the list keeps shrinking and the guard keeps its
      teeth.

      #{revived.map { |attribute, value| %(  [data-#{attribute}="#{value}"]) }.join("\n")}
    MESSAGE

    unstyled = KNOWN_DEAD_HOOKS.reject { |hook| styled_hooks.include?(hook) }

    assert_empty unstyled, <<~MESSAGE
      These entries no longer appear in any stylesheet — the dead rule was
      deleted, which is the intended fix. Remove them from KNOWN_DEAD_HOOKS.

      #{unstyled.map { |attribute, value| %(  [data-#{attribute}="#{value}"]) }.join("\n")}
    MESSAGE
  end

  private

  # [["component", "badge"], ["card-part", "title"], …]
  def styled_hooks
    @styled_hooks ||= CssSource.all_rules.each_value.flat_map { |rules|
      rules.reject(&:at_rule?).flat_map do |rule|
        rule.selector.scan(/\[data-component="([a-z0-9-]+)"\]/).map { |(value)| ["component", value] } +
          rule.selector.scan(/\[data-([a-z0-9-]+-part)="([a-z0-9-]+)"\]/)
      end
    }.uniq.sort
  end

  def emitter_sources
    @emitter_sources ||= EMITTER_GLOBS.transform_values do |glob|
      Dir.glob(glob).sort.map { |path| File.read(path) }.join("\n")
    end
  end

  # An attribute reaches the DOM either as a Ruby data-hash key
  # (`card_part: :title`, `"combobox-part": "option"`) or as literal HTML
  # (`data-card-part="title"`), so accept both spellings of both.
  def emitted?(attribute, value)
    names = [attribute, attribute.tr("-", "_"), camelize(attribute)].uniq
    values = [value, value.tr("-", "_")].uniq

    emitter_sources.each_value.any? do |source|
      names.product(values).any? do |name, candidate|
        # Ruby/ERB hash form: sidebar_part: :rail / "sidebar-part" => "rail"
        source.match?(/["']?#{Regexp.escape(name)}["']?\s*:\s*[:"']?#{Regexp.escape(candidate)}\b/) ||
          # literal attribute in markup
          source.match?(/data-#{Regexp.escape(attribute)}=\\?["']#{Regexp.escape(value)}/) ||
          # Stimulus/JS form: el.dataset.breadcrumbPart = "dropdown"
          source.match?(/dataset\.#{Regexp.escape(camelize(name))}\s*=\s*["']#{Regexp.escape(candidate)}["']/)
      end
    end
  end

  # data-breadcrumb-part -> breadcrumbPart, matching the DOM dataset API.
  def camelize(attribute)
    head, *rest = attribute.split("-")
    [head, *rest.map(&:capitalize)].join
  end
end
