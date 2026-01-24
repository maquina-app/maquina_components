# frozen_string_literal: true

class PreviewsController < ApplicationController
  layout "preview"

  ALLOWED_FRAME_ANCESTORS = [
    "'self'",
    "https://maquina.app",
    "https://www.maquina.app",
    "http://localhost:3803",
    "http://localhost:3804",
    "http://127.0.0.1:3803"
  ].freeze

  before_action :set_theme
  before_action :set_preview, only: :show
  before_action :allow_iframe_embedding, only: :show

  def index
    @components = PreviewRegistry.manifest
    render layout: "application"
  end

  def show
    render "previews/#{@component}/#{@example}"
  end

  private

  def set_theme
    @theme = params[:theme].presence_in(%w[light dark]) || "light"
    @color_theme = params[:color_theme].presence_in(%w[neutral green rose blue])
  end

  def set_preview
    @component = params[:component].to_s
    @example = params[:example].to_s

    return if PreviewRegistry.valid_preview?(@component, @example)

    render plain: "Preview not found", status: :not_found
  end

  def allow_iframe_embedding
    response.headers.delete("X-Frame-Options")
    response.headers["Content-Security-Policy"] = "frame-ancestors #{ALLOWED_FRAME_ANCESTORS.join(" ")};"
  end
end
