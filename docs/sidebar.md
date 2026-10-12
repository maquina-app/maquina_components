# Sidebar

> A composable sidebar component with collapsible states and mobile responsiveness.

<!-- preview:default height:420 -->

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

### Menu Badge and Menu Action

Both pin to the right edge of the menu item, so they must be rendered **inside**
`menu_item`, as siblings of the `menu_button` (or `menu_link`). That nesting is
load-bearing: the item is the positioning context, and a menu item containing an
action automatically reserves right-hand padding on its button so the icon never
sits on top of the label.

```erb
<%%= render "components/sidebar/menu_item" do %>
  <%%= render "components/sidebar/menu_button",
    title: "Inbox", icon_name: :inbox, url: inbox_path %>
  <%%= render "components/sidebar/menu_badge", text: "24" %>
  <%%= render "components/sidebar/menu_action",
    label: "Inbox options",
    icon_name: :ellipsis,
    show_on_hover: true %>
<%% end %>
```

`menu_action` renders a `<button type="button">` by default and an `<a>` when
you pass `url:`. It is icon-only, so `label:` is required — it becomes both the
`aria-label` and screen-reader text. `show_on_hover: true` keeps the action
invisible until the item is hovered or focused.

### Group Action

```erb
<%%= render "components/sidebar/group", title: "Projects" do %>
  <%%= render "components/sidebar/group_action",
    label: "Add project", url: new_project_path %>

  <%%= render "components/sidebar/menu" do %>
    <%# … %>
  <%% end %>
<%% end %>
```

### Separator

```erb
<%%= render "components/sidebar/separator" %>
```

Renders the separator primitive, so it keeps the primitive's 1px track while the
sidebar part re-spaces it and swaps in the sidebar's own border token.

## API Reference

### Provider

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| id | String | "sidebar-provider" | Element ID for stable morph matching |
| default_open | Boolean | true | Initial open state |
| variant | Symbol | :inset | Visual variant; match the sidebar's `variant:` |
| cookie_name | String | "sidebar_state" | Cookie for persistence |
| keyboard_shortcut | String | "b" | Toggle shortcut (Cmd/Ctrl+key) |
| css_classes | String | "" | Additional CSS classes |
| html_options | Hash | {} | Additional HTML attributes |

### Sidebar

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| id | String | "sidebar-#{side}" | Element ID; sub-elements get `-gap`, `-overlay`, `-container`, `-inner` suffixes |
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
| active | Boolean | false | Sets `data-active="true"` and `aria-current="page"` |
| css_classes | String | "" | Additional CSS classes |
| html_options | Hash | {} | Additional HTML attributes |

### Menu Link

Renders an `<a>` with an optional avatar (image or text) and a title/subtitle
stack. The text stack carries `data-sidebar-hide-on-collapse`, so it disappears
when the sidebar collapses to icons.

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| url | String | "#" | Link URL |
| title | String | nil | Primary text |
| subtitle | String | nil | Secondary text |
| icon | String | nil | Image path/URL for the avatar (rendered with `image_tag`) |
| text_icon | String | nil | Text for the avatar, used when `icon` is blank |
| icon_classes | String | "" | Classes for the avatar image or text span |
| active | Boolean | false | Sets `data-active="true"` and `aria-current="page"` |
| css_classes | String | "" | Additional CSS classes |
| html_options | Hash | {} | Additional HTML attributes |

### Menu Badge

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| text | String | nil | Badge text |
| content | String | nil | HTML content via `capture`, or use block |
| css_classes | String | "" | Additional CSS classes |
| html_options | Hash | {} | Additional HTML attributes |

### Menu Action

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| label | String | required | `aria-label` and screen-reader text |
| url | String | nil | Renders an `<a>` when present, otherwise `<button type="button">` |
| icon_name | Symbol | :ellipsis | Icon name; pass `nil` for no icon |
| show_on_hover | Boolean | false | Hidden until the menu item is hovered or focused |
| css_classes | String | "" | Additional CSS classes |
| html_options | Hash | {} | Additional HTML attributes |

