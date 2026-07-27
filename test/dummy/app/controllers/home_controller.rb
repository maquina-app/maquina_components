class HomeController < ApplicationController
  # Previews referenced by a <!-- preview:NAME --> tag in the engine's docs.
  # The site turns those tags into live iframes, so a referenced preview is
  # published documentation: renaming or deleting it 404s a docs page.
  DOC_TAG = /<!--\s*preview:([a-z_]+)/

  # The showcase is generated from the preview registry, so a new preview file
  # shows up here without anyone editing the page.
  def index
    @manifest = PreviewRegistry.manifest
    @documented = documented_previews
  end

  private

  # nil when docs/ is unavailable — it is excluded from the deployed image by
  # .dockerignore. That is "cannot tell", not "nothing is referenced": an empty
  # Set here would report every preview as an orphan, which is the confidently
  # wrong answer.
  def documented_previews
    docs = Rails.root.join("../../docs")
    return nil unless docs.directory?

    Dir.glob(docs.join("*.md")).flat_map { |path|
      component = File.basename(path, ".md")
      File.read(path).scan(DOC_TAG).flatten.map { |example| "#{component}/#{example}" }
    }.to_set
  end
end
