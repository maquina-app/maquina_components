# Gemspec dependencies are not auto-required by Bundler in host apps,
# so load them here before the engine wires them up.
require "importmap-rails"
require "stimulus-rails"

require "maquina_components/version"
require "maquina_components/engine"

module MaquinaComponents
  # Raised by icon_for when a name resolves to no SVG and strict_icons is on.
  class UnknownIconError < ArgumentError; end

  class << self
    # When true, icon_for raises UnknownIconError for a name it can't resolve
    # instead of silently rendering nothing. Defaults to Rails.env.local?
    # (development and test), so typos surface while you work but never break
    # a production page.
    #
    #   # config/initializers/maquina_components.rb
    #   MaquinaComponents.strict_icons = false
    attr_writer :strict_icons

    def strict_icons
      return @strict_icons if defined?(@strict_icons)

      default_strict_icons
    end

    def strict_icons?
      !!strict_icons
    end

    private

    def default_strict_icons
      defined?(Rails) && Rails.respond_to?(:env) && Rails.env.respond_to?(:local?) && Rails.env.local?
    end
  end
end
