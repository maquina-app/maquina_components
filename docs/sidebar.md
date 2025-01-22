# Sidebar

> A composable, themeable sidebar component with collapsible states, mobile responsiveness, and keyboard shortcuts.

---

## Quick Reference

### Parts

| Partial | Purpose | Required |
|---------|---------|----------|
| `sidebar/provider` | Wraps entire layout, manages state | Yes |
| `sidebar` | Main sidebar container | Yes |
| `sidebar/header` | Top section (logo, branding) | No |
| `sidebar/content` | Scrollable middle section | Yes |
| `sidebar/footer` | Bottom section (user menu) | No |
| `sidebar/group` | Groups menu items with optional label | No |
| `sidebar/menu` | List container for menu items | Yes |
| `sidebar/menu_item` | Individual menu item wrapper | Yes |
| `sidebar/menu_button` | Icon + text navigation link | Yes* |
| `sidebar/menu_link` | Avatar style navigation link | Yes* |
| `sidebar/trigger` | Toggle button for sidebar | Yes |
| `sidebar/inset` | Main content area wrapper | No |

*Use either `menu_button` or `menu_link` for each item

### Helper Methods

| Method | Description |
|--------|-------------|
| `sidebar_state(cookie_name)` | Returns `:expanded` or `:collapsed` |
| `sidebar_open?(cookie_name)` | Returns `true` if expanded |
| `sidebar_closed?(cookie_name)` | Returns `true` if collapsed |

### Parameters

#### Provider

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `default_open` | Boolean | `true` | Initial open state |
| `variant` | Symbol | `:inset` | Visual variant |
| `cookie_name` | String | `"sidebar_state"` | Cookie for persistence |
| `keyboard_shortcut` | String | `"b"` | Toggle shortcut (Cmd/Ctrl+key) |
| `css_classes` | String | `""` | Additional CSS classes |
| `**html_options` | Hash | `{}` | Additional HTML attributes |

#### Sidebar

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `id` | String | auto | Element ID |
| `state` | Symbol | `:collapsed` | Initial state (`:expanded`/`:collapsed`) |
| `collapsible` | Symbol | `:offcanvas` | Collapse mode |
| `variant` | Symbol | `:inset` | Visual variant |
| `side` | Symbol | `:left` | Sidebar position |
| `css_classes` | String | `""` | Additional CSS classes |
| `**html_options` | Hash | `{}` | Additional HTML attributes |

### Variants

| Variant | Description |
|---------|-------------|
| `:sidebar` | Standard sidebar with border |
| `:floating` | Floating with rounded corners and shadow |
| `:inset` | Inset within content area, locked to viewport height |

### Collapsible Modes

| Mode | Description |
|------|-------------|
| `:offcanvas` | Slides off screen when collapsed (mobile default) |
| `:icon` | Collapses to icon-only width |
| `:none` | Always visible, no collapse |

### Data Attributes

**Component Identifiers**

| Attribute | Element | Description |
|-----------|---------|-------------|
| `data-component="sidebar"` | Aside element | Main sidebar component |
| `data-sidebar-part="root"` | Provider wrapper | Root container with state |
| `data-sidebar-part="container"` | Fixed wrapper | Fixed position container |
| `data-sidebar-part="inner"` | Inner wrapper | Inner container for styling |
| `data-sidebar-part="header"` | Header section | Top section (logo/branding) |
| `data-sidebar-part="content"` | Content section | Scrollable middle section |
| `data-sidebar-part="footer"` | Footer section | Bottom section (user menu) |
| `data-sidebar-part="group"` | Group wrapper | Menu group container |
| `data-sidebar-part="group-label"` | Group label | Optional group title |
| `data-sidebar-part="menu"` | Menu list | `<ul>` container |
| `data-sidebar-part="menu-item"` | Menu item | `<li>` wrapper |
| `data-sidebar-part="menu-button"` | Menu button | Icon+text link style |
| `data-sidebar-part="menu-link"` | Menu link | Avatar/branding link style |
| `data-sidebar-part="inset"` | Inset | Main content area |
| `data-sidebar-part="trigger"` | Trigger | Toggle button |
| `data-sidebar-part="backdrop"` | Backdrop | Mobile overlay |

