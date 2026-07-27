# frozen_string_literal: true

module MaquinaComponents
  # Migration scanner behind `rake maquina:doctor`.
  #
  # Run inside a consuming app, it looks for the app's own CSS/view/JS patterns
  # that 0.6.0 makes redundant or outright breaks, and prints file:line plus a
  # suggested replacement for each. Advisory only: it never edits anything and
  # never fails a build.
  #
  # Plain Ruby on purpose - no Rails, no extra gems - so it can also be run
  # against a directory from the engine's own repo.
  class Doctor
    Finding = Struct.new(:path, :line, :source, :severity, :rule, :suggestion)

    SEVERITIES = {
      breaking: "BREAKING     - stops working in 0.6.0",
      review: "REVIEW       - still works, but 0.6.0 gives you a token for it",
      cleanup: "CLEANUP      - probably unnecessary in 0.6.0"
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

    attr_reader :root, :findings, :scanned_files

    def initialize(root)
      @root = File.expand_path(root.to_s)
      @findings = []
      @scanned_files = 0
    end

    def run
      each_file(CSS_GLOBS) { |path| scan_css(path) }
      each_file(VIEW_GLOBS) { |path| scan_markup(path) }
      each_file(JS_GLOBS) { |path| scan_markup(path) }
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
        out << "No at-risk patterns found. Nothing to migrate for 0.6.0."
        out << ""
        return out.join("\n")
      end

      SEVERITIES.each do |severity, heading|
        group = findings_for(severity)
        next if group.empty?

        out << "#{heading} (#{group.size})"
        out << "-" * 72
        group.each do |finding|
          out << "  #{relative(finding.path)}:#{finding.line}  [#{finding.rule}]"
          out << "    #{finding.source}"
          finding.suggestion.each_line { |line| out << "    -> #{line.chomp}" }
          out << ""
        end
      end

      out << "Summary: " + SEVERITIES.keys.map { |s| "#{findings_for(s).size} #{s}" }.join(", ")
      out << "Advisory only - nothing was changed. See the 0.6.0 upgrade notes for the full token list."
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
        .reject { |path| path =~ EXCLUDED }
        .select { |path| File.file?(path) }
        .sort
        .each do |path|
          @scanned_files += 1
          yield path
        end
    end

    def add(path, index, source, severity, rule, suggestion)
      findings << Finding.new(path, index + 1, squash(source), severity, rule, suggestion)
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

        next unless line.include?("data-component=") || line =~ /component:\s*[:"']/

        if /\b(?:rounded|shadow)(?:-[a-z0-9\[\].\/-]+)?\b/.match?(line)
          add(path, index, line, :cleanup, "inline-shape-utility",
            "Radius and elevation are tokens in 0.6.0. Drop the inline utility and set\n" \
            "--control-radius / --surface-radius / --elevation-* instead.")
        end
      end
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
