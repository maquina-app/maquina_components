require "test_helper"
require "tmpdir"
require "maquina_components/doctor"

# Covers the scanner behind `rake maquina:doctor`, the 0.6.0 migration report.
class DoctorTest < ActiveSupport::TestCase
  def setup
    @root = Dir.mktmpdir("maquina-doctor")
  end

  def teardown
    FileUtils.rm_rf(@root)
  end

  def write(relative_path, contents)
    path = File.join(@root, relative_path)
    FileUtils.mkdir_p(File.dirname(path))
    File.write(path, contents)
    path
  end

  def doctor
    MaquinaComponents::Doctor.new(@root).run
  end

  def rules(findings)
    findings.map(&:rule).uniq.sort
  end

  test "clean app reports nothing" do
    write "app/assets/tailwind/application.css", <<~CSS
      @import "tailwindcss";

      :root { --control-radius: 0.5rem; }
    CSS

    result = doctor

    assert_empty result.findings
    assert_includes result.report, "No at-risk patterns found"
  end

  test "flags a data-active presence selector as breaking" do
    write "app/assets/tailwind/application.css", <<~CSS
      [data-sidebar-part="menu-link"][data-active] {
        color: red;
      }
    CSS

    finding = doctor.findings_for(:breaking).first

    assert_equal "data-active-presence", finding.rule
    assert_equal 1, finding.line
    assert_match(/data-active="true"/, finding.suggestion)
  end

  test "flags a bare data-[active] Tailwind variant in a view" do
    write "app/views/shared/_nav.html.erb", <<~ERB
      <a class="data-[active]:font-bold" data-active="true">Home</a>
    ERB

    assert_equal ["data-active-presence"], rules(doctor.findings_for(:breaking))
  end

  test "flags restated engine SVG data URIs" do
    write "app/assets/stylesheets/forms.css", <<~CSS
      [data-component="checkbox"]:checked {
        background-image: url("data:image/svg+xml,%3csvg%3e%3c/svg%3e");
      }
    CSS

    breaking = doctor.findings_for(:breaking)

    assert_includes rules(breaking), "restated-svg-uri"
    assert_match(/--checkbox-mark-image/, breaking.first.suggestion)
  end

  # Assigning a data URI to a mark property is the 0.6.0 pattern the previous
  # test recommends. Reporting it would tell people their correct code is broken.
  test "does not flag a data URI assigned to a mark property" do
    write "app/assets/tailwind/application.css", <<~CSS
      :root {
        --checkbox-mark-image: url("data:image/svg+xml,%3csvg%3e%3c/svg%3e");
        --select-chevron-image: url("data:image/svg+xml,%3csvg%3e%3c/svg%3e");
      }
    CSS

    assert_empty doctor.findings.select { |finding| finding.rule == "restated-svg-uri" }
  end

  test "flags hardcoded radius and focus-ring shadows on component selectors" do
    write "app/assets/stylesheets/overrides.css", <<~CSS
      [data-component="button"] {
        @apply rounded-lg;
      }

      [data-component="button"]:focus-visible {
        box-shadow: 0 0 0 3px var(--ring);
      }
    CSS

    review = doctor.findings_for(:review)

    assert_equal ["hardcoded-radius", "hardcoded-shadow"], rules(review)
    assert_match(/--control-radius/, review.find { |f| f.rule == "hardcoded-radius" }.suggestion)
    assert_match(/--focus-ring-width/, review.find { |f| f.rule == "hardcoded-shadow" }.suggestion)
  end

  test "flags .dark twin rules for component selectors" do
    write "app/assets/stylesheets/dark.css", <<~CSS
      .dark [data-component="card"] {
        background-color: #111;
      }
    CSS

    assert_includes rules(doctor.findings_for(:review)), "dark-twin-rule"
  end

  test "flags unlayered component rules and leaves layered ones alone" do
    write "app/assets/stylesheets/unlayered.css", <<~CSS
      [data-component="badge"] { color: red; }
    CSS
    write "app/assets/stylesheets/layered.css", <<~CSS
      @layer components {
        [data-component="badge"] { color: red; }
      }
    CSS

    cleanup = doctor.findings_for(:cleanup)

    assert_equal ["unlayered-component-rule"], rules(cleanup)
    assert_equal 1, cleanup.size
    assert_match(/unlayered\.css/, cleanup.first.path)
  end

  test "ignores compiled builds, vendor and node_modules" do
    write "app/assets/builds/tailwind/application.css", "[data-component=\"badge\"][data-active] { color: red; }"
    write "vendor/javascript/thing.js", "document.querySelector('[data-active]')"

    assert_empty doctor.findings
  end

  # The exclusions name directories inside the app, so they have to be matched
  # against the path relative to the root. Matched against the absolute path,
  # an app that merely lives under one of those names — /tmp on CI, or any
  # checkout under a vendor/ directory — scans zero files and reports a clean
  # bill of health.
  test "scans an app whose root sits under an excluded directory name" do
    nested = File.join(@root, "tmp", "checkout")
    FileUtils.mkdir_p(File.join(nested, "app/assets/tailwind"))
    File.write(File.join(nested, "app/assets/tailwind/application.css"),
      "[data-sidebar-part=\"menu-link\"][data-active] { color: red; }")

    result = MaquinaComponents::Doctor.new(nested).run

    assert_equal 1, result.scanned_files
    assert_equal ["data-active-presence"], rules(result.findings_for(:breaking))
  end

  # The shim every 0.5.x install shipped with. Unlayered, it outranks the
  # engine's @layer components rules and flattens the alert/toast variant
  # borders back to --border.
  test "flags an unlayered universal rule but not a layered one" do
    write "app/assets/tailwind/application.css", <<~CSS
      * {
        border-color: var(--color-border);
      }

      @layer base {
        *, ::before, ::after {
          border-color: var(--color-border);
        }
      }
    CSS

    findings = doctor.findings.select { |finding| finding.rule == "unlayered-universal-rule" }

    assert_equal 1, findings.size
    assert_equal 1, findings.first.line
    assert_equal :breaking, findings.first.severity
    assert_match(/@layer base/, findings.first.suggestion)
  end

  test "report is grouped by severity and lists file:line" do
    write "app/assets/tailwind/application.css", <<~CSS
      [data-component="button"][data-active] {
        @apply rounded-lg;
      }
    CSS

    report = doctor.report

    assert_match(/BREAKING/, report)
    assert_match(/REVIEW/, report)
    assert_match(/CLEANUP/, report)
    assert_match(%r{app/assets/tailwind/application\.css:1}, report)
    assert_match(/Summary: 1 breaking, 1 review, 1 cleanup/, report)
  end

  # ----- 0.7.1 checks -------------------------------------------------

  # Palettes in the two conventions the engine has shipped. The installer's
  # theme.css.tt uses --destructive as a pale tint with a dark readable
  # foreground; docs/getting-started.md used to ship the inverse.
  TINT_PALETTE = <<~CSS
    :root {
      --card: oklch(1 0 0);
      --destructive: oklch(0.92 0.05 8);
      --destructive-foreground: oklch(0.4 0.12 8);
    }
    .dark {
      --card: oklch(0.205 0 0);
      --destructive: oklch(0.34 0.07 8);
      --destructive-foreground: oklch(0.88 0.06 8);
    }
  CSS

  SHADCN_PALETTE = <<~CSS
    :root {
      --card: oklch(1 0 0);
      --destructive: oklch(0.577 0.245 27.325);
      --destructive-foreground: oklch(0.985 0 0);
    }
  CSS

  test "flags a palette whose error text disappears into the card" do
    write "app/assets/tailwind/application.css", SHADCN_PALETTE

    finding = doctor.findings.find { |f| f.rule == "destructive-error-invisible" }

    assert_equal :breaking, finding.severity
    assert_equal "0.7.1", finding.version
    assert_equal 4, finding.line
    assert_match(/--destructive-text: var\(--destructive\)/, finding.suggestion)
  end

  # The check that matters most: the installer's own palette is correct as
  # shipped, in BOTH themes. Its dark block has the same numeric shape as an
  # inverted light block -- pale foreground, dark base -- so a rule keyed on
  # lightness alone would fire on every app that ran our generator.
  test "does not flag the installer's tint palette in either theme" do
    write "app/assets/tailwind/application.css", TINT_PALETTE

    assert_empty doctor.findings.select { |f| f.rule == "destructive-error-invisible" }
  end

  # Without a surface token there is nothing to measure against, and guessing
  # would make a BREAKING finding out of an assumption.
  test "abstains when the theme declares no card or background" do
    write "app/assets/tailwind/application.css", <<~CSS
      :root {
        --destructive: oklch(0.577 0.245 27.325);
        --destructive-foreground: oklch(0.985 0 0);
      }
    CSS

    assert_empty doctor.findings.select { |f| f.rule == "destructive-error-invisible" }
  end

  # Rails form helpers span several lines, so this cannot be a per-line match.
  test "flags a required field with no placeholder across a multi-line helper" do
    write "app/views/users/_form.html.erb", <<~ERB
      <%= form_with model: @user do |f| %>
        <%= f.text_field :workspace_id,
            data: { component: "input" },
            required: true %>
      <% end %>
    ERB

    finding = doctor.findings.find { |f| f.rule == "required-without-placeholder" }

    assert_equal :review, finding.severity
    assert_equal 2, finding.line
    assert_match(/:user-invalid/, finding.suggestion)
  end

  test "does not flag a required field that has a placeholder" do
    write "app/views/users/_form.html.erb", <<~ERB
      <%= f.text_field :name,
          data: { component: "input" },
          placeholder: "Full name",
          required: true %>
    ERB

    assert_empty doctor.findings.select { |f| f.rule == "required-without-placeholder" }
  end

  test "flags an app that renders errors but never sets aria-invalid" do
    write "app/views/users/_form.html.erb", <<~ERB
      <p data-form-part="error">Email is required</p>
    ERB

    finding = doctor.findings.find { |f| f.rule == "invalid-styling-without-aria" }

    assert_equal :breaking, finding.severity
    assert_match(/aria: \{ invalid:/, finding.suggestion)
  end

  test "does not flag an app that already sets aria-invalid" do
    write "app/views/users/_form.html.erb", <<~ERB
      <%= f.email_field :email, aria: { invalid: @user.errors[:email].any? } %>
      <p data-form-part="error">Email is required</p>
    ERB

    assert_empty doctor.findings.select { |f| f.rule == "invalid-styling-without-aria" }
  end

  test "flags a hand-rolled error color on the engine's error part" do
    write "app/views/users/_form.html.erb", <<~ERB
      <p data-form-part="error" class="text-xs text-destructive">Bad</p>
    ERB

    finding = doctor.findings.find { |f| f.rule == "destructive-error-workaround" }

    assert_equal :cleanup, finding.severity
    assert_match(/--destructive-text/, finding.suggestion)
  end

  test "flags an app-level dropdown flip controller" do
    write "app/javascript/controllers/dropdown_flip_controller.js", <<~JS
      export default class extends Controller {
        reposition() {
          const rect = this.element.getBoundingClientRect()
          this.contentTarget.dataset.side = rect.bottom > window.innerHeight ? "top" : "bottom"
        }
      }
    JS

    finding = doctor.findings.find { |f| f.rule == "app-level-dropdown-flip" }

    assert_equal :cleanup, finding.severity
    assert_equal "0.7.1", finding.version
  end

  # getBoundingClientRect on its own is not a dropdown flip.
  test "does not flag unrelated geometry code" do
    write "app/javascript/controllers/ruler_controller.js", <<~JS
      export default class extends Controller {
        measure() { return this.element.getBoundingClientRect().width }
      }
    JS

    assert_empty doctor.findings.select { |f| f.rule == "app-level-dropdown-flip" }
  end

  test "report names the release each finding came from" do
    write "app/views/users/_form.html.erb", <<~ERB
      <p data-form-part="error" class="text-destructive">Bad</p>
    ERB

    assert_match(/\[destructive-error-workaround\] \(0\.7\.1\)/, doctor.report)
  end
end
