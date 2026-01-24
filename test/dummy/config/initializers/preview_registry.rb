# frozen_string_literal: true

require_relative "../../lib/preview_registry"

# Reload preview registry on file changes in development
if Rails.env.development?
  Rails.application.config.to_prepare do
    PreviewRegistry.reload!
  end
end