### Group

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| title | String | nil | Renders a `group-label` when present |
| css_classes | String | "" | Additional CSS classes |
| html_options | Hash | {} | Additional HTML attributes |

### Group Action

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| label | String | required | `aria-label` and screen-reader text |
| url | String | nil | Renders an `<a>` when present, otherwise `<button type="button">` |
| icon_name | Symbol | :ellipsis | Icon name; pass `nil` for no icon |
| css_classes | String | "" | Additional CSS classes |
| html_options | Hash | {} | Additional HTML attributes |

### Separator

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| orientation | Symbol | :horizontal | Passed to the separator primitive |
| css_classes | String | "" | Additional CSS classes |
| html_options | Hash | {} | Additional HTML attributes |

### Trigger

Renders a `<button>` with the `sidebar-trigger` controller and an sr-only
"Toggle Sidebar" label. It can sit anywhere on the page.

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| icon_name | Symbol | :left_panel | Icon name for toggle button |
| css_classes | String | "" | Additional CSS classes |
| html_options | Hash | {} | Additional HTML attributes |

### Other Parts

These take only `css_classes:` and `**html_options`, and yield a block.

| Partial | Element | Description |
|---------|---------|-------------|
| sidebar/header | `<div>` | Top section for logo/branding |
| sidebar/content | `<div>` | Scrollable middle section |
| sidebar/footer | `<div>` | Bottom section for user menu |
| sidebar/menu | `<ul>` | List container for menu items |
| sidebar/menu_item | `<li>` | Individual menu item wrapper; positioning context for badge and action |
| sidebar/inset | `<main>` | Main content area wrapper |

### Variants

Set `variant:` on both the provider and the sidebar.

| Variant | Description |
|---------|-------------|
| :sidebar | Plain sidebar flush against the edge |
| :floating | Inner panel gets a border, radius and shadow |
| :inset | Main content (`sidebar/inset`) is inset inside the sidebar background (default) |

### Menu Button Sizes

| Size | Description |
|------|-------------|
| :default | `h-8` (default) |
| :sm | `h-7`, `text-xs` |
| :lg | `h-12`, for two-line content |

### Helper Methods

| Method | Description |
|--------|-------------|
| sidebar_state(cookie_name = "sidebar_state") | Returns `:expanded` or `:collapsed` from the cookie; `:expanded` when no cookie exists |
| sidebar_open?(cookie_name = "sidebar_state") | Returns true if expanded |
| sidebar_closed?(cookie_name = "sidebar_state") | Returns true if collapsed |

## Stimulus Controllers

### sidebar

Attached to `sidebar/provider` (which also carries `data-outlet="sidebar"`).

| Value | Type | Default | Description |
|-------|------|---------|-------------|
| open | Boolean | true | Current state (the provider renders it from `default_open`) |
| defaultOpen | Boolean | true | Fallback when no cookie exists |
| cookieName | String | "sidebar_state" | Cookie that persists the desktop state |
| cookieMaxAge | Number | 31536000 | Cookie lifetime in seconds (one year) |
| keyboardShortcut | String | "b" | Key used with Cmd/Ctrl |

| Target | Element |
|--------|---------|
| sidebar | The `<aside>` rendered by `components/sidebar` |
| container | The fixed sidebar container (receives `inert` when off-canvas) |
| backdrop | Mobile overlay |

| Action | Description |
|--------|-------------|
| toggle / open / close | Change the open state |
| toggleMobile | Toggle only below 768px |
| toggleWithKeyboard | Bound by the provider to `keydown.meta+<key>@window` and `keydown.ctrl+<key>@window` |
| backdropClick | Closes the sidebar on mobile; bound on the backdrop |

The controller dispatches `sidebar:stateChanged` (bubbling) with
`detail: { open, mobile, state, collapsible }` whenever the state changes. It's also dispatched after every page morph, so listeners can re-sync. Below
768px the sidebar starts closed and its state is not written to the cookie.

### sidebar-trigger

