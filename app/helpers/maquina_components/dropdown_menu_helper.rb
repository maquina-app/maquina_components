# frozen_string_literal: true

module MaquinaComponents
  # DropdownMenu Helper
  #
  # Provides a builder pattern for creating dropdown menus with a clean API.
  #
  # @example Basic usage
  #   <%= dropdown_menu do |menu| %>
  #     <% menu.trigger { "Options" } %>
  #     <% menu.content do %>
  #       <% menu.item "Profile", href: profile_path %>
  #       <% menu.item "Settings", href: settings_path %>
  #     <% end %>
  #   <% end %>
  #
  # @example With icons and shortcuts
  #   <%= dropdown_menu do |menu| %>
  #     <% menu.trigger variant: :ghost, size: :icon do %>
  #       <%= icon_for :more_horizontal %>
  #     <% end %>
  #     <% menu.content align: :end, width: :md do %>
  #       <% menu.label "Actions" %>
  #       <% menu.item "Edit", href: edit_path, icon: :pencil do |item| %>
  #         <% item.shortcut "⌘E" %>
  #       <% end %>
  #       <% menu.separator %>
  #       <% menu.item "Delete", href: delete_path, method: :delete, variant: :destructive, icon: :trash %>
  #     <% end %>
  #   <% end %>
  #
  # @example Simple data-driven menu
  #   <%= dropdown_menu_simple "Actions", items: [
  #     { label: "Edit", href: edit_path, icon: :pencil },
  #     { label: "Delete", href: delete_path, method: :delete, destructive: true }
  #   ] %>
  #
  module DropdownMenuHelper
    # Renders a dropdown menu using the builder pattern
    #
    # @param css_classes [String] Additional CSS classes for the root element
    # @param html_options [Hash] Additional HTML attributes
    # @yield [DropdownMenuBuilder] Builder instance for constructing the menu
    # @return [String] Rendered HTML
    def dropdown_menu(css_classes: "", **html_options, &block)
      builder = DropdownMenuBuilder.new(self)
      capture(builder, &block)

      render "components/dropdown_menu", css_classes: css_classes, **html_options do
        builder.to_html
      end
    end

    # Renders a simple dropdown menu from data
    #
    # @param trigger_text [String] Text for the trigger button
    # @param items [Array<Hash>] Array of item configurations
    # @param trigger_options [Hash] Options for the trigger button
    # @param content_options [Hash] Options for the content container
    # @return [String] Rendered HTML
    def dropdown_menu_simple(trigger_text, items:, trigger_options: {}, content_options: {})
      dropdown_menu do |menu|
        menu.trigger(**trigger_options) { trigger_text }

        menu.content(**content_options) do
          items.each do |item|
            if item[:separator]
              menu.separator
            elsif item[:label] && item[:href].nil? && item[:action].nil?
              menu.label item[:label]
            else
              variant = item[:destructive] ? :destructive : :default
              menu.item(
                item[:label],
                href: item[:href],
                method: item[:method],
                icon: item[:icon],
                variant: variant,
                disabled: item[:disabled]
              )
            end
          end
        end
      end
    end

    # Builder class for constructing dropdown menus
    class DropdownMenuBuilder
      def initialize(view_context)
        @view = view_context
        @trigger_content = nil
        @content_block = nil
      end

      # Defines the trigger button
      #
      # @param variant [Symbol] Button variant
      # @param size [Symbol] Button size
      # @param as_child [Boolean] Whether to use custom trigger markup
      # @param options [Hash] Additional options
      # @yield Block for trigger content
      def trigger(variant: :outline, size: :default, as_child: false, **options, &block)
        @trigger_options = {variant: variant, size: size, as_child: as_child, **options}
        @trigger_content = @view.capture(&block)
      end

      # Defines the menu content
      #
      # @param align [Symbol] Horizontal alignment
      # @param side [Symbol] Which side to open
      # @param width [Symbol] Width preset
      # @param options [Hash] Additional options
      # @yield Block containing menu items
      def content(align: :start, side: :bottom, width: :default, **options, &block)
        @content_options = {align: align, side: side, width: width, **options}
        @content_builder = DropdownMenuContentBuilder.new(@view)
        @view.capture(@content_builder, &block)
      end

      # Generates the final HTML
      def to_html
        parts = []

        if @trigger_content
          parts << @view.render(
            "components/dropdown_menu/trigger",
            **@trigger_options
          ) { @trigger_content }
        end

        if @content_builder
          parts << @view.render(
            "components/dropdown_menu/content",
            **@content_options
          ) { @content_builder.to_html }
        end

        @view.safe_join(parts)
      end
    end

    # Builder for dropdown menu content
    class DropdownMenuContentBuilder
      def initialize(view_context)
        @view = view_context
        @parts = []
      end

      # Adds a menu item
      #
      # @param label [String, nil] Item label (alternative to block)
      # @param href [String, nil] URL for the item
      # @param method [Symbol, nil] HTTP method
      # @param icon [Symbol, nil] Icon name
      # @param variant [Symbol] Visual variant
      # @param disabled [Boolean] Whether disabled
      # @param options [Hash] Additional options
      # @yield Optional block for custom content or item builder
      def item(label = nil, href: nil, method: nil, icon: nil, variant: :default, disabled: false, **options, &block)
        item_builder = DropdownMenuItemBuilder.new(@view)

        content = if block
          @view.capture(item_builder, &block)
        elsif label
          build_item_content(label, icon)
        end

        # Append shortcut if defined via builder
        content = @view.safe_join([content, item_builder.shortcut_html].compact) if item_builder.shortcut_html

        @parts << @view.render(
          "components/dropdown_menu/item",
          href: href,
          method: method,
          variant: variant,
          disabled: disabled,
          **options
        ) { content }
      end

      # Adds a label/heading
      #
      # @param text [String, nil] Label text
      # @param inset [Boolean] Whether to indent
      # @param options [Hash] Additional options
      # @yield Optional block for custom content
      def label(text = nil, inset: false, **options, &block)
        @parts << @view.render(
          "components/dropdown_menu/label",
          text: text,
          inset: inset,
          **options,
          &block
        )
      end

      # Adds a separator
      #
      # @param options [Hash] Additional options
      def separator(**options)
        @parts << @view.render("components/dropdown_menu/separator", **options)
      end

      # Adds a group
      #
      # @param options [Hash] Additional options
      # @yield Block containing group items
      def group(**options, &block)
        group_builder = DropdownMenuContentBuilder.new(@view)
        @view.capture(group_builder, &block)

        @parts << @view.render("components/dropdown_menu/group", **options) do
          group_builder.to_html
        end
      end

      # Generates the final HTML
      def to_html
        @view.safe_join(@parts)
      end

      private

      def build_item_content(label, icon)
        parts = []
        parts << @view.icon_for(icon) if icon && @view.respond_to?(:icon_for)
        parts << label
        @view.safe_join(parts)
      end
    end

    # Builder for individual menu items (supports shortcuts)
    class DropdownMenuItemBuilder
      attr_reader :shortcut_html

      def initialize(view_context)
        @view = view_context
        @shortcut_html = nil
      end

      # Adds a keyboard shortcut
      #
      # @param text [String] Shortcut text
      def shortcut(text)
        @shortcut_html = @view.render("components/dropdown_menu/shortcut", text: text)
      end
    end
  end
end
