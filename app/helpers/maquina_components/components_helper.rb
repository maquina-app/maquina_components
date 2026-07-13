module MaquinaComponents
  # Shared plumbing for component partials.
  module ComponentsHelper
    # Merges a caller's data: hash with a component's own data attributes.
    #
    # Component values win for identity keys (component, variant, size, ...)
    # so callers can't accidentally break a component's styling hooks. The
    # Stimulus token keys :controller and :action concatenate instead, so a
    # caller can attach extra behavior without losing the component's:
    #
    #   <%= render "components/combobox", name: "country",
    #         data: { controller: "analytics", action: "change->analytics#track" } %>
    #   # => data-controller="combobox analytics"
    #
    # @param html_options [Hash] the partial's **html_options (data: is consumed)
    # @param component_data [Hash] the component's own data attributes
    # @return [Hash] the merged data hash
    def merge_component_data(html_options, **component_data)
      user_data = html_options.delete(:data) || {}
      merged = user_data.merge(component_data)

      [:controller, :action].each do |key|
        user_value = user_data[key] || user_data[key.to_s]
        next if user_value.blank? || component_data[key].blank?

        merged.delete(key.to_s)
        merged[key] = "#{component_data[key]} #{user_value}"
      end

      merged
    end
  end
end
