# frozen_string_literal: true

# MaquinaComponents Helper
#
# This helper provides customization hooks for maquina_components.
# Override methods here to integrate with your application's icon system,
# sidebar state management, and other customizations.
#
# Documentation: https://github.com/maquina-app/maquina_components
#
module MaquinaComponentsHelper
  # Icon Override
  #
  # Override this method to use your own icon system (Heroicons, Lucide, etc.)
  # The engine's icon_for helper will call this method first.
  #
  # @param name [Symbol] Icon name (e.g., :check, :chevron_right, :home)
  # @param options [Hash] Options hash with :class, :stroke_width, etc.
  # @return [String, nil] SVG string or nil to fall back to engine's icons
  #
  # @example Using Heroicons
  #   def main_icon_svg_for(name)
  #     heroicon_tag(name, variant: :outline)
  #   end
  #
  # @example Using Lucide
  #   def main_icon_svg_for(name)
  #     lucide_icon(name)
  #   end
  #
  # @example Using inline SVG files
  #   def main_icon_svg_for(name)
  #     file_path = Rails.root.join("app/assets/images/icons/#{name}.svg")
  #     File.read(file_path) if File.exist?(file_path)
  #   end
  #
  def main_icon_svg_for(name)
    # Return nil to use the engine's built-in icons
    # Override this method to use your own icon system
    nil
  end

  # Sidebar State Helpers
  #
  # These helpers are re-exported from the engine for convenience.
  # You can override them if you need custom cookie names or behavior.

  # Returns the current sidebar state from cookies
  # @param cookie_name [String] Cookie name (default: "sidebar_state")
  # @return [Symbol] :expanded or :collapsed
  def app_sidebar_state(cookie_name = "sidebar_state")
    sidebar_state(cookie_name)
  end

  # Check if sidebar is expanded
  # @param cookie_name [String] Cookie name (default: "sidebar_state")
  # @return [Boolean]
  def app_sidebar_open?(cookie_name = "sidebar_state")
    sidebar_open?(cookie_name)
  end

  # Check if sidebar is collapsed
  # @param cookie_name [String] Cookie name (default: "sidebar_state")
  # @return [Boolean]
  def app_sidebar_closed?(cookie_name = "sidebar_state")
    sidebar_closed?(cookie_name)
  end
end
