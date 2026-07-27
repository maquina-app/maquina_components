require "test_helper"

# The published-documentation guard.
#
# maquina_site embeds these previews as live iframes: each `<!-- preview:NAME
# height:N -->` tag in docs/*.md is rewritten into
# https://demo.maquina.app/previews/<doc-basename>/<NAME>. The site derives the
# component segment from the *doc filename*, which is why docs/theming.md's tags
# resolve to previews/theming/.
#
# Nothing in either repo connects the two names, so renaming or deleting a
# preview 404s a live documentation page with no local symptom at all. This test
# is that connection.
class DocsPreviewsContractTest < ActiveSupport::TestCase
  DOCS_DIR = File.expand_path("../../docs", __dir__)
  PREVIEWS_DIR = File.expand_path("../dummy/app/views/previews", __dir__)
  PREVIEW_TAG = /<!--\s*preview:([a-z0-9_-]+)(?:\s+height:(\d+))?\s*-->/

  test "every preview tag in the docs resolves to a preview template" do
    missing = preview_tags.reject { |doc, name| File.exist?(preview_path(doc, name)) }

    assert_empty missing, <<~MESSAGE
      These documentation preview tags point at a preview template that does not
      exist. The docs site renders each one as a live iframe on
      https://demo.maquina.app, so every line here is a broken frame on a
      published page — and nothing else in this repo would have noticed.

      #{missing.map { |doc, name| "  docs/#{doc}.md -> previews/#{doc}/#{name}" }.join("\n")}
    MESSAGE

    assert_operator preview_tags.size, :>=, 60,
      "expected the docs to still carry their preview tags; found only #{preview_tags.size}"
  end

  test "every preview tag declares a height" do
    without_height = preview_tags_with_height.select { |_doc, _name, height| height.nil? }

    assert_empty without_height, <<~MESSAGE
      The site sizes each iframe from the tag's height:N. Without it the frame
      collapses and the preview is invisible on the published page.

      #{without_height.map { |doc, name, _| "  docs/#{doc}.md -> preview:#{name}" }.join("\n")}
    MESSAGE
  end

  test "reports previews no documentation page references" do
    referenced = preview_tags.to_set
    orphans = Dir.glob("#{PREVIEWS_DIR}/*/*.html.erb").map { |path|
      [File.basename(File.dirname(path)), File.basename(path, ".html.erb")]
    }.reject { |component, example| referenced.include?([component, example]) }.sort

    # Informational, not a failure: an unreferenced preview is a working page
    # nobody links yet, which harms nothing. It is printed so the count stays
    # visible when someone wonders which previews the docs actually use.
    if orphans.any?
      puts "\n[docs contract] #{orphans.size} preview(s) referenced by no doc page: " \
           "#{orphans.map { |component, example| "#{component}/#{example}" }.join(", ")}"
    end

    assert_operator referenced.size, :>=, 1
  end

  private

  def preview_path(doc, name)
    File.join(PREVIEWS_DIR, doc, "#{name}.html.erb")
  end

  def preview_tags
    preview_tags_with_height.map { |doc, name, _height| [doc, name] }
  end

  def preview_tags_with_height
    @preview_tags_with_height ||= Dir.glob("#{DOCS_DIR}/*.md").sort.flat_map do |path|
      doc = File.basename(path, ".md")
      File.read(path).scan(PREVIEW_TAG).map { |name, height| [doc, name, height] }
    end
  end
end
