class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # This app is a component-preview harness. maquina.app embeds these pages in
  # <iframe> previews, so the same content is already published on the docs
  # site. Left crawlable, Google indexed the previews as a second copy of the
  # documentation — Search Console reported 43 "duplicate without user-selected
  # canonical" URLs here, plus soft 404s for previews that no longer exist.
  #
  # The preview pages are meant for humans reading the docs, not for search
  # results, so they are excluded from indexing. nofollow keeps the iframe
  # embed intact (it follows no links out) while stopping the preview URLs
  # from competing with the canonical docs pages.
  before_action :disallow_indexing

  private

  def disallow_indexing
    response.headers["X-Robots-Tag"] = "noindex, nofollow"
  end
end