**State Attributes**

| Attribute | Values | Description |
|-----------|--------|-------------|
| `data-state` | `expanded`, `collapsed`, `open`, `visible` | Sidebar open/closed state |
| `data-side` | `left`, `right` | Sidebar position |
| `data-variant` | `sidebar`, `floating`, `inset` | Visual variant |
| `data-collapsible` | `offcanvas`, `icon`, `none` | Collapse mode |
| `data-active` | `true` | Active menu item |

**Stimulus Attributes**

| Attribute | Description |
|-----------|-------------|
| `data-controller="sidebar"` | Main sidebar controller |
| `data-controller="sidebar-trigger"` | Trigger button controller |
| `data-sidebar-outlet` | Outlet reference to sidebar controller |

---

## Critical Architecture

### Provider Must Wrap Both Sidebar AND Content

The `sidebar/provider` component **must wrap both the sidebar AND main content**. This is essential for:

1. **Stimulus Outlets:** The trigger controller uses outlets to find the sidebar controller
2. **CSS Peer Selectors:** Collapsed state styling uses `[data-state="collapsed"] ~ [data-sidebar-part="inset"]` selectors
3. **State Synchronization:** The provider manages state for all children

```erb
<%%# CORRECT: Provider wraps everything %>
<%%= render "components/sidebar/provider", default_open: sidebar_open? do %>
  <%%= render "components/sidebar", state: sidebar_state do %>
    <!-- sidebar content -->
  <%% end %>

  <%%= render "components/sidebar/inset" do %>
    <!-- main content responds to sidebar state -->
  <%% end %>
<%% end %>

<%%# WRONG: Content outside provider %>
<%%= render "components/sidebar/provider" do %>
  <%%= render "components/sidebar" do %>
    <!-- sidebar content -->
  <%% end %>
<%% end %>
<%%= render "components/sidebar/inset" do %>
  <!-- WON'T respond to sidebar state changes! -->
<%% end %>
```

### Stimulus Initialization Required

The sidebar requires Stimulus to be properly initialized. If the trigger doesn't work:

```javascript
// app/javascript/application.js
import "@hotwired/turbo-rails"
import { Application } from "@hotwired/stimulus"
import { eagerLoadControllersFrom } from "@hotwired/stimulus-loading"

const application = Application.start()
application.debug = false
window.Stimulus = application

eagerLoadControllersFrom("controllers", application)
```

Ensure your `importmap.rb` pins the required packages:

```ruby
# config/importmap.rb
pin "@hotwired/turbo-rails", to: "turbo.min.js"
pin "@hotwired/stimulus", to: "stimulus.min.js"
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js"
```

---

## Basic Usage

### Layout Structure

```erb
<%%= render "components/sidebar/provider", default_open: sidebar_open? do %>
  <%%= render "components/sidebar", state: sidebar_state do %>
    <%%= render "components/sidebar/header" do %>
      <!-- Logo/branding -->
    <%% end %>

    <%%= render "components/sidebar/content" do %>
      <!-- Navigation groups -->
    <%% end %>

    <%%= render "components/sidebar/footer" do %>
      <!-- User menu -->
    <%% end %>
  <%% end %>

  <%%= render "components/sidebar/inset" do %>
    <!-- Main content -->
  <%% end %>
<%% end %>
```

### Menu Structure

```erb
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
      
      <%%= render "components/sidebar/menu_item" do %>
        <%%= render "components/sidebar/menu_button",
          title: "Settings",
          icon_name: :settings,
          url: settings_path %>
      <%% end %>
    <%% end %>
  <%% end %>
<%% end %>
```

---

## Examples

### Menu Button vs Menu Link

**Menu Button** — Icon + text style, compact:

```erb
<%%= render "components/sidebar/menu_button",
  title: "Dashboard",
  icon_name: :home,
  url: root_path,
  size: :default,
  active: true %>
```

**Menu Link** — Avatar/branding style, larger:

```erb
<%%= render "components/sidebar/menu_link",
  url: root_path,
  text_icon: "A",
  title: "Company Name",
  subtitle: "Workspace",
  icon_classes: "font-bold text-lg" %>
```

