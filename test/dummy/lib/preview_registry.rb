# frozen_string_literal: true

module PreviewRegistry
  PREVIEW_PATH = Rails.root.join("app/views/previews")

  class << self
    def components
      @components ||= scan_components
    end

    def examples_for(component)
      examples_cache[component] ||= scan_examples(component)
    end

    def manifest
      components.index_with { |c| examples_for(c) }
    end

    def valid_preview?(component, example)
      components.include?(component) && examples_for(component).include?(example)
    end

    def reload!
      @components = nil
      @examples_cache = nil
    end

    private

    def scan_components
      return [] unless PREVIEW_PATH.exist?

      PREVIEW_PATH.children
        .select(&:directory?)
        .map { |d| d.basename.to_s }
        .reject { |n| n.start_with?("_") }
        .sort
    end

    def scan_examples(component)
      path = PREVIEW_PATH.join(component)
      return [] unless path.exist?

      path.children
        .select { |f| f.extname == ".erb" && !f.basename.to_s.start_with?("_") }
        .map { |f| f.basename(".html.erb").to_s }
        .sort
    end

    def examples_cache
      @examples_cache ||= {}
    end
  end
end
