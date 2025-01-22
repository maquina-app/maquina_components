# frozen_string_literal: true

module MaquinaComponents
  # Pagination Helper
  #
  # Provides convenient methods for creating pagination components with Pagy integration.
  #
  # @example Using the helper with Pagy
  #   <%%= pagination_nav(@pagy, :users_path) %>
  #
  # @example With additional params
  #   <%%= pagination_nav(@pagy, :search_users_path, params: { q: params[:q] }) %>
  #
  # @example With Turbo options
  #   <%%= pagination_nav(@pagy, :users_path, turbo: { action: :replace, frame: "users" }) %>
  #
  # @example Using partials directly
  #   <%%= render "components/pagination" do %>
  #     <%%= render "components/pagination/content" do %>
  #       <%%= render "components/pagination/item" do %>
  #         <%%= render "components/pagination/previous", href: prev_path %>
  #       <%% end %>
  #       ...
  #     <%% end %>
  #   <%% end %>
  #
  module PaginationHelper
    # Renders a complete pagination navigation from a Pagy object
    #
    # @param pagy [Pagy] The Pagy pagination object
    # @param route_helper [Symbol] Route helper method name (e.g., :users_path)
    # @param params [Hash] Additional params to pass to route helper
    # @param turbo [Hash] Turbo-specific data attributes
    # @param show_labels [Boolean] Whether to show Previous/Next text labels
    # @param css_classes [String] Additional CSS classes for the nav
    # @return [String] Rendered HTML
    def pagination_nav(pagy, route_helper, params: {}, turbo: {action: :replace}, show_labels: true, css_classes: "", **html_options)
      return if pagy.pages <= 1

      render "components/pagination", css_classes: css_classes, **html_options do
        render "components/pagination/content" do
          safe_join([
            pagination_previous_item(pagy, route_helper, params, turbo, show_labels),
            pagination_page_items(pagy, route_helper, params, turbo),
            pagination_next_item(pagy, route_helper, params, turbo, show_labels)
          ])
        end
      end
    end

    # Simpler pagination with just Previous/Next (no page numbers)
    #
    # @param pagy [Pagy] The Pagy pagination object
    # @param route_helper [Symbol] Route helper method name
    # @param params [Hash] Additional params to pass to route helper
    # @param turbo [Hash] Turbo-specific data attributes
    # @return [String] Rendered HTML
    def pagination_simple(pagy, route_helper, params: {}, turbo: {action: :replace}, css_classes: "", **html_options)
      return if pagy.pages <= 1

      render "components/pagination", css_classes: css_classes, **html_options do
        render "components/pagination/content" do
          safe_join([
            pagination_previous_item(pagy, route_helper, params, turbo, true),
            pagination_next_item(pagy, route_helper, params, turbo, true)
          ])
        end
      end
    end

    # Build paginated path with page param
    #
    # @param route_helper [Symbol] Route helper method name
    # @param pagy [Pagy] The Pagy pagination object
    # @param page [Integer] Page number
    # @param extra_params [Hash] Additional params
    # @return [String] URL path
    def paginated_path(route_helper, pagy, page, extra_params = {})
      page_param = pagy.vars[:page_param] || Pagy::DEFAULT[:page_param]
      query_params = request.query_parameters.except(page_param.to_s).merge(extra_params)
      query_params[page_param] = page

      send(route_helper, query_params)
    end

    private

    def pagination_previous_item(pagy, route_helper, params, turbo, show_label)
      render "components/pagination/item" do
        if pagy.prev
          render "components/pagination/previous",
            href: paginated_path(route_helper, pagy, pagy.prev, params),
            show_label: show_label,
            data: turbo_data(turbo)
        else
          render "components/pagination/previous",
            disabled: true,
            show_label: show_label
        end
      end
    end

    def pagination_next_item(pagy, route_helper, params, turbo, show_label)
      render "components/pagination/item" do
        if pagy.next
          render "components/pagination/next",
            href: paginated_path(route_helper, pagy, pagy.next, params),
            show_label: show_label,
            data: turbo_data(turbo)
        else
          render "components/pagination/next",
            disabled: true,
            show_label: show_label
        end
      end
    end

    def pagination_page_items(pagy, route_helper, params, turbo)
      pagy.series.map do |item|
        render "components/pagination/item" do
          case item
          when Integer
            render "components/pagination/link",
              href: paginated_path(route_helper, pagy, item, params),
              active: item == pagy.page,
              data: turbo_data(turbo) do
              item.to_s
            end
          when String
            # Current page (string representation)
            render "components/pagination/link",
              href: paginated_path(route_helper, pagy, item.to_i, params),
              active: true,
              data: turbo_data(turbo) do
              item
            end
          when :gap
            render "components/pagination/ellipsis"
          end
        end
      end
    end

    def turbo_data(turbo)
      return {} if turbo.blank?

      data = {}
      data[:turbo_action] = turbo[:action] if turbo[:action]
      data[:turbo_frame] = turbo[:frame] if turbo[:frame]
      data
    end
  end
end
