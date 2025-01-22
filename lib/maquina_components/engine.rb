module MaquinaComponents
  class Engine < ::Rails::Engine
    initializer "maquina-components.importmap", before: "importmap" do |app|
      app.config.importmap.paths << root.join("config/importmap.rb")
      app.config.importmap.cache_sweepers << root.join("app/javascript")
    end

    initializer "maquin-components.assets" do |app|
      if app.config.respond_to?(:assets)
        app.config.assets.paths << Engine.root.join("app/javascript")
      end
    end
  end
end
