module MaquinaComponents
  module SidebarHelper
    # Get sidebar state from cookie
    #
    # Reads the sidebar state cookie and returns a String.
    # Use this to set the state value in the sidebar
    # to ensure server-rendered state matches client state.
    #
    # @param cookie_name [String] The cookie name (default: "sidebar_state")
    # @return [String] expanded if sidebar should be open, collapsed otherwise
    #
    # @example In layout
    #   <%= render "components/sidebar",
    #     state: sidebar_state do %>
    #     <!-- content -->
    #   <% end %>
    #
    # @example With custom cookie name
    #   <%= render "components/sidebar",
    #     state: sidebar_state("custom_sidebar_cookie") do %>
    #     <!-- content -->
    #   <% end %>
    #
    def sidebar_state(cookie_name = "sidebar_state")
      # Read cookie value
      cookie_value = cookies[cookie_name]

      # Default to expanded when no cookie exists
      return :expanded if cookie_value.nil?

      # Return expanded if cookie says "true", otherwise collapsed
      (cookie_value == "true") ? :expanded : :collapsed
    end

    # Check if sidebar is currently open
    #
    # @param cookie_name [String] The cookie name (default: "sidebar_state")
    # @return [Boolean] true if sidebar is open
    #
    # @example
    #   <% if sidebar_open? %>
    #     <!-- Show sidebar-specific content -->
    #   <% end %>
    #
    def sidebar_open?(cookie_name = "sidebar_state")
      sidebar_state(cookie_name) == :expanded
    end

    # Check if sidebar is currently closed
    #
    # @param cookie_name [String] The cookie name (default: "sidebar_state")
    # @return [Boolean] true if sidebar is closed
    #
    # @example
    #   <% if sidebar_closed? %>
    #     <!-- Show expanded content when sidebar is closed -->
    #   <% end %>
    #
    def sidebar_closed?(cookie_name = "sidebar_state")
      sidebar_state(cookie_name) == :collapsed
    end
  end
end
