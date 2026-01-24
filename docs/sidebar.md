# Sidebar

> A composable sidebar component with collapsible states and mobile responsiveness.

<!-- preview:default height:280 -->

## Usage

```erb
<%%= render "components/sidebar/provider", default_open: sidebar_open? do %>
  <%%= render "components/sidebar", state: sidebar_state do %>
    <%%= render "components/sidebar/header" do %>
      <%# Logo/branding %>
    <%% end %>

    <%%= render "components/sidebar/content" do %>
      <%%= render "components/sidebar/group", title: "Navigation" do %>
        <%%= render "components/sidebar/menu" do %>
          <%%= render "components/sidebar/menu_item" do %>
            <%%= render "components/sidebar/menu_button",
              title: "Dashboard",
              icon_name: :home,
              url: root_path,
              active: current_page?(root_path) %>
          <%% end %>
        <%% end %>
      <%% end %>
    <%% end %>

    <%%= render "components/sidebar/footer" do %>
      <%# User menu %>
    <%% end %>
  <%% end %>

  <%%= render "components/sidebar/inset" do %>
    <%%= render "components/header" do %>
      <%%= render "components/sidebar/trigger" %>
    <%% end %>
    <%%= yield %>
  <%% end %>
<%% end %>
```

## Examples

### Menu Button

```erb
<%%= render "components/sidebar/menu_button",
  title: "Dashboard",
  icon_name: :home,
  url: root_path,
  active: true %>
```

### Menu Link (Avatar Style)

```erb
<%%= render "components/sidebar/menu_link",
  url: profile_path,
  text_icon: "A",
  title: "ACME Corp",
  subtitle: "Workspace" %>
```

## API Reference

### Provider

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| default_open | Boolean | true | Initial open state |
| variant | Symbol | :inset | Visual variant |
| cookie_name | String | "sidebar_state" | Cookie for persistence |
| keyboard_shortcut | String | "b" | Toggle shortcut (Cmd/Ctrl+key) |
| css_classes | String | "" | Additional CSS classes |
| html_options | Hash | {} | Additional HTML attributes |

### Sidebar

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| id | String | auto | Element ID |
| state | Symbol | :collapsed | :expanded or :collapsed |
| collapsible | Symbol | :offcanvas | :offcanvas, :icon, or :none |
| variant | Symbol | :inset | :sidebar, :floating, or :inset |
| side | Symbol | :left | :left or :right |
| css_classes | String | "" | Additional CSS classes |
| html_options | Hash | {} | Additional HTML attributes |

### Menu Button

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| title | String | required | Button text |
| url | String | required | Link URL |
| icon_name | Symbol | nil | Icon name |
| size | Symbol | :default | :default, :sm, or :lg |
| active | Boolean | false | Whether active |
| css_classes | String | "" | Additional CSS classes |
| html_options | Hash | {} | Additional HTML attributes |

### Menu Link

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| url | String | required | Link URL |
| title | String | required | Primary text |
| subtitle | String | nil | Secondary text |
| text_icon | String | nil | Text for avatar |
| icon | String | nil | Image URL for avatar |
| active | Boolean | false | Whether active |
| css_classes | String | "" | Additional CSS classes |
| html_options | Hash | {} | Additional HTML attributes |

### Other Parts

| Partial | Description |
|---------|-------------|
| sidebar/header | Top section for logo/branding |
| sidebar/content | Scrollable middle section |
| sidebar/footer | Bottom section for user menu |
| sidebar/group | Groups menu items with optional title |
| sidebar/menu | List container for menu items |
| sidebar/menu_item | Individual menu item wrapper |
| sidebar/trigger | Toggle button for sidebar |
| sidebar/inset | Main content area wrapper |

### Helper Methods

| Method | Description |
|--------|-------------|
| sidebar_state(cookie_name) | Returns :expanded or :collapsed |
| sidebar_open?(cookie_name) | Returns true if expanded |
| sidebar_closed?(cookie_name) | Returns true if collapsed |