Or with an image:

```erb
<%%= render "components/sidebar/menu_link",
  url: profile_path,
  icon: user.avatar_url,
  title: user.name,
  subtitle: user.email %>
```

### Multiple Groups

```erb
<%%= render "components/sidebar/content" do %>
  <%%= render "components/sidebar/group", title: "Main" do %>
    <%%= render "components/sidebar/menu" do %>
      <!-- Primary navigation -->
    <%% end %>
  <%% end %>

  <%%= render "components/sidebar/group", title: "Settings" do %>
    <%%= render "components/sidebar/menu" do %>
      <!-- Settings links -->
    <%% end %>
  <%% end %>
<%% end %>
```

### Groups Without Labels

```erb
<%%= render "components/sidebar/group" do %>
  <%%= render "components/sidebar/menu" do %>
    <!-- Menu items without a group label -->
  <%% end %>
<%% end %>
```

---

## Real-World Patterns

### Full Application Layout

```erb
<!DOCTYPE html>
<html>
  <head>
    <title><%%= content_for(:title) || "App" %></title>
    <%%= stylesheet_link_tag "application" %>
    <%%= javascript_importmap_tags %>
  </head>

  <body class="overflow-hidden bg-background">
    <%%= render "components/sidebar/provider",
      default_open: sidebar_open?,
      variant: :inset do %>
      
      <%%= render "components/sidebar",
        state: sidebar_state,
        variant: :inset,
        side: :left do %>
        
        <%%= render "components/sidebar/header" do %>
          <%%= render "components/sidebar/menu" do %>
            <%%= render "components/sidebar/menu_item" do %>
              <%%= render "components/sidebar/menu_link",
                url: root_path,
                text_icon: "A",
                title: "ACME",
                subtitle: "Dashboard" %>
            <%% end %>
          <%% end %>
        <%% end %>

        <%%= render "components/sidebar/content" do %>
          <%%= render "components/sidebar/group", title: "Main" do %>
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
          <%%= render "components/sidebar/menu" do %>
            <%%= render "components/sidebar/menu_item" do %>
              <%%= render "components/sidebar/menu_link",
                url: profile_path,
                icon: current_user.avatar_url,
                title: current_user.name,
                subtitle: current_user.email %>
            <%% end %>
          <%% end %>
        <%% end %>
      <%% end %>

      <%%= render "components/sidebar/inset" do %>
        <%%= render "components/header" do %>
          <%%= render "components/sidebar/trigger", icon_name: :menu %>
          <%%= render "components/separator", orientation: :vertical %>
          <!-- Breadcrumbs, etc. -->
        <%% end %>

        <div class="flex-1 overflow-y-auto">
          <%%= yield %>
        </div>
      <%% end %>
    <%% end %>
  </body>
</html>
```

### Content Scrolling (Inset Variant)

The inset variant locks the layout to viewport height (`h-svh`). To create a **sticky header with scrollable content**:

```erb
<%%= render "components/sidebar/inset" do %>
  <%%= render "components/header" do %>
    <%%= render "components/sidebar/trigger", icon_name: :menu %>
    <!-- Header content stays fixed -->
  <%% end %>

  <div class="flex-1 overflow-y-auto">
    <%%= yield %>
  </div>
<%% end %>
```

### Custom Cookie Name

```ruby
# app/helpers/application_helper.rb
SIDEBAR_COOKIE_NAME = "myapp_sidebar"

def app_sidebar_open?
  sidebar_open?(SIDEBAR_COOKIE_NAME)
end

def app_sidebar_state
  sidebar_state(SIDEBAR_COOKIE_NAME)
end
```

```erb
<%%= render "components/sidebar/provider",
  default_open: app_sidebar_open?,
  cookie_name: "myapp_sidebar" do %>
  <%%= render "components/sidebar", state: app_sidebar_state do %>
    <!-- ... -->
  <%% end %>
<%% end %>
```

---

## Theme Variables

