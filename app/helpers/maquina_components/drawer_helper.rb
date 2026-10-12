module MaquinaComponents
  module DrawerHelper
    # The drawer's persisted state. A missing cookie means :closed, matching the
    # provider's default_open: false and the controller's default.
    def drawer_state(cookie_name = "drawer_state")
      (cookies[cookie_name] == "true") ? :open : :closed
    end

    def drawer_open?(cookie_name = "drawer_state")
      drawer_state(cookie_name) == :open
    end

    def drawer_closed?(cookie_name = "drawer_state")
      drawer_state(cookie_name) == :closed
    end
  end
end
