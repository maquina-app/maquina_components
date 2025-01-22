# frozen_string_literal: true

require "rails/generators/base"

module MaquinaComponents
  module Generators
    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path("templates", __dir__)

      desc "Install maquina_components into your Rails application"

      class_option :skip_theme, type: :boolean, default: false,
        desc: "Skip adding theme variables to application.css"
      class_option :skip_helper, type: :boolean, default: false,
        desc: "Skip creating the maquina_components helper"

      def check_tailwindcss_rails
        css_path = "app/assets/tailwind/application.css"

        unless File.exist?(File.join(destination_root, css_path))
          say_status :warning, "tailwindcss-rails doesn't appear to be installed", :yellow
          say "Please install tailwindcss-rails first:"
          say "  bundle add tailwindcss-rails"
          say "  rails tailwindcss:install"
          say ""
        end
      end

      def add_engine_css_import
        css_path = "app/assets/tailwind/application.css"
        full_path = File.join(destination_root, css_path)

        unless File.exist?(full_path)
          say_status :skip, "#{css_path} not found", :yellow
          return
        end

        import_line = '@import "../builds/tailwind/maquina_components_engine.css";'

        if File.read(full_path).include?(import_line)
          say_status :skip, "Engine CSS import already present", :blue
          return
        end

        # Insert after @import "tailwindcss"; or @import 'tailwindcss'; line
        inject_into_file css_path, after: /@import\s+["']tailwindcss["'];?\n/ do
          "\n#{import_line}\n"
        end

        say_status :insert, "Added maquina_components engine CSS import", :green
      end

      def add_theme_variables
        return if options[:skip_theme]

        css_path = "app/assets/tailwind/application.css"
        full_path = File.join(destination_root, css_path)

        unless File.exist?(full_path)
          say_status :skip, "#{css_path} not found", :yellow
          return
        end

        if File.read(full_path).include?("--color-primary:")
          say_status :skip, "Theme variables already present", :blue
          return
        end

        theme_content = File.read(File.expand_path("templates/theme.css.tt", __dir__))

        append_to_file css_path, "\n#{theme_content}"

        say_status :append, "Added theme variables to application.css", :green
      end

      def create_helper
        return if options[:skip_helper]

        helper_path = "app/helpers/maquina_components_helper.rb"
        full_path = File.join(destination_root, helper_path)

        if File.exist?(full_path)
          say_status :skip, "#{helper_path} already exists", :blue
          return
        end

        template "maquina_components_helper.rb.tt", helper_path
        say_status :create, helper_path, :green
      end

      def show_post_install_message
        say ""
        say "=" * 60
        say "  maquina_components installed successfully!", :green
        say "=" * 60
        say ""
        say "Next steps:"
        say ""
        say "1. Customize theme variables in app/assets/tailwind/application.css"
        say "   to match your design system."
        say ""
        say "2. Override the icon helper in app/helpers/maquina_components_helper.rb"
        say "   to use your own icon system (Heroicons, Lucide, etc.)."
        say ""
        say "3. Start using components in your views:"
        say ""
        say '   <%= render "components/card" do %>'
        say '     <%= render "components/card/header" do %>'
        say '       <%= render "components/card/title", text: "Hello" %>'
        say "     <% end %>"
        say "   <% end %>"
        say ""
        say "4. For form elements, use data attributes:"
        say ""
        say '   <%= f.text_field :email, data: { component: "input" } %>'
        say '   <%= f.submit "Save", data: { component: "button", variant: "primary" } %>'
        say ""
        say "Documentation: https://github.com/maquina-app/maquina_components"
        say ""
      end
    end
  end
end
