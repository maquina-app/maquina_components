# frozen_string_literal: true

module MaquinaComponents
  # Toggle Group Helper
  #
  # Provides convenient methods for creating toggle group components.
  #
  # @example Using partials directly
  #   <%%= render "components/toggle_group", type: :single, variant: :outline do %>
  #     <%%= render "components/toggle_group/item", value: "bold", aria_label: "Toggle bold" do %>
  #       <%%= icon_for :bold %>
  #     <%% end %>
  #   <%% end %>
  #
  # @example Using the helper with builder
  #   <%%= toggle_group type: :multiple, variant: :outline do |group| %>
  #     <%% group.item value: "bold", icon: :bold, aria_label: "Toggle bold" %>
  #     <%% group.item value: "italic", icon: :italic, aria_label: "Toggle italic" %>
  #   <%% end %>
  #
  # @example Simple data-driven helper
  #   <%%= toggle_group_simple type: :single, items: [
  #     { value: "left", icon: :align_left, aria_label: "Align left" },
  #     { value: "center", icon: :align_center, aria_label: "Align center" },
  #     { value: "right", icon: :align_right, aria_label: "Align right" }
  #   ] %>
  #
  module ToggleGroupHelper
    # Renders a toggle group with builder pattern
    #
    # @param type [Symbol] Selection mode (:single, :multiple)
    # @param variant [Symbol] Visual style (:default, :outline)
    # @param size [Symbol] Size variant (:default, :sm, :lg)
    # @param value [String, Array, nil] Initially selected value(s)
    # @param disabled [Boolean] Disable all items
    # @param css_classes [String] Additional CSS classes
    # @param html_options [Hash] Additional HTML attributes
    # @yield [ToggleGroupBuilder] Builder for adding items
    # @return [String] Rendered HTML
    def toggle_group(type: :single, variant: :default, size: :default, value: nil, disabled: false, css_classes: "", **html_options, &block)
      builder = ToggleGroupBuilder.new(self, type: type, variant: variant, size: size, value: value, disabled: disabled)

      if block && block.arity == 1
        capture { yield(builder) }
      end

      render "components/toggle_group",
        type: type,
        variant: variant,
        size: size,
        value: value,
        disabled: disabled,
        css_classes: css_classes,
        **html_options do
        if block && block.arity == 1
          builder.to_html
        elsif block
          capture(&block)
        end
      end
    end

    # Renders a simple data-driven toggle group
    #
    # @param type [Symbol] Selection mode (:single, :multiple)
    # @param items [Array<Hash>] Array of item configurations
    # @param variant [Symbol] Visual style
    # @param size [Symbol] Size variant
    # @param value [String, Array, nil] Initially selected value(s)
    # @return [String] Rendered HTML
    def toggle_group_simple(items:, type: :single, variant: :default, size: :default, value: nil, disabled: false, css_classes: "", **html_options)
      selected_values = normalize_value(value)

      render "components/toggle_group",
        type: type,
        variant: variant,
        size: size,
        value: value,
        disabled: disabled,
        css_classes: css_classes,
        **html_options do
        safe_join(items.map do |item|
          item_value = item[:value].to_s
          is_pressed = selected_values.include?(item_value)

          render "components/toggle_group/item",
            value: item_value,
            pressed: is_pressed,
            disabled: item[:disabled] || disabled,
            aria_label: item[:aria_label] do
            parts = []
            parts << icon_for(item[:icon]) if item[:icon] && respond_to?(:icon_for)
            parts << item[:label] if item[:label]
            safe_join(parts)
          end
        end)
      end
    end

    # Builder class for toggle group
    class ToggleGroupBuilder
      def initialize(view_context, type:, variant:, size:, value:, disabled:)
        @view = view_context
        @type = type
        @variant = variant
        @size = size
        @value = value
        @disabled = disabled
        @items = []
        @selected_values = normalize_value(value)
      end

      # Add an item to the toggle group
      def item(value:, label: nil, icon: nil, disabled: false, aria_label: nil, **options, &block)
        is_pressed = @selected_values.include?(value.to_s)

        @items << {
          value: value,
          label: label,
          icon: icon,
          disabled: disabled || @disabled,
          aria_label: aria_label,
          pressed: is_pressed,
          options: options,
          block: block
        }
      end

      def to_html
        @view.safe_join(@items.map { |item| render_item(item) })
      end

      private

      def render_item(item)
        @view.render "components/toggle_group/item",
          value: item[:value],
          pressed: item[:pressed],
          disabled: item[:disabled],
          aria_label: item[:aria_label],
          **item[:options] do
          if item[:block]
            @view.capture(&item[:block])
          else
            parts = []
            parts << @view.icon_for(item[:icon]) if item[:icon] && @view.respond_to?(:icon_for)
            parts << item[:label] if item[:label]
            @view.safe_join(parts)
          end
        end
      end

      def normalize_value(value)
        case value
        when Array then value.map(&:to_s)
        when nil then []
        else [value.to_s]
        end
      end
    end

    private

    def normalize_value(value)
      case value
      when Array then value.map(&:to_s)
      when nil then []
      else [value.to_s]
      end
    end
  end
end
