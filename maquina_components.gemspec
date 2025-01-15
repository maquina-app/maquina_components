require_relative "lib/maquina_components/version"

Gem::Specification.new do |spec|
  spec.name = "maquina_components"
  spec.version = MaquinaComponents::VERSION
  spec.authors = ["Mario Alberto Chávez"]
  spec.email = ["mario.chavez@gmail.com"]
  spec.homepage = "https://maquina.app"
  spec.summary = "ERB, TailwindCSS, and StimulusJS UI components based on Shadcn/UI."
  spec.description = "ERB, TailwindCSS, and StimulusJS UI components based on Shadcn/UI."
  spec.license = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the "allowed_push_host"
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  # spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/maquina-app/maquina_components"
  spec.metadata["changelog_uri"] = "https://github.com/maquina-app/maquina_components"

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]
  end

  spec.add_dependency "rails", ">= 8.0.0"
end
