# frozen_string_literal: true

# CORS configuration for component preview embeds
#
# Allows the documentation site to embed previews via iframe
# and receive postMessage communications.

if defined?(Rack::Cors)
  Rails.application.config.middleware.insert_before 0, Rack::Cors do
    allow do
      origins(
        "maquina.app",
        "www.maquina.app",
        "http://localhost:3803",    # Bridgetown dev server
        "http://localhost:3804",    # Bridgetown live reload
        "http://127.0.0.1:3803"
      )

      resource "/previews/*",
        headers: :any,
        methods: %i[get options head]
    end
  end
end
