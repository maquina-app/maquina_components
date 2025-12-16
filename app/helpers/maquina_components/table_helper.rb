# frozen_string_literal: true

module MaquinaComponents
  # Table Component Helper
  #
  # Provides a simple helper for rendering basic tables from collections.
  # For complex tables, use the partials directly for full control.
  #
  # @example Basic usage with collection
  #   <%= simple_table @invoices,
  #         columns: [
  #           { key: :number, label: "Invoice" },
  #           { key: :status, label: "Status" },
  #           { key: :amount, label: "Amount", align: :right }
  #         ] %>
  #
  # @example With caption and bordered variant
  #   <%= simple_table @users,
  #         columns: [
  #           { key: :name, label: "Name" },
  #           { key: :email, label: "Email" },
  #           { key: :role, label: "Role" }
  #         ],
  #         caption: "Active users",
  #         variant: :bordered %>
  #
  module TableHelper
    # Render a simple table from a collection
    #
    # @param collection [Array, ActiveRecord::Relation] The collection to render
    # @param columns [Array<Hash>] Column definitions with :key, :label, and optional :align
    # @param caption [String, nil] Optional table caption
    # @param variant [Symbol, nil] Container variant (:bordered)
    # @param table_variant [Symbol, nil] Table variant (:striped)
    # @param empty_message [String] Message to show when collection is empty
    # @param row_id [Symbol, nil] Method to call for row ID (e.g., :id)
    # @param html_options [Hash] Additional HTML options for the table
    # @return [String] Rendered HTML
    def simple_table(collection, columns:, caption: nil, variant: nil, table_variant: nil, empty_message: "No data available", row_id: nil, **html_options)
      render partial: "components/simple_table", locals: {
        collection: collection,
        columns: columns,
        caption: caption,
        variant: variant,
        table_variant: table_variant,
        empty_message: empty_message,
        row_id: row_id,
        html_options: html_options
      }
    end

    # Generate data attributes for table elements
    # Useful when composing tables with other Rails helpers
    #
    # @example Using with content_tag
    #   <%= content_tag :table, **table_data_attrs do %>
    #     ...
    #   <% end %>
    #
    # @param variant [Symbol, nil] Table variant (:striped)
    # @return [Hash] Data attributes hash
    def table_data_attrs(variant: nil)
      attrs = { data: { component: "table" } }
      attrs[:data][:variant] = variant.to_s if variant
      attrs
    end

    # Generate data attributes for table container
    #
    # @param variant [Symbol, nil] Container variant (:bordered)
    # @return [Hash] Data attributes hash
    def table_container_data_attrs(variant: nil)
      attrs = { data: { table_part: "container" } }
      attrs[:data][:variant] = variant.to_s if variant
      attrs
    end

    # Generate data attributes for table row
    #
    # @param selected [Boolean] Whether the row is selected
    # @return [Hash] Data attributes hash
    def table_row_data_attrs(selected: false)
      attrs = { data: { table_part: "row" } }
      attrs[:data][:state] = "selected" if selected
      attrs
    end

    # Generate data attributes for table header
    #
    # @param sticky [Boolean] Whether the header is sticky
    # @return [Hash] Data attributes hash
    def table_header_data_attrs(sticky: false)
      attrs = { data: { table_part: "header" } }
      attrs[:data][:sticky] = "true" if sticky
      attrs
    end

    # Generate data attributes for table head cell
    # @return [Hash] Data attributes hash
    def table_head_data_attrs
      { data: { table_part: "head" } }
    end

    # Generate data attributes for table cell
    #
    # @param empty [Boolean] Whether this is an empty state cell
    # @return [Hash] Data attributes hash
    def table_cell_data_attrs(empty: false)
      attrs = { data: { table_part: "cell" } }
      attrs[:data][:empty] = "true" if empty
      attrs
    end

    # Generate data attributes for table body
    # @return [Hash] Data attributes hash
    def table_body_data_attrs
      { data: { table_part: "body" } }
    end

    # Generate data attributes for table footer
    # @return [Hash] Data attributes hash
    def table_footer_data_attrs
      { data: { table_part: "footer" } }
    end

    # Generate data attributes for table caption
    # @return [Hash] Data attributes hash
    def table_caption_data_attrs
      { data: { table_part: "caption" } }
    end

    # Convert alignment symbol to CSS class
    #
    # @param align [Symbol, nil] Alignment (:left, :center, :right)
    # @return [String, nil] CSS class name
    def table_alignment_class(align)
      case align&.to_sym
      when :right then "text-right"
      when :center then "text-center"
      else nil
      end
    end
  end
end
