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

  def documented_previews
    docs = Rails.root.join("../../docs")
    return Set.new unless docs.directory?

    Dir.glob(docs.join("*.md")).flat_map { |path|
      component = File.basename(path, ".md")
      File.read(path).scan(DOC_TAG).flatten.map { |example| "#{component}/#{example}" }
    }.to_set
  end
end
