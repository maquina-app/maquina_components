# frozen_string_literal: true

module MaquinaComponents
  # Breadcrumbs Helper
  #
  # Provides helper methods for rendering breadcrumb navigation.
  # Supports both simple hash-based API and composable partials.
  #
  module BreadcrumbsHelper
    # Render breadcrumbs from a hash of links
    #
    # @param links [Hash] Hash of text => path pairs
    # @param current_page [String, nil] Text for current page (no link)
    # @param css_classes [String] Additional CSS classes for nav element
    # @return [String] HTML string
    #
    # @example Basic usage
    #   breadcrumbs({"Home" => root_path, "Users" => users_path}, "John Doe")
    #
    # @example Without current page
    #   breadcrumbs({"Home" => root_path, "Users" => users_path})
    #
    def breadcrumbs(links = {}, current_page = nil, css_classes: "")
      render "components/breadcrumbs", css_classes: css_classes do
        render "components/breadcrumbs/list" do
          build_breadcrumb_items(links, current_page, responsive: false)
        end
      end
    end

    # Render responsive breadcrumbs that auto-collapse on overflow
    #
    # Uses Stimulus controller to hide middle items when space is limited,
    # showing an ellipsis element instead.
    #
    # @param links [Hash] Hash of text => path pairs
    # @param current_page [String, nil] Text for current page (no link)
    # @param css_classes [String] Additional CSS classes for nav element
    # @return [String] HTML string
    #
    # @example
    #   responsive_breadcrumbs(
    #     {"Home" => root_path, "Docs" => docs_path, "Components" => components_path},
    #     "Button"
    #   )
    #
    def responsive_breadcrumbs(links = {}, current_page = nil, css_classes: "")
      render "components/breadcrumbs", css_classes: css_classes, responsive: true do
        render "components/breadcrumbs/list" do
          build_breadcrumb_items(links, current_page, responsive: true)
        end
      end
    end

    private

    # Build breadcrumb items from links hash
    #
    # @param links [Hash] Hash of text => path pairs
    # @param current_page [String, nil] Text for current page
    # @param responsive [Boolean] Whether to include Stimulus targets
    # @return [String] Safe-joined HTML string
    #
    def build_breadcrumb_items(links, current_page, responsive: false)
      items = []
      link_array = links.to_a

      link_array.each_with_index do |(text, path), index|
        # Determine if this is a collapsible middle item (not first or last)
        is_middle = responsive && index > 0 && (index < link_array.size - 1 || current_page.present?)
        item_data = is_middle ? {breadcrumb_target: "item"} : {}

        items << capture do
          render "components/breadcrumbs/item", data: item_data do
            render "components/breadcrumbs/link", href: path do
              text
            end
          end
        end

        # Add separator after each link
        items << capture do
          render "components/breadcrumbs/separator"
        end

        # Insert ellipsis after first item for responsive mode
        if responsive && index == 0 && (link_array.size > 2 || (link_array.size > 1 && current_page.present?))
          items << capture do
            render "components/breadcrumbs/item", css_classes: "hidden", data: {breadcrumb_target: "ellipsis"} do
              render "components/breadcrumbs/ellipsis"
            end
          end

          items << capture do
            render "components/breadcrumbs/separator", css_classes: "hidden", data: {breadcrumb_target: "ellipsisSeparator"}
          end
        end
      end

      # Add current page if provided
      if current_page.present?
        # Remove last separator since current page follows
        items << capture do
          render "components/breadcrumbs/item" do
            render "components/breadcrumbs/page" do
              current_page
            end
          end
        end
      else
        # Remove trailing separator if no current page
        items.pop
      end

      safe_join(items)
    end
  end
end
