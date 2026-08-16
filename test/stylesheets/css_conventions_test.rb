require "test_helper"
require_relative "css_source"

# Source-level guards on app/assets/stylesheets/*.css.
#
# Every assertion here corresponds to a defect that shipped in 0.5.1 and
# survived because nothing checked for it. The engine is now flattened to
# specificity 0,1,0 inside `@layer components`, which means specificity no
# longer resolves anything: source order and token discipline are the only
# things keeping it correct, and neither is visible in a diff.
class CssConventionsTest < ActiveSupport::TestCase
  # Variables the host theme is contractually required to declare — the shadcn
  # palette the installer writes into theme.css. Using one of these without a
  # fallback is fine; using anything else without one is the `--success` /
  # `--warning` / `--info` bug: a variable that may simply not exist.
  BASE_PALETTE = %w[
    --background --foreground --card --card-foreground --popover --popover-foreground
    --primary --primary-foreground --secondary --secondary-foreground
    --muted --muted-foreground --accent --accent-foreground
    --destructive --destructive-foreground --border --input --ring
    --sidebar --sidebar-foreground --sidebar-primary --sidebar-primary-foreground
    --sidebar-accent --sidebar-accent-foreground --sidebar-border --sidebar-ring
    --sidebar-width --sidebar-width-icon --header-height
  ].freeze

  # calendar.css sets --cell-size on the calendar root itself, unconditionally,
  # before any rule reads it. It is local layout state, not a theme token.
  LOCAL_VARIABLES = %w[--cell-size].freeze

  # Radius declarations that are literal on purpose: these zero out an inner
  # edge so adjacent cells read as one shape. Listed by selector so a *new*
  # hardcoded radius still fails.
  STRUCTURAL_ZERO_RADIUS = {
    "calendar.css" => ['[data-state="range-start"]', '[data-state="range-middle"]', '[data-state="range-end"]'],
    "toggle_group.css" => ['[data-component="toggle-group"][data-variant="outline"]'],
    "sidebar.css" => ['[data-sidebar-part="root"][data-variant="inset"]']
  }.freeze

  # State tiers, in the order the cascade needs them declared: after variants.
  STATE_PSEUDO = /:hover\b|:focus-visible\b|:disabled\b|\[aria-invalid/

  # Parts that clear their outline on purpose: roving-focus menu items carrying
  # tabindex="-1", where focus moves under arrow keys and is shown as a
  # background change. They are never reached by Tab, so a ring would be noise.
  ROVING_FOCUS_PARTS = [
    "data-dropdown-menu-part=item",
    "data-combobox-part=option",
    "data-combobox-part=content"
  ].freeze

  # The only engine rule outside @layer components. It is a functional scroll
  # lock, not appearance: layered, a host's own unlayered `body { position: … }`
  # would beat it and the page would scroll behind an open drawer.
  UNLAYERED_EXCEPTIONS = {"drawer.css" => ["body[data-maquina-scroll-locked]"]}.freeze

  test "every var() either names a declared token or carries a fallback" do
    allowed = CssSource.declared_tokens + BASE_PALETTE + LOCAL_VARIABLES
    offenders = []

    CssSource.stylesheets.each do |file, css|
      CssSource.uncomment(css).each_line.with_index(1) do |line, number|
        line.scan(/var\(\s*(--[a-z0-9-]+)\s*\)/) do |(name)|
          offenders << "#{file}:#{number} var(#{name})" unless allowed.include?(name)
        end
      end
    end

    assert_empty offenders, <<~MESSAGE
      These var() calls name a variable that is neither declared in tokens.css nor
      part of the palette every host theme must define, and they supply no
      fallback — so in an app that does not happen to define them the declaration
      is simply dropped. That is how `--success` and `--warning` shipped as
      invisible badges. Either add the token to tokens.css or give the call a
      fallback: var(--x, <literal>).

      #{offenders.join("\n")}
    MESSAGE
  end

  test "the info role never falls back to the brand color" do
    offenders = []

    CssSource.stylesheets.each do |file, css|
      CssSource.uncomment(css).each_line.with_index(1) do |line, number|
        offenders << "#{file}:#{number} #{line.strip}" if line.match?(/var\(--info(-foreground)?,\s*var\(--primary/)
      end
    end

    assert_empty offenders, <<~MESSAGE
      An undefined --info must fall back to the neutral treatment, never to
      --primary. Falling back to the brand color is worse than no fallback at
      all: it renders informational alerts, badges and toasts as brand-colored
      calls to action, and nothing looks broken enough to report.

      #{offenders.join("\n")}
    MESSAGE
  end

  test "no radius is hardcoded outside the documented structural zeros" do
    applied = []
    literal = []

    CssSource.all_rules.each do |file, rules|
      rules.each do |rule|
        rule.own_declarations.scan(/@apply\s+([^;]+);/) do |(utilities)|
          utilities.scan(%r{[\w:./\[\]-]*rounded-[\w./\[\]-]+}) do |utility|
            applied << "#{rule.where} @apply #{utility} (#{rule.selector.squeeze(" ")[0, 60]})"
          end
        end

        rule.declarations.each do |property, value|
          next if property.start_with?("--")
          next unless property.end_with?("radius")

          remainder = without_var_calls(value).strip
          next if remainder.empty?
          next if remainder.match?(/\A[0\s]+\z/) && structural_zero?(file, rule.selector)

          literal << "#{rule.where} #{property}: #{value.strip} (#{rule.selector.squeeze(" ")[0, 60]})"
        end
      end
    end

    assert_empty applied + literal, <<~MESSAGE
      Shape is a token: every corner reads
      var(--<component>-radius, var(--<role>-radius, <literal>)). A `rounded-*`
      utility inside @apply, or a literal border-radius, is a corner a theme
      cannot reach — which is what made "square everything" a rewrite instead of
      four declarations. The only literal radii allowed are the documented
      structural zeros (calendar range edges, toggle-group inner seams, the
      inset sidebar panel); add a selector to STRUCTURAL_ZERO_RADIUS only if the
      zero is joining two shapes, never to silence a themeable corner.

      #{(applied + literal).join("\n")}
    MESSAGE
  end

  test "focus rings are outlines, never box-shadows" do
    offenders = []

    CssSource.all_rules.each_value do |rules|
      rules.reject(&:at_rule?).each do |rule|
        next unless rule.selector.match?(/:focus(-visible)?\b/)

        rule.declarations.each do |property, value|
          offenders << "#{rule.where} #{property}: #{value.strip[0, 60]}" if property == "box-shadow"
        end
        rule.own_declarations.scan(/@apply\s+([^;]+);/) do |(utilities)|
          if utilities.match?(/(?<![\w-])(ring|shadow)-/)
            offenders << "#{rule.where} @apply #{utilities.strip[0, 60]}"
          end
        end
      end
    end

    faked_band = CssSource.stylesheets.filter_map do |file, css|
      "#{file}: 0 0 0 2px var(--background) band survives" if CssSource.uncomment(css).include?("0 0 0 2px var(--background)")
    end

    assert_empty offenders + faked_band, <<~MESSAGE
      Focus rings are `outline` + `outline-offset` read from the ring tokens. A
      box-shadow ring competes with the elevation every variant declares — that
      collision is exactly what left 14 of 16 buttons with no visible focus ring
      in 0.5.1 — and it gets clipped by any overflow-hidden ancestor. The
      `0 0 0 2px var(--background)` half was a hand-painted backdrop band that an
      outline does not need.

      #{(offenders + faked_band).join("\n")}
    MESSAGE
  end

  test "no rule transitions outline-color" do
    offenders = []

    CssSource.all_rules.each_value do |rules|
      rules.reject(&:at_rule?).each do |rule|
        rule.own_declarations.scan(/@apply\s+([^;]+);/) do |(utilities)|
          utilities.split(/\s+/).each do |utility|
            next unless utility.match?(/(?<![\w-])transition-/)
            next unless utility == "transition-colors" || utility.include?("outline-color")

            offenders << "#{rule.where} @apply #{utility} (#{rule.selector.squeeze(" ")[0, 60]})"
          end
        end

        rule.declarations.each do |property, value|
          next unless property == "transition" || property == "transition-property"
          next unless value.include?("outline-color")

          offenders << "#{rule.where} #{property}: #{value.strip[0, 60]}"
        end
      end
    end

    assert_empty offenders, <<~MESSAGE
      A focus ring must appear instantly. Tailwind v4 folds `outline-color` into
      `transition-colors`, so that utility is unusable in this engine: the ring
      animates from its pre-focus value, which on a control that has never
      painted an outline is the initial `currentColor` — the control's own text
      color. On a filled variant that is a near-white ring for the first 150ms,
      i.e. no focus indicator on exactly the highest-stakes controls, and it
      makes every getComputedStyle read taken right after a Tab press report the
      previous color. That is what got --focus-ring-color reported as an inert
      token when it was working the whole time. Name the properties instead:
      transition-[color,background-color,border-color,text-decoration-color].

      #{offenders.join("\n")}
    MESSAGE
  end

  test "a part that suppresses its outline restores a token ring" do
    suppressed = {}
    restored = Set.new

    CssSource.all_rules.each_value do |rules|
      rules.reject(&:at_rule?).each do |rule|
        key = CssSource.subject(rule.selector)

        if rule.own_declarations.match?(/@apply[^;]*(?<![\w-])outline-(none|hidden)\b/) ||
            rule.declarations.any? { |property, value| property == "outline" && value.strip == "none" }
          suppressed[key] ||= rule
        end

        restored << key if rule.declarations.any? { |property, _| property == "outline-color" }
      end
    end

    offenders = (suppressed.keys - restored.to_a - ROVING_FOCUS_PARTS).map do |key|
      "#{suppressed[key].where} #{key} (#{suppressed[key].selector.squeeze(" ")[0, 60]})"
    end

    assert_empty offenders, <<~MESSAGE
      This part clears its outline and never paints one back from the
      --focus-ring-* tokens, so it is a tab stop with no focus indicator. That
      is how breadcrumb links shipped with an underline as their *only* focus
      signal — measured as the sole ringless stops on a dashboard header — and
      how the combobox search field shipped with nothing at all. Add a
      :focus-visible rule reading outline-width / -style / -color / -offset.

      Add to ROVING_FOCUS_PARTS only for a part that is genuinely not a tab stop
      (tabindex="-1" menu items whose focus is shown as a background change).

      #{offenders.join("\n")}
    MESSAGE
  end

  test "state rules are declared after the variant rules they must beat" do
    checked = 0
    offenders = []

    CssSource.all_rules.each do |file, rules|
      last_variant = {}
      first_state = {}

      rules.reject(&:at_rule?).each do |rule|
        CssSource.split_outside_brackets(rule.selector, /,/).each do |selector|
          subject_compound = CssSource.compounds(selector).last.to_s
          stateful = subject_compound.match?(STATE_PSEUDO)
          # A rule qualified by a variant on an *ancestor* is a scoped tier of
          # its own; it legitimately re-declares base and state together after
          # the unscoped rules (see toast's error variant). Only variants on the
          # styled element itself compete with that element's state rules.
          variant = subject_compound.include?("[data-variant=") && !stateful
          key = CssSource.subject(selector)

          last_variant[key] = rule if variant
          first_state[key] ||= rule if stateful && !rule.selector.include?("[data-variant=")
        end
      end

      (last_variant.keys & first_state.keys).each do |key|
        checked += 1
        variant_rule = last_variant[key]
        state_rule = first_state[key]
        next if variant_rule.offset < state_rule.offset

        offenders << <<~ENTRY
          #{file} — #{key}
            state   declared first at line #{state_rule.line}: #{state_rule.selector.squeeze(" ")[0, 80]}
            variant declared after at line #{variant_rule.line}: #{variant_rule.selector.squeeze(" ")[0, 80]}
        ENTRY
      end
    end

    assert_operator checked, :>=, 4, "the ordering check stopped covering anything — it must still compare at least the button, badge, toast and dropdown-menu item tiers"

    assert_empty offenders, <<~MESSAGE
      Every rule in the engine is specificity 0,1,0, so a later declaration wins
      outright and source order is the whole cascade. A state rule declared
      before the variants of the same element is dead for every variant that
      touches the same property — that is precisely the 0.5.1 button bug, where
      :focus-visible sat above the variant list and each variant's box-shadow
      erased the ring (2 of 16 buttons ringed). Move the state block below the
      variants.

      #{offenders.join("\n")}
    MESSAGE
  end

  test "every rule lives in @layer components except the documented scroll lock" do
    offenders = []

    CssSource.all_rules.each do |file, rules|
      rules.reject { |rule| rule.at_rule? || rule.layered? }.each do |rule|
        next if UNLAYERED_EXCEPTIONS.fetch(file, []).include?(rule.selector)

        offenders << "#{rule.where} #{rule.selector.squeeze(" ")[0, 80]}"
      end
    end

    assert_empty offenders, <<~MESSAGE
      An unlayered rule outranks every layer at any specificity, so it silently
      beats a caller's Tailwind utility and cannot be overridden without !important
      — the same trap the installed theme's unlayered `* { border-color }` shim
      sprang on every alert and toast border. Wrap the rule in
      @layer components. The single exception is drawer.css's
      body[data-maquina-scroll-locked], which is a functional scroll lock rather
      than appearance and must keep beating a host's own body rule; add to
      UNLAYERED_EXCEPTIONS only for another lock of that kind.

      #{offenders.join("\n")}
    MESSAGE
  end

  test "dark mode is expressed as tokens, not as prefers-color-scheme or property overrides" do
    media_queries = []
    dark_rules = []

    CssSource.all_rules.each do |file, rules|
      rules.each do |rule|
        media_queries << rule.where if rule.selector.match?(/@media[^{]*prefers-color-scheme/)
        next if rule.at_rule?
        next unless rule.selector.match?(/(\A|[^-\w])\.dark\b/)

        rule.declarations.each do |property, value|
          next if property.start_with?("--")

          dark_rules << "#{rule.where} #{property}: #{value.strip[0, 40]} (#{rule.selector.squeeze(" ")[0, 60]})"
        end
      end
    end

    assert_empty media_queries, <<~MESSAGE
      Dark mode in this engine is the host's `.dark` class, not the OS setting. A
      lone @media (prefers-color-scheme: dark) block flips one component against
      the user's explicit in-app choice, which is how 0.5.1 shipped a component
      that went dark on a light page.

      #{media_queries.join("\n")}
    MESSAGE

    assert_empty dark_rules, <<~MESSAGE
      A `.dark` rule that sets a real property is a specificity trap: it adds a
      class to the selector, so it outranks the 0,1,0 rule it is twinning and a
      consumer cannot override either one without matching the scope. Set a
      custom property instead and let the unscoped rule resolve it — that is what
      --control-fill and --select-chevron-image are for.

      #{dark_rules.join("\n")}
    MESSAGE
  end

  private

  # Removes var() calls at any nesting depth, innermost first, so what is left is
  # only the literal values a theme cannot reach.
  def without_var_calls(value)
    remainder = +""
    index = 0

    while index < value.length
      if value[index..].start_with?("var(")
        index = end_of_call(value, index + 3) + 1
      else
        remainder << value[index]
        index += 1
      end
    end

    remainder
  end

  # Index of the ")" closing the "(" at open_index.
  def end_of_call(value, open_index)
    depth = 0
    index = open_index

    while index < value.length
      depth += 1 if value[index] == "("
      if value[index] == ")"
        depth -= 1
        return index if depth.zero?
      end
      index += 1
    end

    index
  end

  def structural_zero?(file, selector)
    STRUCTURAL_ZERO_RADIUS.fetch(file, []).any? { |allowed| selector.include?(allowed) }
  end
end
