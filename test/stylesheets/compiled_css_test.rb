require "test_helper"
require_relative "css_source"

# Guards on the *compiled* stylesheet. Three of this release's contracts are
# invisible in the source and only exist after Tailwind runs:
#
#   * `@theme static` — without `static`, Tailwind tree-shakes theme variables
#     that no utility class references, and the engine reads every one of these
#     from a hand-written var(). The whole token layer can vanish while the
#     source still looks right.
#   * layer order — `theme` before `components` before `utilities` is what makes
#     a caller's utility beat the engine and an engine default lose to a host
#     token.
#   * cross-file source order — the only tie-breaker left once every rule is
#     0,1,0.
#
# CI builds this before running tests (see .github/workflows/ci.yml); locally it
# skips rather than failing when the artifact is absent.
class CompiledCssTest < ActiveSupport::TestCase
  COMPILED_CSS = File.expand_path("../dummy/app/assets/builds/tailwind.css", __dir__)

  ROLE_TOKENS = %w[
    --control-radius --surface-radius --mark-radius --pill-radius
    --focus-ring-width --focus-ring-offset --focus-ring-style
    --elevation-control --elevation-raised --elevation-overlay
    --label-weight --value-weight
  ].freeze

  setup do
    unless File.exist?(COMPILED_CSS)
      skip "#{COMPILED_CSS} is missing — run `cd test/dummy && bin/rails tailwindcss:build`"
    end

    @css = File.read(COMPILED_CSS)
  end

  test "every role token survives compilation into @layer theme" do
    theme_layer = layer_body("theme")
    missing = ROLE_TOKENS.reject { |token| theme_layer.match?(/#{Regexp.escape(token)}\s*:/) }

    assert_empty missing, <<~MESSAGE
      These tokens are declared in tokens.css but never reached the compiled
      @layer theme, so every var() that reads them silently fell back to its
      literal and the token layer is decoration. Check, in order: that tokens.css
      is still imported first from engine.css; that the token was not renamed;
      and that `@theme` still says `static` — Tailwind prunes theme variables no
      utility references, which bites the moment a token name falls inside one of
      Tailwind's own namespaces (--radius-*, --shadow-*), and the engine reads
      these only from hand-written var() calls.

      missing: #{missing.join(", ")}
    MESSAGE

    assert_equal ROLE_TOKENS.size, CssSource.declared_tokens.size,
      "tokens.css declares #{CssSource.declared_tokens.to_a.inspect}, but this test only checks #{ROLE_TOKENS.inspect} — add the new role token here so it is covered too"
  end

  test "cascade layers are emitted in theme, components, utilities order" do
    order = %w[theme components utilities].map { |layer| [layer, @css.index("@layer #{layer}")] }

    order.each do |layer, index|
      assert index, "@layer #{layer} is missing from the compiled CSS entirely"
    end

    assert_equal order.map(&:first), order.sort_by(&:last).map(&:first), <<~MESSAGE
      Layer order is the engine's whole override story: `theme` first so a host's
      unlayered :root beats the engine's token defaults, `components` next, and
      `utilities` last so a class passed through css_classes: wins. Emitted in
      any other order, either the engine clobbers a host token or a caller's
      utility stops applying with nothing in the diff to explain it.

      found: #{order.sort_by(&:last).map { |layer, index| "#{layer}@#{index}" }.join(" -> ")}
    MESSAGE
  end

  test "the button focus ring is compiled after every button variant" do
    ring = @css.index(/\[data-component=.?button.?\]:where\(:focus-visible\)/)
    refute_nil ring, "the compiled CSS has no [data-component=button]:where(:focus-visible) rule at all — the ring is gone, not merely losing"

    variants = @css.enum_for(:scan, /\[data-component=.?button.?\]:where\(\[data-variant=[a-z-]+\]\)\s*\{/)
      .map { Regexp.last_match.begin(0) }

    assert_operator variants.size, :>=, 5,
      "expected the compiled CSS to still carry the button variant rules; found #{variants.size}"

    late = variants.select { |offset| offset > ring }

    assert_empty late, <<~MESSAGE
      A button variant rule is compiled after the focus ring at equal
      specificity, so the variant's own box-shadow/background wins and that
      variant has no visible focus ring. This shipped in 0.5.1: only the two
      destructive buttons ringed, because destructive was the one variant that
      re-declared its own focus rule. Source order inside form.css is the only
      thing holding this — the ring block must stay below the variant list.

      ring at #{ring}; variants after it at #{late.join(", ")}
    MESSAGE
  end

  private

  # Contents of a top-level `@layer <name> { … }` block in the minified output.
  def layer_body(name)
    start = @css.index("@layer #{name}")
    return "" unless start

    open = @css.index("{", start)
    depth = 0
    index = open

    while index < @css.length
      case @css[index]
      when "{" then depth += 1
      when "}"
        depth -= 1
        break if depth.zero?
      end
      index += 1
    end

    @css[(open + 1)...index].to_s
  end
end
