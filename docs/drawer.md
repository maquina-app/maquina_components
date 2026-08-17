# Drawer

> A slide-out drawer panel component with overlay and persistence.

<!-- preview:default height:280 -->

## Usage

```erb
<%%= render "components/drawer/provider", default_open: drawer_open? do %>
  <%%= render "components/drawer", state: drawer_state do %>
    <%%= render "components/drawer/header" do %>
      <%%= render "components/drawer/title", text: "Drawer Title" %>
      <%%= render "components/drawer/close" %>
    <%% end %>

    <%%= render "components/drawer/content" do %>
      <!-- Drawer content -->
    <%% end %>

    <%%= render "components/drawer/footer" do %>
      <!-- Footer actions -->
    <%% end %>
  <%% end %>
<%% end %>
```

## Examples

### With Trigger

```erb
<%%= render "components/drawer/trigger" %>

<%%= render "components/drawer/provider" do %>
  <%%= render "components/drawer" do %>
    <!-- content -->
  <%% end %>
<%% end %>
```

### Sections and Separators

Group the drawer body into stacked sections, divided by a separator.

```erb
<%%= render "components/drawer/content" do %>
  <%%= render "components/drawer/section" do %>
    <%%= render "components/drawer/title", text: "Filters", tag: :h3 %>
  <%% end %>

  <%%= render "components/drawer/separator" %>

  <%%= render "components/drawer/section" do %>
    <%# More rows %>
  <%% end %>
<%% end %>
```

`drawer/separator` renders the separator primitive, so it keeps the primitive's
1px track while the drawer part re-spaces it for the panel.

### Left Side Drawer

```erb
<%%= render "components/drawer", side: :left do %>
  <!-- content -->
<%% end %>
```

## API Reference

### Provider

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| id | String | "drawer-provider" | Element ID for stable morph matching |
| default_open | Boolean | false | Initial open state |
| cookie_name | String | "drawer_state" | Cookie for persistence |
| keyboard_shortcut | String | "d" | Toggle shortcut (Cmd/Ctrl+key) |
| css_classes | String | "" | Additional CSS classes |
| html_options | Hash | {} | Additional HTML attributes |

### Drawer

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| id | String | auto | Element ID |
| state | Symbol | :closed | :open or :closed |
| side | Symbol | :right | :left or :right |
| aria_label | String | "Drawer" | Accessible name for the dialog panel |
| css_classes | String | "" | Additional CSS classes |
| html_options | Hash | {} | Additional HTML attributes |

### Trigger

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| icon_name | Symbol | :panel_right_open | Icon name for toggle button |
| css_classes | String | "" | Additional CSS classes |
| html_options | Hash | {} | Additional HTML attributes |

### Other Parts

| Partial | Description |
|---------|-------------|
| drawer/header | Top section with title and close button |
| drawer/title | Heading inside the header. `text:` / `content:` / block, `tag:` (default `:h2`) |
| drawer/description | Supporting line under the title. `text:` / `content:` / block, `tag:` (default `:p`) |
| drawer/content | Scrollable middle section |
| drawer/footer | Bottom section for actions |
| drawer/section | Groups related rows inside the content area. Container — pass a block |
| drawer/separator | Divider between sections. `orientation:` (default `:horizontal`) |
| drawer/trigger | Toggle button for drawer |
| drawer/close | Close button (X icon) |

### Helper Methods

| Method | Description |
|--------|-------------|
| drawer_state(cookie_name) | Returns :open or :closed |
| drawer_open?(cookie_name) | Returns true if open |
| drawer_closed?(cookie_name) | Returns true if closed |

## Turbo Drive

The drawer controller integrates with Turbo Drive to maintain correct state across navigations:

- **Cache teardown:** The drawer closes and the backdrop is hidden before Turbo caches the page.
- **Morph awareness:** When using `turbo_refresh_method_tag :morph`, the drawer re-reads its cookie to preserve toggle state.
- **Persistence:** The drawer state is stored in a cookie, so it survives full page loads and Turbo navigations.