```css
:root {
  /* Dimensions */
  --sidebar-width: 16rem;
  --sidebar-width-mobile: 18rem;
  --sidebar-width-icon: 3rem;

  /* Colors */
  --sidebar: oklch(0.96 0 0);
  --sidebar-foreground: oklch(0.2 0 0);
  --sidebar-primary: oklch(21.03% 0.006 285.88);
  --sidebar-primary-foreground: oklch(98.48% 0 0);
  --sidebar-accent: oklch(0.9 0 0);
  --sidebar-accent-foreground: oklch(0.145 0 0);
  --sidebar-border: oklch(0.88 0 0);
  --sidebar-ring: oklch(62.32% 0.19 259.8);
}

.dark {
  --sidebar: oklch(0.14 0 0);
  --sidebar-foreground: oklch(0.9 0 0);
  --sidebar-primary: oklch(90% 0.01 260);
  --sidebar-primary-foreground: oklch(15% 0.01 260);
  --sidebar-accent: oklch(0.22 0 0);
  --sidebar-accent-foreground: oklch(0.95 0 0);
  --sidebar-border: oklch(0.25 0 0);
  --sidebar-ring: oklch(60% 0.15 260);
}
```

---

## Customization

### Custom Width

```erb
<%%= render "components/sidebar/provider",
  css_classes: "[--sidebar-width:20rem]" do %>
  <!-- ... -->
<%% end %>
```

### Custom Keyboard Shortcut

```erb
<%%= render "components/sidebar/provider",
  keyboard_shortcut: "s" do %>
  <!-- Cmd/Ctrl+S toggles sidebar -->
<%% end %>
```

### Right-Side Sidebar

```erb
<%%= render "components/sidebar", side: :right do %>
  <!-- ... -->
<%% end %>
```

### Custom Collapsed State Styles

When the sidebar collapses, use CSS with the data-state selector:

```css
/* Hide element when collapsed */
[data-state="collapsed"] ~ [data-sidebar-part="inset"] .show-when-expanded {
  display: none;
}
```

---

## Troubleshooting

### Trigger Doesn't Work

1. Stimulus is initialized correctly
2. Provider wraps both sidebar AND content
3. No JavaScript errors in console
4. Hotwire gems are in Gemfile

### Collapsed Styles Don't Apply

1. Provider wraps both sidebar AND content
2. CSS selectors use `[data-state="collapsed"] ~` pattern
3. Custom elements are inside `sidebar/inset`

### Cookie Not Persisting

1. `cookie_name` matches between provider and helper calls
2. Cookies are enabled in browser
3. No JavaScript errors preventing Stimulus from running

---

## Accessibility

- **Keyboard Navigation:** Cmd/Ctrl+B (configurable) toggles sidebar
- **Focus Management:** Focus trapped in sidebar when modal on mobile
- **ARIA:** Semantic `<aside>`, `<nav>`, `<ul>/<li>` structure
- **Screen Reader:** `.sr-only` labels on icon-only elements
- **Scroll Lock:** Body scroll locked when mobile sidebar open

---

## File Structure

```
app/
├── assets/stylesheets/
│   └── sidebar.css
├── helpers/maquina_components/
│   └── sidebar_helper.rb
├── javascript/controllers/
│   ├── sidebar_controller.js
│   └── sidebar_trigger_controller.js
└── views/components/
    ├── _sidebar.html.erb
    └── sidebar/
        ├── _provider.html.erb
        ├── _header.html.erb
        ├── _content.html.erb
        ├── _footer.html.erb
        ├── _group.html.erb
        ├── _menu.html.erb
        ├── _menu_item.html.erb
        ├── _menu_button.html.erb
        ├── _menu_link.html.erb
        ├── _trigger.html.erb
        └── _inset.html.erb
```

---

## Migration Notes

### From Previous Version

**Changed:**
- All inline Tailwind moved to `sidebar.css`
- Data attributes standardized: `data-sidebar-part="..."`
- All partials now accept `css_classes:` and `**html_options`
- Inset variant now uses `h-svh` for viewport-locked layouts

**Breaking Changes:**
- `size:` on `menu_link` removed (always `lg`)
- Group `title_action` removed — use separate action partial
- Inline classes no longer work — use CSS customization
