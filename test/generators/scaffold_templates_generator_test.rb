# frozen_string_literal: true

require_relative "../test_helper"
require "rails/generators/test_case"
require "generators/maquina_components/scaffold_templates/scaffold_templates_generator"

class ScaffoldTemplatesGeneratorTest < Rails::Generators::TestCase
  tests MaquinaComponents::Generators::ScaffoldTemplatesGenerator
  destination File.expand_path("../tmp", __dir__)

  setup do
    prepare_destination
  end

  teardown do
    FileUtils.rm_rf(destination_root)
  end

  test "copies all scaffold template files" do
    run_generator

    %w[_form edit index new partial show].each do |name|
      assert_file "lib/templates/erb/scaffold/#{name}.html.erb.tt"
    end
  end

  test "index template uses card and table components" do
    run_generator

    assert_file "lib/templates/erb/scaffold/index.html.erb.tt" do |content|
      assert_match %r{render "components/card"}, content
      assert_match %r{render "components/table"}, content
      assert_match %r{render "components/empty"}, content
      assert_match %r{data: \{ component: "button", variant: "primary"}, content
    end
  end

  test "form template uses component data attributes" do
    run_generator

    assert_file "lib/templates/erb/scaffold/_form.html.erb.tt" do |content|
      assert_match %r{data: \{ component: "input" \}}, content
      assert_match %r{data: \{ component: "textarea" \}}, content
      assert_match %r{data: \{ component: "checkbox" \}}, content
      assert_match %r{render "components/alert"}, content
    end
  end

  test "show template uses breadcrumbs and card components" do
    run_generator

    assert_file "lib/templates/erb/scaffold/show.html.erb.tt" do |content|
      assert_match %r{render "components/breadcrumbs"}, content
      assert_match %r{render "components/card"}, content
      assert_match %r{render "components/card/footer"}, content
      assert_match %r{variant: "destructive"}, content
    end
  end

  test "new and edit templates use breadcrumbs" do
    run_generator

    assert_file "lib/templates/erb/scaffold/new.html.erb.tt" do |content|
      assert_match %r{render "components/breadcrumbs"}, content
      assert_match %r{content_for :breadcrumbs}, content
    end

    assert_file "lib/templates/erb/scaffold/edit.html.erb.tt" do |content|
      assert_match %r{render "components/breadcrumbs"}, content
      assert_match %r{content_for :breadcrumbs}, content
    end
  end

  test "templates use English text matching Rails conventions" do
    run_generator

    assert_file "lib/templates/erb/scaffold/show.html.erb.tt" do |content|
      assert_match %r{Destroy this}, content
      assert_match %r{Back to}, content
    end

    assert_file "lib/templates/erb/scaffold/index.html.erb.tt" do |content|
      assert_match %r{Show this}, content
    end
  end
end
