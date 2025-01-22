# frozen_string_literal: true

module MaquinaComponents
  # Empty Helper
  #
  # Provides convenient methods for creating empty state components.
  #
  # @example Simple empty state
  #   <%= empty_state title: "No projects", description: "Get started by creating one.", icon: :folder_open %>
  #
  # @example With action button
  #   <%= empty_state title: "No projects", icon: :folder_open do %>
  #     <%= link_to "Create Project", new_project_path, data: { component: "button", variant: "primary" } %>
  #   <% end %>
  #
  # @example Full control with partials
  #   <%= render "components/empty", variant: :outline do %>
  #     <%= render "components/empty/header" do %>
  #       <%= render "components/empty/media", icon: :search %>
  #       <%= render "components/empty/title", text: "No results" %>
  #     <% end %>
  #   <% end %>
  #
  module EmptyHelper
    # Renders an empty state component with a simple API
    #
    # @param title [String] The title text
    # @param description [String, nil] Optional description text
    # @param icon [Symbol, nil] Icon name (uses icon_for helper)
    # @param variant [Symbol] Visual style (:default, :outline)
    # @param size [Symbol] Size variant (:default, :compact)
    # @param css_classes [String] Additional CSS classes
    # @param html_options [Hash] Additional HTML attributes
    # @yield Optional block for action content (buttons, links)
    # @return [String] Rendered HTML
    def empty_state(title:, description: nil, icon: nil, variant: :default, size: :default, css_classes: "", **html_options, &block)
      render "components/empty", variant: variant, size: size, css_classes: css_classes, **html_options do
        parts = []

        # Build header
        header_content = []
        header_content << render("components/empty/media", icon: icon) if icon
        header_content << render("components/empty/title", text: title)
        header_content << render("components/empty/description", text: description) if description

        parts << render("components/empty/header") { safe_join(header_content) }

        # Add content/actions if block given
        if block
          parts << render("components/empty/content") { capture(&block) }
        end

        safe_join(parts)
      end
    end

    # Renders an empty state for search results
    #
    # @param query [String, nil] The search query (for display)
    # @param reset_path [String, nil] Path to reset/clear search
    # @param size [Symbol] Size variant
    # @return [String] Rendered HTML
    def empty_search_state(query: nil, reset_path: nil, size: :default)
      description = if query.present?
        "No results found for \"#{query}\". Try a different search term."
      else
        "No results found. Try adjusting your search."
      end

      empty_state(
        title: "No results",
        description: description,
        icon: :search,
        size: size
      ) do
        if reset_path
          link_to "Clear search", reset_path, data: {component: "button", variant: "outline", size: "sm"}
        end
      end
    end

    # Renders an empty state for lists/tables
    #
    # @param resource_name [String] Name of the resource (e.g., "projects", "users")
    # @param new_path [String, nil] Path to create new resource
    # @param icon [Symbol] Icon to display
    # @param size [Symbol] Size variant
    # @return [String] Rendered HTML
    def empty_list_state(resource_name:, new_path: nil, icon: :folder_open, size: :default)
      empty_state(
        title: "No #{resource_name} yet",
        description: "Get started by creating your first #{resource_name.singularize}.",
        icon: icon,
        size: size
      ) do
        if new_path
          link_to "Create #{resource_name.singularize.titleize}", new_path, data: {component: "button", variant: "primary"}
        end
      end
    end
  end
end
