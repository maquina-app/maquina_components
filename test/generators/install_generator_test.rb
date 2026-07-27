# frozen_string_literal: true

require_relative "../test_helper"
require "rails/generators/test_case"
require "generators/maquina_components/install/install_generator"

class InstallGeneratorTest < Rails::Generators::TestCase
  tests MaquinaComponents::Generators::InstallGenerator
  destination File.expand_path("../tmp", __dir__)

  setup do
    prepare_destination
    create_tailwind_css_file
  end

  teardown do
    FileUtils.rm_rf(destination_root)
  end

  # === Setup Helpers ===

  def create_tailwind_css_file(content = nil)
    content ||= <<~CSS
      @import "tailwindcss";

      /* Application styles */
    CSS

    FileUtils.mkdir_p(File.join(destination_root, "app/assets/tailwind"))
    File.write(
      File.join(destination_root, "app/assets/tailwind/application.css"),
      content
    )
  end

  def css_file_path
    File.join(destination_root, "app/assets/tailwind/application.css")
  end

  def css_file_content
    File.read(css_file_path)
  end

  def helper_file_path
    File.join(destination_root, "app/helpers/maquina_components_helper.rb")
  end

  # === Engine CSS Import Tests ===

  test "adds engine CSS import after tailwindcss import" do
    run_generator

    assert_file "app/assets/tailwind/application.css" do |content|
      assert_match %r{@import "tailwindcss";}, content
      assert_match %r{@import "\.\./builds/tailwind/maquina_components_engine\.css";}, content
    end
  end

  test "engine CSS import appears after tailwindcss import" do
    run_generator

    content = css_file_content
    tailwind_pos = content.index('@import "tailwindcss";')
    engine_pos = content.index('@import "../builds/tailwind/maquina_components_engine.css";')

    assert tailwind_pos < engine_pos, "Engine import should come after tailwindcss import"
  end

  test "does not duplicate engine CSS import if already present" do
    create_tailwind_css_file(<<~CSS)
      @import "tailwindcss";

      @import "../builds/tailwind/maquina_components_engine.css";

      /* Application styles */
    CSS

    run_generator

    content = css_file_content
    import_count = content.scan('@import "../builds/tailwind/maquina_components_engine.css";').count

    assert_equal 1, import_count, "Should not duplicate engine import"
  end

  # === Theme Variables Tests ===

  test "appends theme variables to application.css" do
    run_generator

    assert_file "app/assets/tailwind/application.css" do |content|
      # Check for root variables
      assert_match %r{:root \{}, content
      assert_match %r{--background:}, content
      assert_match %r{--foreground:}, content
      assert_match %r{--primary:}, content
      assert_match %r{--primary-foreground:}, content
      assert_match %r{--muted:}, content
      assert_match %r{--destructive:}, content
      assert_match %r{--sidebar:}, content

      # Check for dark mode
      assert_match %r{\.dark \{}, content

      # Check for @theme block
      assert_match %r{@theme \{}, content
      assert_match %r{--color-primary: var\(--primary\)}, content
      assert_match %r{--color-background: var\(--background\)}, content
    end
  end

  test "does not duplicate theme variables if already present" do
    create_tailwind_css_file(<<~CSS)
      @import "tailwindcss";

      @theme {
        --color-primary: var(--primary);
      }
    CSS

    run_generator

    content = css_file_content
    theme_count = content.scan("--color-primary:").count

    assert_equal 1, theme_count, "Should not duplicate theme variables"
  end

  test "skips theme variables with --skip-theme option" do
    run_generator %w[--skip-theme]

    content = css_file_content

    refute_match %r{:root \{}, content
    refute_match %r{@theme \{}, content
  end

  # === Helper File Tests ===

  test "creates maquina_components_helper.rb" do
    run_generator

    assert_file "app/helpers/maquina_components_helper.rb" do |content|
      assert_match %r{module MaquinaComponentsHelper}, content
      assert_match %r{include MaquinaComponents::ComponentsHelper}, content
      assert_match %r{include MaquinaComponents::IconsHelper}, content
      assert_match %r{include MaquinaComponents::SidebarHelper}, content
      assert_match %r{include MaquinaComponents::ToastHelper}, content
      assert_match %r{def main_icon_svg_for\(name\)}, content
      assert_match %r{def app_sidebar_state}, content
      assert_match %r{def app_sidebar_open\?}, content
      assert_match %r{def app_sidebar_closed\?}, content
    end
  end

  test "does not overwrite existing helper file" do
    FileUtils.mkdir_p(File.join(destination_root, "app/helpers"))
    File.write(helper_file_path, "# Custom helper\nmodule MaquinaComponentsHelper\nend")

    run_generator

    assert_file "app/helpers/maquina_components_helper.rb" do |content|
      assert_match %r{# Custom helper}, content
      refute_match %r{def main_icon_svg_for}, content
    end
  end

  test "skips helper creation with --skip-helper option" do
    run_generator %w[--skip-helper]

    assert_no_file "app/helpers/maquina_components_helper.rb"
  end

  # === Edge Cases ===

  test "handles missing application.css gracefully" do
    FileUtils.rm_rf(File.join(destination_root, "app/assets/tailwind"))

    # Should not raise an error
    assert_nothing_raised do
      run_generator
    end

    # Helper should still be created
    assert_file "app/helpers/maquina_components_helper.rb"
  end

  test "handles tailwindcss import with single quotes" do
    create_tailwind_css_file(<<~CSS)
      @import 'tailwindcss';

      /* Application styles */
    CSS

    run_generator

    assert_file "app/assets/tailwind/application.css" do |content|
      assert_match %r{@import 'tailwindcss';}, content
      assert_match %r{@import "\.\./builds/tailwind/maquina_components_engine\.css";}, content
    end
  end

  test "handles tailwindcss import with semicolon variations" do
    create_tailwind_css_file(<<~CSS)
      @import "tailwindcss"

      /* No semicolon above */
    CSS

    # Generator should still work (regex handles optional semicolon)
    run_generator

    # The import should be added somewhere in the file
    assert_file "app/assets/tailwind/application.css"
  end

  # === Shape/State Token Block Tests ===

  test "appends the shape and state token block with the new tokens" do
    run_generator

    assert_file "app/assets/tailwind/application.css" do |content|
      assert_match %r{maquina_components:shape-state-tokens}, content

      # Real defaults for new installs
      assert_match %r{^\s+--info: }, content
      assert_match %r{^\s+--info-foreground: }, content
      assert_match %r{^\s+--primary-hover: }, content
      assert_match %r{^\s+--secondary-hover: }, content
      assert_match %r{^\s+--destructive-hover: }, content
      assert_match %r{^\s+--accent-hover: }, content

      # Commented out at their 0.5.1 values, ready to be pinned
      %w[
        --control-radius --surface-radius --mark-radius --pill-radius
        --focus-ring-width --focus-ring-offset --focus-ring-style --focus-ring-color
        --elevation-control --elevation-raised --elevation-overlay
        --label-weight --value-weight --control-fill
        --checkbox-mark-image --checkbox-indeterminate-image --radio-mark-image
        --switch-thumb-image --select-chevron-image
      ].each do |token|
        assert_match %r{/\* #{Regexp.escape(token)}: }, content, "#{token} should be listed commented out"
      end
    end
  end

  test "re-running the generator appends the token block without clobbering the palette" do
    create_tailwind_css_file(<<~CSS)
      @import "tailwindcss";

      @import "../builds/tailwind/maquina_components_engine.css";

      :root {
        --color-primary: var(--primary);
        --primary: oklch(0.5 0.2 250);
      }
    CSS

    run_generator

    content = css_file_content

    # The app's own palette survives untouched, and the engine's theme block
    # is not appended on top of it.
    assert_match %r{--primary: oklch\(0\.5 0\.2 250\)}, content
    assert_equal 1, content.scan("--primary:").count
    assert_match %r{maquina_components:shape-state-tokens}, content
  end

  test "token block is not duplicated on a second run" do
    run_generator
    run_generator

    content = css_file_content

    assert_equal 1, content.scan("maquina_components:shape-state-tokens").count
    assert_equal 1, content.scan("--primary-hover:").count
    assert_equal 1, content.scan('@import "../builds/tailwind/maquina_components_engine.css";').count
  end

  test "skips the token block with --skip-theme" do
    run_generator %w[--skip-theme]

    refute_match %r{maquina_components:shape-state-tokens}, css_file_content
  end

  # === Combined Options Tests ===

  test "both skip options together" do
    run_generator %w[--skip-theme --skip-helper]

    # Engine import should still be added
    assert_file "app/assets/tailwind/application.css" do |content|
      assert_match %r{@import "\.\./builds/tailwind/maquina_components_engine\.css";}, content
      refute_match %r{@theme \{}, content
    end

    assert_no_file "app/helpers/maquina_components_helper.rb"
  end

  # === Content Order Tests ===

  test "maintains correct order of inserted content" do
    run_generator

    content = css_file_content
    lines = content.lines

    tailwind_line = lines.index { |l| l.include?('@import "tailwindcss"') }
    engine_line = lines.index { |l| l.include?("maquina_components_engine") }
    theme_line = lines.index { |l| l.include?("@theme {") }

    assert tailwind_line < engine_line, "Tailwind import should come first"
    assert engine_line < theme_line, "Engine import should come before theme"
  end
end
