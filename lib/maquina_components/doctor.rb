# frozen_string_literal: true

module MaquinaComponents
  # Migration scanner behind `rake maquina:doctor`.
  #
  # Run inside a consuming app, it looks for the app's own CSS/view/JS patterns
  # that a maquina release makes redundant or outright breaks, and prints
  # file:line plus a suggested replacement for each. Advisory only: it never
  # edits anything and never fails a build.
  #
  # Findings carry the release that introduced them, so the report stays useful
  # across upgrades rather than describing a single migration.
  #
  # Plain Ruby on purpose - no Rails, no extra gems - so it can also be run
  # against a directory from the engine's own repo.
  class Doctor
    Finding = Struct.new(:path, :line, :source, :severity, :rule, :suggestion, :version)

    SEVERITIES = {
      breaking: "BREAKING     - stops working after upgrading",
      review: "REVIEW       - still works, but there is now a token for it",
      cleanup: "CLEANUP      - probably unnecessary now"
    }.freeze

    CSS_GLOBS = [
      "app/assets/stylesheets/**/*.css",
      "app/assets/tailwind/**/*.css",
      "app/assets/**/*.css",
      "app/javascript/**/*.css",
      "app/views/**/*.css"
    ].freeze

    VIEW_GLOBS = [
      "app/views/**/*.erb",
      "app/views/**/*.html",
      "app/components/**/*.erb",
      "app/helpers/**/*.rb"
    ].freeze

    JS_GLOBS = [
      "app/javascript/**/*.js"
    ].freeze

    EXCLUDED = %r{/(node_modules|tmp|vendor|coverage)/|/app/assets/builds/}

    # A component-owned selector: data-component or any data-*-part hook.
    COMPONENT_SELECTOR = /\[data-(?:component|[a-z]+(?:-[a-z]+)*-part)\s*[~|^$*]?=/
    # A rule whose every selector is the universal one, e.g. `*` or
    # `*, ::before, ::after` — the shape of a Tailwind-v3-style preflight shim.
    UNIVERSAL_SELECTOR = /\A\*(\s*,\s*(\*|::?[a-z-]+))*\z/
    PRESENCE_ACTIVE = /\[data-active\](?!\s*[~|^$*]?=)/
    TAILWIND_ACTIVE_VARIANT = /data-\[active\]/
    SVG_DATA_URI = /data:image\/svg\+xml/
    # Assigning a data URI to one of the five mark properties IS the 0.6.0
    # pattern, so it must not be reported as a restated rule.
    MARK_TOKEN_ASSIGNMENT = /--(?:checkbox-mark|checkbox-indeterminate|radio-mark|switch-thumb|select-chevron)-image\s*:/
    RADIUS_DECL = /(?:border-radius\s*:|@apply[^;{}]*\brounded(?:-[a-z0-9\[\].\/-]+)?\b)/
    SHADOW_DECL = /(?:box-shadow\s*:|@apply[^;{}]*\b(?:shadow|ring)(?:-[a-z0-9\[\].\/-]+)?\b)/
    FOCUS_SELECTOR = /:focus(-visible|-within)?\b/

    # 0.7.1 -----------------------------------------------------------------
    # The destructive pair plus the surface it lands on, read out of a host
    # theme. Lightness alone cannot separate the two shipped palette
    # conventions -- a tint palette's dark block has the same shape as a
    # shadcn palette's light block -- so the check measures the symptom
    # (error text disappearing into its own card) instead. See docs/theming.md.
    DESTRUCTIVE_DECL = /\A--(destructive|destructive-foreground|card|background)\s*:\s*(.+)\z/m
    OKLCH_LIGHTNESS = /oklch\(\s*([0-9.]+)(%?)/
    # Oklch lightness gap below which text is effectively invisible on its
    # surface. A proxy for a contrast ratio, deliberately conservative: this
    # rule is BREAKING, so it must not fire on a merely low-contrast palette.
    CONTRAST_FLOOR = 0.25
    # Only :root / .dark / @theme declare a palette; a component-level override
    # of the same name is not a statement about the app's convention.
    THEME_SCOPE = /\A(:root|html|:where\(:root\)|\.dark|html\.dark|\[data-theme[^\]]*\]|)\s*\z/

    ERROR_PART = /data-form-part=["']error["']|form_part:\s*[:"']error/
    FIELD_WITH_ERRORS = /field_with_errors/
    ARIA_INVALID = /aria-invalid|aria:\s*\{[^}]*\binvalid\b|\baria_invalid\b/
    HANDROLLED_ERROR_COLOR = /\btext-destructive\b|\btext-red-\d/

    # A form field, raw or through a Rails helper. Matched against a bounded
    # window rather than a line: helper calls routinely span five or six lines,
    # and a per-line regex would silently miss almost every real one.
    FIELD_OPENER = /<(?:input|textarea)\b|\bf\.(?:text_field|text_area|email_field|password_field|number_field|url_field|telephone_field|phone_field|search_field|date_field)\b/
    FIELD_COMPONENT = /data-component=["'](?:input|textarea)["']|component:\s*[:"'](?:input|textarea)["']?/
    FIELD_REQUIRED = /\brequired\b/
    FIELD_PLACEHOLDER = /\bplaceholder\b/

    DROPDOWN_FLIP_HINT = /dataset\.side|["']data-side["']|setAttribute\(\s*["']data-side["']/

    attr_reader :root, :findings, :scanned_files

    def initialize(root)
      @root = File.expand_path(root.to_s)
      @findings = []
      @scanned_files = 0
      # Cross-file state: some 0.7.1 rules are conclusions about the whole app,
      # not about one line, so they are evaluated after the scan.
      @destructive_tokens = {}
      @aria_invalid_seen = false
      @error_sites = []
    end

    def run
      each_file(CSS_GLOBS) { |path| scan_css(path) }
      each_file(VIEW_GLOBS) { |path|
        scan_markup(path)
        scan_form_fields(path)
      }
      each_file(JS_GLOBS) { |path|
        scan_markup(path)
        scan_javascript(path)
      }
      check_destructive_palette
      check_invalid_without_aria
      self
    end

    def findings_for(severity)
      findings.select { |finding| finding.severity == severity }
    end

    def report
      out = []
      out << "maquina_components doctor"
      out << "Scanned #{scanned_files} file#{"s" unless scanned_files == 1} under #{root}"
      out << ""

      if findings.empty?
        out << "No at-risk patterns found. Nothing to migrate."
        out << ""
        return out.join("\n")
      end

      SEVERITIES.each do |severity, heading|
        group = findings_for(severity)
        next if group.empty?

        out << "#{heading} (#{group.size})"
        out << "-" * 72
        group.each do |finding|
          out << "  #{relative(finding.path)}:#{finding.line}  [#{finding.rule}] (#{finding.version})"
          out << "    #{finding.source}"
          finding.suggestion.each_line { |line| out << "    -> #{line.chomp}" }
          out << ""
        end
      end

      out << "Summary: " + SEVERITIES.keys.map { |s| "#{findings_for(s).size} #{s}" }.join(", ")
      out << "Advisory only - nothing was changed. See docs/upgrading.md for the release notes behind each rule."
      out << ""
      out.join("\n")
    end

    private

    def relative(path)
      path.sub(/\A#{Regexp.escape(root)}\/?/, "")
    end

    def each_file(globs)
      globs.flat_map { |glob| Dir.glob(File.join(root, glob)) }
        .uniq
        .reject { |path| "/#{relative(path)}" =~ EXCLUDED }
        .select { |path| File.file?(path) }
        .sort
        .each do |path|
          @scanned_files += 1
          yield path
        end
    end

    def add(path, index, source, severity, rule, suggestion, version = "0.6.0")
      findings << Finding.new(path, index + 1, squash(source), severity, rule, suggestion, version)
    end

    # Multi-line selectors read better as one line in a report.
    def squash(text)
      text.to_s.gsub(/\s+/, " ").strip[0, 120]
    end

    # Walks a stylesheet tracking the open block stack, so every declaration
    # knows the selector chain it belongs to and whether it sits in an @layer.
    def scan_css(path)
      read(path).each_with_index { |line, index| scan_shared(path, index, line) }

      source = File.read(path).gsub(%r{/\*.*?\*/}m) { |comment| comment.gsub(/[^\n]/, " ") }
      stack = []
      buffer = +""
      index = 0

      source.each_char do |char|
        case char
        when "{"
          selector = buffer.strip
          buffer = +""
          at_rule = selector.start_with?("@")
          check_selector(path, index, selector, in_layer?(stack)) unless at_rule
          stack.push(selector)
        when "}"
          check_declaration(path, index, buffer.strip, stack)
          buffer = +""
          stack.pop
        when ";"
          check_declaration(path, index, buffer.strip, stack)
          buffer = +""
        else
          index += 1 if char == "\n"
          buffer << char
        end
      end
    end

    def in_layer?(stack)
      stack.any? { |selector| selector.start_with?("@layer") }
    end

    # The selector chain a declaration sits under, ignoring at-rules.
    def selector_chain(stack)
      stack.reject { |selector| selector.start_with?("@") }.join(" ")
    end

    def check_declaration(path, index, declaration, stack)
      return if declaration.empty?

      chain = selector_chain(stack)
      # Palette tokens live on :root / .dark, never on a component selector, so
      # they have to be captured before the component guard below discards them.
      capture_destructive_token(path, index, declaration, chain)

      return unless component_selector?(chain)

      if RADIUS_DECL.match?(declaration)
        add(path, index, declaration, :review, "hardcoded-radius",
          "0.6.0 reads --control-radius / --surface-radius / --mark-radius / --pill-radius.\n" \
          "Set the token once instead of restating a radius per component:\n" \
          "  :root { --control-radius: 0.375rem; }")
      end

      if SHADOW_DECL.match?(declaration)
        suggestion = if FOCUS_SELECTOR.match?(chain)
          "Focus rings come from --focus-ring-width / --focus-ring-offset /\n" \
          "--focus-ring-style / --focus-ring-color in 0.6.0. Set those instead of\n" \
          "restating a box-shadow or ring utility on the component."
        else
          "0.6.0 reads --elevation-control / --elevation-raised / --elevation-overlay.\n" \
          "Set the matching elevation token instead of a per-component shadow."
        end
        add(path, index, declaration, :review, "hardcoded-shadow", suggestion)
      end
    end

    def check_selector(path, index, selector, in_layer)
      return if selector.empty?

      if UNIVERSAL_SELECTOR.match?(selector) && !in_layer
        add(path, index, selector, :breaking, "unlayered-universal-rule",
          "An unlayered `*` rule outranks every layer at any specificity, and the engine's\n" \
          "own rules move into @layer components in 0.6.0. The shadcn/Tailwind-v3 preflight\n" \
          "shim `* { border-color: var(--color-border) }` therefore flattens the tinted\n" \
          "borders on every alert and toast variant back to --border.\n" \
          "Wrap it so the engine can still paint its own borders:\n" \
          "  @layer base { #{squash(selector)} { ... } }")
      end

      if COMPONENT_SELECTOR.match?(selector)
        if /(^|[\s>+~(])\.dark\b/.match?(selector)
          add(path, index, selector, :review, "dark-twin-rule",
            "0.6.0 resolves dark-mode component values through tokens, so the .dark twin\n" \
            "is usually redundant. Override the token inside your own .dark block instead:\n" \
            "  .dark { --control-fill: ...; }")
        end

        unless in_layer
          add(path, index, selector, :cleanup, "unlayered-component-rule",
            "The engine's own rules move into @layer components in 0.6.0, so many app-level\n" \
            "overrides become unnecessary. Delete it, or wrap what you still need:\n" \
            "  @layer components { #{squash(selector)} { ... } }")
        end
      end
    end

    # Checks that read the same in CSS, ERB and JS.
    def scan_shared(path, index, line)
      if PRESENCE_ACTIVE.match?(line)
        add(path, index, line, :breaking, "data-active-presence",
          "Match the value: [data-active=\"true\"]. 0.6.0 omits data-active entirely when\n" \
          "a sidebar item is inactive, so a presence selector no longer matches.")
      end

      if TAILWIND_ACTIVE_VARIANT.match?(line)
        add(path, index, line, :breaking, "data-active-presence",
          "Use the value form of the variant: data-[active=true]:... - the bare\n" \
          "data-[active] variant relies on an attribute 0.6.0 no longer emits when false.")
      end

      if SVG_DATA_URI.match?(line) && !MARK_TOKEN_ASSIGNMENT.match?(line)
        add(path, index, line, :breaking, "restated-svg-uri",
          "0.6.0 exposes these marks as overridable custom properties:\n" \
          "--checkbox-mark-image, --checkbox-indeterminate-image, --radio-mark-image,\n" \
          "--switch-thumb-image, --select-chevron-image. Assign your SVG to the token\n" \
          "instead of restating the engine's rule.")
      end
    end

    def scan_markup(path)
      read(path).each_with_index do |line, index|
        scan_shared(path, index, line)

        # Cross-file signals for check_invalid_without_aria.
        @aria_invalid_seen ||= ARIA_INVALID.match?(line)
        if ERROR_PART.match?(line) || FIELD_WITH_ERRORS.match?(line)
          @error_sites << {path: path, index: index, source: squash(line)}
        end

        if ERROR_PART.match?(line) && HANDROLLED_ERROR_COLOR.match?(line)
          add(path, index, line, :cleanup, "destructive-error-workaround",
            "This restates the error color by hand on top of the engine's part.\n" \
            "0.7.1 gives that color its own token, so the part is legible under\n" \
            "either palette convention:\n" \
            "  :root { --destructive-text: var(--destructive); }\n" \
            "Then drop the utility and let [data-form-part=\"error\"] paint itself.",
            "0.7.1")
        end

        next unless line.include?("data-component=") || line =~ /component:\s*[:"']/

        if /\b(?:rounded|shadow)(?:-[a-z0-9\[\].\/-]+)?\b/.match?(line)
          add(path, index, line, :cleanup, "inline-shape-utility",
            "Radius and elevation are tokens in 0.6.0. Drop the inline utility and set\n" \
            "--control-radius / --surface-radius / --elevation-* instead.")
        end
      end
    end

    # ----- 0.7.1 checks -------------------------------------------------

    # Records --destructive / --destructive-foreground per theme scope. The
    # engine ships two opposite conventions for this pair (a pale tint with a
    # dark readable foreground, and a saturated fill with a near-white one),
    # and only the app's own theme says which one its components are sitting in.
    def capture_destructive_token(path, index, declaration, chain)
      match = DESTRUCTIVE_DECL.match(declaration.strip)
      return unless match
      return unless THEME_SCOPE.match?(chain.to_s.strip)

      name = match[1]
      scope = /\.dark\b/.match?(chain.to_s) ? "dark" : "light"

      @destructive_tokens[scope] ||= {}
      @destructive_tokens[scope][name] ||= {value: match[2].strip, path: path, index: index}
    end

    # First component of an oklch() color, normalised to 0..1. Returns nil for
    # any other color space -- an unparseable value must not be guessed at.
    def oklch_lightness(value)
      match = OKLCH_LIGHTNESS.match(value.to_s)
      return nil unless match

      lightness = match[1].to_f
      (match[2] == "%") ? lightness / 100.0 : lightness
    end

    def check_destructive_palette
      @destructive_tokens.each do |scope, tokens|
        foreground = tokens["destructive-foreground"]
        base = tokens["destructive"]
        surface = tokens["card"] || tokens["background"]
        next unless foreground && base && surface

        foreground_lightness = oklch_lightness(foreground[:value])
        surface_lightness = oklch_lightness(surface[:value])
        next unless foreground_lightness && surface_lightness

        # [data-form-part="error"] paints --destructive-foreground on the card.
        # Under the installer's palette that is the dark readable red and this
        # gap is wide; under a shadcn-style palette it is the near-white
        # on-fill color and the text vanishes.
        next unless (foreground_lightness - surface_lightness).abs < CONTRAST_FLOOR

        add(foreground[:path], foreground[:index], "--destructive-foreground: #{foreground[:value]}",
          :breaking, "destructive-error-invisible",
          "In this #{scope} palette --destructive-foreground is the color that sits ON\n" \
          "a destructive fill, not on the page. [data-form-part=\"error\"] paints it\n" \
          "as body text on --#{tokens["card"] ? "card" : "background"}, where it is all but invisible\n" \
          "(oklch lightness #{foreground_lightness.round(3)} against #{surface_lightness.round(3)}).\n" \
          "0.7.1 routes that color through its own token. Add to your #{scope} block:\n" \
          "  --destructive-text: var(--destructive);\n" \
          "  --destructive-border: var(--destructive);",
          "0.7.1")
      end
    end

    # An app that never sets aria-invalid is getting its error border from the
    # CSS :invalid fallback. 0.7.1 narrows that to :user-invalid so a pristine
    # required field stops painting red, which also means an app relying on the
    # old behaviour loses the border it was depending on.
    def check_invalid_without_aria
      return if @aria_invalid_seen || @error_sites.empty?

      site = @error_sites.first
      add(site[:path], site[:index], site[:source], :breaking, "invalid-styling-without-aria",
        "This app renders form errors (#{@error_sites.size} site#{"s" unless @error_sites.size == 1})\n" \
        "but never sets aria-invalid, so the destructive border is coming from the\n" \
        "CSS :invalid fallback. 0.7.1 replaces that with :user-invalid, which only\n" \
        "matches after the reader has interacted with the field -- a server-rendered\n" \
        "error on an untouched form will no longer paint a border.\n" \
        "Drive the state explicitly on the input:\n" \
        "  aria: { invalid: model.errors[:field].any? }",
        "0.7.1")
    end

    # Scans a view for form fields across their whole tag, not line by line.
    def scan_form_fields(path)
      source = File.read(path)

      source.to_enum(:scan, FIELD_OPENER).each do
        match = Regexp.last_match
        window = field_window(source, match.begin(0))
        next unless FIELD_COMPONENT.match?(window)
        next unless FIELD_REQUIRED.match?(window)
        next if FIELD_PLACEHOLDER.match?(window)

        index = source[0...match.begin(0)].count("\n")
        add(path, index, window, :review, "required-without-placeholder",
          "Before 0.7.1 a required field with no placeholder matched\n" \
          ":invalid:not(:placeholder-shown) from first paint, so it rendered the\n" \
          "error state before the reader touched it -- with no aria-invalid, so\n" \
          "screen readers were told nothing. 0.7.1 keys the error state on\n" \
          ":user-invalid instead, and the premature red goes away on upgrade.\n" \
          "Nothing to change here unless you were relying on it; drive real errors\n" \
          "with aria-invalid.",
          "0.7.1")
      end
    rescue ArgumentError, Errno::ENOENT
      nil
    end

    # From the opener to the end of the tag or ERB expression that contains it,
    # bounded so a malformed template cannot swallow the rest of the file.
    def field_window(source, start)
      slice = source[start, 500].to_s
      terminator = slice.index("%>") || slice.index(">") || slice.length
      slice[0, terminator + 2]
    end

    def scan_javascript(path)
      source = File.read(path)
      return unless source.include?("getBoundingClientRect")
      return unless DROPDOWN_FLIP_HINT.match?(source)

      index = source[0...source.index("getBoundingClientRect")].count("\n")
      add(path, index, "getBoundingClientRect + data-side", :cleanup, "app-level-dropdown-flip",
        "This looks like an app-level dropdown collision/flip controller. 0.7.1\n" \
        "measures on open and sets data-side itself, for both the dropdown menu\n" \
        "and the menu button, so the workaround can go.\n" \
        "Delete it and let the engine place the menu.",
        "0.7.1")
    rescue ArgumentError, Errno::ENOENT
      nil
    end

    def read(path)
      File.readlines(path)
    rescue ArgumentError, Errno::ENOENT
      []
    end

    def component_selector?(selector)
      COMPONENT_SELECTOR.match?(selector) || false
    end
  end
end
