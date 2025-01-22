module MaquinaComponents
  class Engine < ::Rails::Engine
    initializer "maquina-components.importmap", before: "importmap" do |app|
      app.config.importmap.paths << Engine.root.join("config/importmap.rb")
    end

    initializer "maquin-components.importmap.assets" do |app|
      if app.config.respond_to?(:assets)
        app.config.assets.paths << Engine.root.join("app/javascript")
      end
    end
  end
end
