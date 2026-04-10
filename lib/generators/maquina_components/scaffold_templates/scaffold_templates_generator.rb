# frozen_string_literal: true

require "rails/generators/base"

module MaquinaComponents
  module Generators
    class ScaffoldTemplatesGenerator < Rails::Generators::Base
      source_root File.expand_path("templates", __dir__)

      desc "Copy maquina_components scaffold templates to your application"

      TEMPLATE_FILES = %w[
        _form.html.erb.tt
        edit.html.erb.tt
        index.html.erb.tt
        new.html.erb.tt
        partial.html.erb.tt
        show.html.erb.tt
      ].freeze

      def copy_templates
        TEMPLATE_FILES.each do |filename|
          copy_file filename, "lib/templates/erb/scaffold/#{filename}"
        end
      end

      def show_post_install_message
        say ""
        say "Scaffold templates installed!", :green
        say ""
        say "Rails will now use maquina_components when you run:"
        say "  rails generate scaffold ModelName field:type"
        say ""
        say "Templates are in lib/templates/erb/scaffold/"
        say "Feel free to customize them for your application."
        say ""
      end
    end
  end
end
