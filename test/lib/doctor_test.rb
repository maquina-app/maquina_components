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
end
