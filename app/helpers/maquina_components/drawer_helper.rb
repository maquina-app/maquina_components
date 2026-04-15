module MaquinaComponents
  module DrawerHelper
    def drawer_state(cookie_name = "drawer_state")
      cookie_value = cookies[cookie_name]

      return :open if cookie_value.nil?

      (cookie_value == "true") ? :open : :closed
    end

    def drawer_open?(cookie_name = "drawer_state")
      drawer_state(cookie_name) == :open
    end

    def drawer_closed?(cookie_name = "drawer_state")
      drawer_state(cookie_name) == :closed
    end
  end
end
