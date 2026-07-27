# Minimal CSS reader shared by the stylesheet guard tests.
#
# These tests assert *source-level* contracts (layering, cascade order, token
# usage), so they need selectors, byte offsets and nesting — not computed
# styles. A full CSS parser would be a dependency; this is a brace/quote/comment
# scanner that keeps offsets stable so "rule A must be declared before rule B"
# is expressible.
module CssSource
  ENGINE_ROOT = File.expand_path("../../app", __dir__)
  STYLESHEET_DIR = File.join(ENGINE_ROOT, "assets/stylesheets")
  TOKENS_FILE = File.join(ENGINE_ROOT, "assets/tailwind/maquina_components_engine/tokens.css")
  ENGINE_ENTRY = File.join(ENGINE_ROOT, "assets/tailwind/maquina_components_engine/engine.css")
  VIEWS_DIR = File.join(ENGINE_ROOT, "views/components")

  # A single block: `selector { body }`. `offset` is the byte offset of the
  # first character of the prelude, which is what cascade-order assertions
  # compare. `at_rules` is the enclosing at-rule preludes, outermost first.
  Rule = Struct.new(:file, :selector, :body, :offset, :line, :at_rules, keyword_init: true) do
    def at_rule?
      selector.start_with?("@")
    end

    def layered?
      at_rules.any? { |at| at.start_with?("@layer components") }
    end

    def where
      "#{file}:#{line}"
    end

    # The rule's own declarations, with nested blocks removed, so a check on
    # `[data-component="button"] { … }` does not pick up `& svg { … }`.
    def own_declarations
      text = body
      text = text.gsub(/\{[^{}]*\}/, "") while text.match?(/\{[^{}]*\}/)
      text
    end

    # [["border-radius", "var(--card-radius, …)"], …]
    def declarations
      own_declarations.scan(/([a-z-]+|--[a-z0-9-]+)\s*:\s*([^;]+);/)
    end
  end

  class << self
    # { "badge.css" => "…source…" }, sorted for stable failure messages.
    def stylesheets
      @stylesheets ||= Dir.glob(File.join(STYLESHEET_DIR, "*.css")).sort.to_h do |path|
        [File.basename(path), File.read(path)]
      end
    end

    def tokens_css
      @tokens_css ||= File.read(TOKENS_FILE)
    end

    # Every custom property declared in tokens.css's @theme block.
    # Public role tokens: the ones declared inside `@theme`. Excludes the
    # engine-internal `--maquina-*` defaults, which live on :root/.dark
    # precisely so they stay inheritable rather than landing in @layer theme.
    def declared_tokens
      @declared_tokens ||= theme_block.scan(/^\s*(--[a-z0-9-]+)\s*:/).flatten.to_set
    end

    def theme_block
      @theme_block ||= begin
        css = uncomment(tokens_css)
        start = css.index("@theme")
        raise "no @theme block in tokens.css" unless start

        depth = 0
        finish = nil
        css[start..].each_char.with_index do |char, offset|
          depth += 1 if char == "{"
          if char == "}"
            depth -= 1
            (finish = start + offset) && break if depth.zero?
          end
        end
        css[start..finish]
      end
    end

    # Blocks of one stylesheet, in source order.
    def rules(basename)
      all_rules.fetch(basename)
    end

    def all_rules
      @all_rules ||= stylesheets.to_h { |name, css| [name, parse(css, name)] }
    end

    # Comments replaced by spaces of the same length, so offsets and line
    # numbers still line up with the file on disk.
    def uncomment(css)
      css.gsub(%r{/\*.*?\*/}m) { |match| match.gsub(/[^\n]/, " ") }
    end

    # Splits on a separator that appears at bracket depth zero, so the commas
    # inside :where(a, b) and the spaces inside [data-x="a b"] are left alone.
    def split_outside_brackets(string, separator)
      parts = []
      buffer = +""
      depth = 0

      string.each_char do |char|
        case char
        when "(", "[" then depth += 1
        when ")", "]" then depth -= 1
        end

        if depth.zero? && separator.match?(char)
          parts << buffer
          buffer = +""
        else
          buffer << char
        end
      end

      (parts << buffer).map(&:strip).reject(&:empty?)
    end

    # One selector in, its compound selectors out, ancestors first:
    # `:where(.dark) [data-component="input"]` => [':where(.dark)', '[data-…]'].
    def compounds(selector)
      split_outside_brackets(selector, /[ >~+]/)
    end

    # The element a selector actually styles, as a stable key: the identifying
    # data attribute of the rightmost compound that carries one, plus any bare
    # element/pseudo-element tail. Pseudo-classes are stripped, so a base rule
    # and its :hover twin share a subject — which is what lets a test compare
    # their declaration order.
    def subject(selector)
      tail = []

      compounds(selector).reverse_each do |compound|
        if (match = compound.match(/\[data-component="([a-z0-9-]+)"\]/))
          return (["data-component=#{match[1]}"] + tail).join(" ")
        elsif (match = compound.match(/\[data-([a-z0-9-]+-part)="([a-z0-9-]+)"\]/))
          return (["data-#{match[1]}=#{match[2]}"] + tail).join(" ")
        else
          bare = compound.gsub(/:where\([^)]*\)|:not\([^)]*\)|:[a-z-]+(\([^)]*\))?/, "").strip
          tail.unshift(bare) unless bare.empty?
        end
      end

      (["(unidentified)"] + tail).join(" ")
    end

    def parse(css, file)
      source = uncomment(css)
      rules = []
      scan(source, 0, source.length, [], rules, file)
      rules.sort_by(&:offset)
    end

    private

    def scan(source, from, to, ancestors, rules, file)
      index = from
      prelude_start = nil

      while index < to
        char = source[index]

        case char
        when '"', "'"
          index = skip_string(source, index)
        when "{"
          prelude = source[prelude_start...index].to_s.strip.squeeze(" ")
          close = matching_brace(source, index, to)
          rules << Rule.new(file: file, selector: prelude, body: source[(index + 1)...close].to_s,
            offset: prelude_start || index, line: source[0...(prelude_start || index)].count("\n") + 1,
            at_rules: ancestors)
          # @keyframes bodies hold percentage selectors, not style rules.
          unless prelude.start_with?("@keyframes")
            scan(source, index + 1, close, ancestors + [prelude], rules, file)
          end
          index = close + 1
          prelude_start = nil
        when ";", "}"
          index += 1
          prelude_start = nil
        else
          prelude_start = index if prelude_start.nil? && !char.match?(/\s/)
          index += 1
        end
      end
    end

    def skip_string(source, index)
      quote = source[index]
      index += 1
      index += 1 while index < source.length && source[index] != quote
      index + 1
    end

    def matching_brace(source, open_index, limit)
      depth = 0
      index = open_index

      while index < limit
        case source[index]
        when '"', "'" then index = skip_string(source, index) - 1
        when "{" then depth += 1
        when "}"
          depth -= 1
          return index if depth.zero?
        end
        index += 1
      end

      limit
    end
  end
end
