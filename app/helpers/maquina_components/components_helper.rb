module MaquinaComponents
  # Shared plumbing for component partials.
  module ComponentsHelper
    # Merges a caller's data: hash with a component's own data attributes.
    #
    # Component values win for the identity keys only — :component, :variant,
    # :size and any *_part key (data-table-part, data-sidebar-part, ...) — so
    # callers can't accidentally break a component's styling hooks. For every
    # other key the caller wins, which is what makes per-instance overrides
    # (a drawer trigger pointing at one specific drawer, an aria hook, a
    # Stimulus value) possible.
    #
    # The Stimulus token keys :controller and :action concatenate instead, so a
    # caller can attach extra behavior without losing the component's:
    #
    #   <%= render "components/combobox", name: "country",
    #         data: { controller: "analytics", action: "change->analytics#track" } %>
    #   # => data-controller="combobox analytics"
    #
    # nil values are dropped, so `active: (active ? true : nil)` renders
    # data-active="true" or no attribute at all rather than "false".
    #
    # @param html_options [Hash] the partial's **html_options (data: is consumed)
    # @param component_data [Hash] the component's own data attributes
    # @return [Hash] the merged data hash
    def merge_component_data(html_options, **component_data)
      user_data = html_options.delete(:data) || {}

      # Caller wins by default; identity keys below are restored afterwards.
      merged = component_data.merge(user_data.symbolize_keys)

      component_data.each_key do |key|
        next unless component_identity_key?(key)

        merged[key] = component_data[key]
      end

      [:controller, :action].each do |key|
        user_value = user_data[key] || user_data[key.to_s]
        next if user_value.blank? || component_data[key].blank?

        merged[key] = "#{component_data[key]} #{user_value}"
      end

      merged.compact
    end

    # Keys a component owns outright: its identity and its styling hooks.
    COMPONENT_IDENTITY_KEYS = [:component, :variant, :size].freeze

    def component_identity_key?(key)
      name = key.to_s
      COMPONENT_IDENTITY_KEYS.include?(name.to_sym) ||
        name.end_with?("_part", "-part")
    end
  end
end