Attached to `sidebar/trigger`. It uses a `sidebar` outlet
(`data-sidebar-trigger-sidebar-outlet="[data-outlet='sidebar']"`) and exposes one
action, `triggerClick`, which toggles every connected sidebar. It listens for
`sidebar:stateChanged` to keep `aria-expanded` in sync, and sets
`aria-controls` to the sidebar's id.

## Turbo Drive

The sidebar controller integrates with Turbo Drive to maintain correct state across navigations:

- **Cache teardown:** When you navigate to another page on mobile, the sidebar closes and the backdrop is hidden before Turbo caches the page, so pressing back never shows a stale open sidebar or a scroll-locked body.
- **Page refreshes keep the sidebar open:** A page refresh is a same-path `replace` visit. That includes `Turbo.visit(location.href, { action: "replace" })`, refresh broadcasts (`broadcasts_refreshes`, `turbo_stream.refresh`) and form redirects back to the same URL. With `turbo_refresh_method_tag :morph`, the sidebar keeps its live state through it: a sidebar you opened on mobile stays open, with its backdrop, scroll lock and the trigger's `aria-expanded`. On desktop it re-reads the cookie, as before.
- **Morph-safe attributes:** The morph doesn't overwrite the attributes the controller owns (`data-sidebar-open-value` on the provider; `data-state` and `data-collapsible` on the sidebar; `data-state` and `class` on the backdrop; `inert` on the container; `aria-expanded` and `aria-controls` on the trigger). The menu contents still morph normally.
- **Breakpoint crossing:** Resizing from desktop into the mobile range closes the sidebar, whatever its state. Resizing back restores the saved desktop state.
- **Desktop persistence:** The sidebar state is stored in a cookie, so it survives full page loads and Turbo navigations without extra configuration.

## Accessibility

- **A collapsed off-canvas sidebar is out of the tab order.** When it is parked
  off-screen, its container carries `inert`, so keyboard focus skips it entirely
  rather than walking through a screenful of destinations no pointer can reach.
  It is applied server-side as well as by the controller, so the invariant holds
  before Stimulus connects. A `collapsible: :icon` sidebar is a visible rail and
  stays reachable; an open sidebar obviously does too.
- **Below 768px the sidebar reserves no layout.** The container is a fixed
  overlay with a backdrop at that width, so the gap that normally holds space for
  it collapses to zero — structurally, in CSS, whatever the state cookie says and
  before any JavaScript has run. A phone load carrying an expanded cookie gets a
  full-width content column in the first painted frame, with no settle.
- Sidebar items expose `aria-current="page"` when active, and the trigger keeps
  `aria-expanded` and `aria-controls` in sync with the sidebar it drives.

### Stable IDs

The sidebar generates deterministic IDs based on its `side:` parameter (`sidebar-left`, `sidebar-right`) instead of random IDs. This allows idiomorph to match old and new elements across morph renders, preventing the sidebar from being destroyed and recreated.

The provider div also receives a stable ID (`sidebar-provider`) for the same reason.

If you render multiple sidebars on the same side, pass explicit `id:` parameters to avoid collisions:

```erb
<%%= render "components/sidebar/provider", id: "sidebar-main" do %>
  <%%= render "components/sidebar", id: "sidebar-nav", side: :left do %>
    ...
  <%% end %>
<%% end %>
```

### Morph Compatibility

During a Turbo morph, the server-rendered `data-sidebar-open-value` may carry a stale value (e.g., from a broadcast where the server has no access to the browser cookie). The controller treats the browser cookie as the source of truth:

1. Before morph updates attributes, the controller sets an internal guard flag.
2. When idiomorph overwrites `data-sidebar-open-value`, the Stimulus value callback is skipped — preventing the stale server value from overwriting the cookie.
3. After morph completes, the controller reads the cookie, reasserts the correct state, and removes the `sidebar-loading` class that morph re-adds from server HTML.

### Turbo Frames

The sidebar works inside Turbo Frames because stable IDs enable clean Stimulus disconnect/reconnect cycles. On reconnection, `initialize()` re-reads the cookie, so the sidebar always reflects the latest client-side state.
