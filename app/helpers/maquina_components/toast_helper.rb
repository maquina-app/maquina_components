# frozen_string_literal: true

module MaquinaComponents
  # Toast Helper
  #
  # Provides helpers for rendering toast notifications.
  #
  # @example Render flash messages as toasts
  #   <%= toast_flash_messages %>
  #
  # @example Render a single toast
  #   <%= toast :success, "Profile updated!" %>
  #
  # @example Toast with description
  #   <%= toast :error, "Save failed", description: "Please check your connection." %>
  #
  # @example Toast with action
  #   <%= toast :info, "New version available" do %>
  #     <%= render "components/toast/action", label: "Refresh", href: root_path %>
  #   <% end %>
  #
  module ToastHelper
    # Flash type to toast variant mapping
    FLASH_VARIANTS = {
      notice: :success,
      success: :success,
      alert: :error,
      error: :error,
      warning: :warning,
      warn: :warning,
      info: :info
    }.freeze

    # Render all flash messages as toasts
    #
    # @param exclude [Array<Symbol>] Flash types to exclude
    # @return [String] HTML-safe string of toast elements
    def toast_flash_messages(exclude: [])
      return "" if flash.empty?

      toasts = flash.map do |type, message|
        next if exclude.include?(type.to_sym)
        next if message.blank?

        variant = flash_to_variant(type)
        render "components/toast", variant: variant, title: message
      end

      safe_join(toasts.compact)
    end

    # Render a single toast
    #
    # @param variant [Symbol] Toast variant (:default, :success, :info, :warning, :error)
    # @param title [String] Toast title
    # @param description [String, nil] Optional description
    # @param options [Hash] Additional options passed to the toast partial
    # @yield Optional block for custom content (e.g., action button)
    # @return [String] HTML-safe toast element
    def toast(variant, title, description: nil, **options, &block)
      render "components/toast",
        variant: variant,
        title: title,
        description: description,
        **options,
        &block
    end

    # Render a success toast
    #
    # @param title [String] Toast title
    # @param options [Hash] Additional options
    # @return [String] HTML-safe toast element
    def toast_success(title, **options, &block)
      toast(:success, title, **options, &block)
    end

    # Render an error toast
    #
    # @param title [String] Toast title
    # @param options [Hash] Additional options
    # @return [String] HTML-safe toast element
    def toast_error(title, **options, &block)
      toast(:error, title, **options, &block)
    end

    # Render a warning toast
    #
    # @param title [String] Toast title
    # @param options [Hash] Additional options
    # @return [String] HTML-safe toast element
    def toast_warning(title, **options, &block)
      toast(:warning, title, **options, &block)
    end

    # Render an info toast
    #
    # @param title [String] Toast title
    # @param options [Hash] Additional options
    # @return [String] HTML-safe toast element
    def toast_info(title, **options, &block)
      toast(:info, title, **options, &block)
    end

    private

    # Convert flash type to toast variant
    #
    # @param type [String, Symbol] Flash type
    # @return [Symbol] Toast variant
    def flash_to_variant(type)
      FLASH_VARIANTS[type.to_sym] || :default
    end
  end
end
