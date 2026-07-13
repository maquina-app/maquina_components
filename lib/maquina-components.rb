# Gemspec dependencies are not auto-required by Bundler in host apps,
# so load them here before the engine wires them up.
require "importmap-rails"
require "stimulus-rails"

require "maquina_components/version"
require "maquina_components/engine"

module MaquinaComponents
  # Your code goes here...
end
