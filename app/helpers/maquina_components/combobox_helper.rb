# frozen_string_literal: true

module MaquinaComponents
  # Combobox Helper
  #
  # Provides a builder pattern for creating combobox components with a clean API.
  #
  # @example Basic usage
  #   <%= combobox placeholder: "Select framework..." do |cb| %>
  #     <% cb.trigger %>
  #     <% cb.content do %>
  #       <% cb.input placeholder: "Search..." %>
  #       <% cb.list do %>
  #         <% cb.option value: "nextjs" do %>Next.js<% end %>
  #         <% cb.option value: "remix" do %>Remix<% end %>
  #       <% end %>
  #       <% cb.empty %>
  #     <% end %>
  #   <% end %>
  #
  # @example Simple data-driven combobox
  #   <%= combobox_simple placeholder: "Select framework...",
  #                       options: [
  #                         { value: "nextjs", label: "Next.js" },
  #                         { value: "remix", label: "Remix" }
  #                       ] %>
  #
  # @example With groups
  #   <%= combobox placeholder: "Select..." do |cb| %>
  #     <% cb.trigger %>
  #     <% cb.content do %>
  #       <% cb.input %>
  #       <% cb.list do %>
  #         <% cb.group do %>
  #           <% cb.label "Frontend" %>
  #           <% cb.option value: "react" do %>React<% end %>
  #           <% cb.option value: "vue" do %>Vue<% end %>
  #         <% end %>
  #         <% cb.separator %>
  #         <% cb.group do %>
  #           <% cb.label "Backend" %>
  #           <% cb.option value: "rails" do %>Rails<% end %>
  #         <% end %>
  #       <% end %>
  #       <% cb.empty %>
  #     <% end %>
  #   <% end %>
  #
  module ComboboxHelper
    # Renders a combobox using the builder pattern
    #
    # @param id [String, nil] Explicit ID for the combobox
    # @param name [String, nil] Form field name
    # @param value [String, nil] Currently selected value
    # @param placeholder [String] Placeholder text
    # @param css_classes [String] Additional CSS classes
    # @param html_options [Hash] Additional HTML attributes
    # @yield [ComboboxBuilder] Builder instance for constructing the combobox
    # @return [String] Rendered HTML
    def combobox(id: nil, name: nil, value: nil, placeholder: "Select...", css_classes: "", **html_options, &block)
      builder = ComboboxBuilder.new(self, placeholder: placeholder)
      combobox_id = id || "combobox-#{SecureRandom.hex(4)}"
      builder.combobox_id = combobox_id

      capture(builder, &block)

      render "components/combobox",
        id: combobox_id,
        name: name,
        value: value,
        placeholder: placeholder,
        css_classes: css_classes,
        **html_options do |_id|
        builder.to_html
      end
    end

    # Renders a simple combobox from data
    #
    # @param options [Array<Hash>] Array of option configurations with :value and :label keys
    # @param placeholder [String] Placeholder text
    # @param search_placeholder [String] Search input placeholder
    # @param empty_text [String] Text shown when no results
    # @param value [String, nil] Currently selected value
    # @param name [String, nil] Form field name
    # @param trigger_options [Hash] Options for the trigger button
    # @param content_options [Hash] Options for the content container
    # @return [String] Rendered HTML
    def combobox_simple(
      options:,
      placeholder: "Select...",
      search_placeholder: "Search...",
      empty_text: "No results found.",
      value: nil,
      name: nil,
      trigger_options: {},
      content_options: {}
    )
      combobox(placeholder: placeholder, value: value, name: name) do |cb|
        cb.trigger(**trigger_options)

        cb.content(**content_options) do
          cb.input(placeholder: search_placeholder)
          cb.list do
            options.each do |opt|
              selected = value.present? && opt[:value].to_s == value.to_s
              cb.option(value: opt[:value], selected: selected, disabled: opt[:disabled]) do
                opt[:label] || opt[:value]
              end
            end
          end
          cb.empty(text: empty_text)
        end
      end
    end

    # Builder class for constructing comboboxes
    class ComboboxBuilder
      attr_accessor :combobox_id

      def initialize(view_context, placeholder:)
        @view = view_context
        @placeholder = placeholder
        @parts = []
      end

      # Defines the trigger button
      #
      # @param variant [Symbol] Button variant
      # @param size [Symbol] Button size
      # @param options [Hash] Additional options
      def trigger(variant: :outline, size: :default, **options)
        @parts << @view.render(
          "components/combobox/trigger",
          for_id: combobox_id,
          placeholder: @placeholder,
          variant: variant,
          size: size,
          **options
        )
      end

      # Defines the content popover
      #
      # @param align [Symbol] Horizontal alignment
      # @param width [Symbol] Width preset
      # @param options [Hash] Additional options
      # @yield Block containing combobox content
      def content(align: :start, width: :default, **options, &block)
        content_builder = ComboboxContentBuilder.new(@view)
        @view.capture(content_builder, &block)

        @parts << @view.render(
          "components/combobox/content",
          id: combobox_id,
          align: align,
          width: width,
          **options
        ) { content_builder.to_html }
      end

      # Shortcut to add input directly (delegates to content builder)
      def input(placeholder: "Search...", **options)
        @current_content_builder&.input(placeholder: placeholder, **options)
      end

      # Shortcut to add list directly (delegates to content builder)
      def list(**options, &block)
        @current_content_builder&.list(**options, &block)
      end

      # Shortcut to add empty directly (delegates to content builder)
      def empty(text: "No results found.", **options)
        @current_content_builder&.empty(text: text, **options)
      end

      # Generates the final HTML
      def to_html
        @view.safe_join(@parts)
      end
    end

    # Builder for combobox content
    class ComboboxContentBuilder
      def initialize(view_context)
        @view = view_context
        @parts = []
      end

      # Adds the search input
      #
      # @param placeholder [String] Input placeholder
      # @param options [Hash] Additional options
      def input(placeholder: "Search...", **options)
        @parts << @view.render(
          "components/combobox/input",
          placeholder: placeholder,
          **options
        )
      end

      # Adds the options list container
      #
      # @param options [Hash] Additional options
      # @yield Block containing options
      def list(**options, &block)
        list_builder = ComboboxListBuilder.new(@view)
        @view.capture(list_builder, &block)

        @parts << @view.render(
          "components/combobox/list",
          **options
        ) { list_builder.to_html }
      end

      # Adds the empty state
      #
      # @param text [String] Empty state text
      # @param options [Hash] Additional options
      def empty(text: "No results found.", **options)
        @parts << @view.render(
          "components/combobox/empty",
          text: text,
          **options
        )
      end

      # Generates the final HTML
      def to_html
        @view.safe_join(@parts)
      end
    end

    # Builder for combobox list content
    class ComboboxListBuilder
      def initialize(view_context)
        @view = view_context
        @parts = []
      end

      # Adds an option
      #
      # @param value [String] Option value
      # @param selected [Boolean] Whether selected
      # @param disabled [Boolean] Whether disabled
      # @param options [Hash] Additional options
      # @yield Block for option content
      def option(value:, selected: false, disabled: false, **options, &block)
        content = @view.capture(&block) if block
        @parts << @view.render(
          "components/combobox/option",
          value: value,
          selected: selected,
          disabled: disabled,
          **options
        ) { content }
      end

      # Adds a group
      #
      # @param options [Hash] Additional options
      # @yield Block containing group items
      def group(**options, &block)
        group_builder = ComboboxListBuilder.new(@view)
        @view.capture(group_builder, &block)

        @parts << @view.render(
          "components/combobox/group",
          **options
        ) { group_builder.to_html }
      end

      # Adds a label
      #
      # @param text [String, nil] Label text
      # @param options [Hash] Additional options
      # @yield Optional block for custom content
      def label(text = nil, **options, &block)
        @parts << @view.render(
          "components/combobox/label",
          text: text,
          **options,
          &block
        )
      end

      # Adds a separator
      #
      # @param options [Hash] Additional options
      def separator(**options)
        @parts << @view.render("components/combobox/separator", **options)
      end

      # Generates the final HTML
      def to_html
        @view.safe_join(@parts)
      end
    end
  end
end
