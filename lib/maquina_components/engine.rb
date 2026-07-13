module MaquinaComponents
  class Engine < ::Rails::Engine
    initializer "maquina-components.importmap", before: "importmap" do |app|
      # Hosts bundling JS without importmap-rails (esbuild, vite, bun)
      # have no config.importmap; skip so the engine doesn't break boot.
      if app.config.respond_to?(:importmap)
        app.config.importmap.paths << root.join("config/importmap.rb")
        app.config.importmap.cache_sweepers << root.join("app/javascript")
      end
    end

    initializer "maquina-components.assets" do |app|
      if app.config.respond_to?(:assets)
        app.config.assets.paths << Engine.root.join("app/javascript")
      end
    end
  end
end
