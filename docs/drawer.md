# Drawer

> A slide-out drawer panel component with overlay and persistence.

<!-- preview:default height:280 -->

## Usage

```erb
<%%= render "components/drawer/provider" do %>
  <%%= render "components/drawer/trigger" do %>Open Drawer<%% end %>

  <%%= render "components/drawer" do %>
    <%%= render "components/drawer/header" do %>
      <%%= render "components/drawer/title", text: "Drawer Title" %>
      <%%= render "components/drawer/description", text: "Supporting text" %>
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

`drawer/header` renders its own close button; pass `show_close: false` to omit it.

## Examples

### With Trigger

The trigger finds its drawer through a Stimulus outlet, so it can live anywhere
on the page — inside or outside the provider.

```erb
<%%= render "components/drawer/trigger", icon_name: :panel_left do %>
  Open Drawer
<%% end %>

<%%= render "components/drawer/provider" do %>
  <%%= render "components/drawer" do %>
    <!-- content -->
  <%% end %>
<%% end %>
```

### Multiple Drawers

By default a trigger controls every drawer on the page. Give each provider a
`name:` and point the trigger at its id with `for_id:`. Each drawer should also
get its own `cookie_name:` and `keyboard_shortcut:`.

```erb
<%%= render "components/drawer/trigger", for_id: "drawer-provider-filters" do %>Filters<%% end %>

<%%= render "components/drawer/provider", name: :filters, cookie_name: "filters_drawer", keyboard_shortcut: "f" do %>
  <%%= render "components/drawer", id: "drawer-filters", aria_label: "Filters" do %>
    <!-- content -->
  <%% end %>
<%% end %>
```

`for_id:` takes a bare id (prefixed with `#`) or any selector starting with `#`,
`[` or `.`, used verbatim.

### Footer Actions

```erb
<%%= render "components/drawer/footer" do %>
  <%%= render "components/drawer/close", show_icon: false, variant: :outline do %>
    Cancel
  <%% end %>
  <button type="button" data-component="button">Save Changes</button>
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

Carries the `drawer` controller and `data-outlet="drawer"`.

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| id | String | "drawer-provider" | Element ID for stable morph matching; `"drawer-provider-#{name}"` when `name:` is given |
| name | String, Symbol | nil | Names the drawer: sets `data-drawer-name` and the default id |
| default_open | Boolean | false | Initial open state when no cookie exists |
| cookie_name | String | "drawer_state" | Cookie for persistence |
| keyboard_shortcut | String | "d" | Toggle shortcut (Cmd/Ctrl+key) |
| css_classes | String | "" | Additional CSS classes |
| html_options | Hash | {} | Additional HTML attributes |

### Drawer

Renders an `<aside>` containing the backdrop and a `role="dialog"`
`aria-modal="true"` panel. A closed drawer's panel is rendered with
`aria-hidden` and `inert`.

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| id | String | "drawer-#{side}" | Element ID; sub-elements get `-backdrop`, `-panel`, `-inner` suffixes |
| state | Symbol | :closed | :open or :closed |
| side | Symbol | :right | :left or :right |
| aria_label | String | "Drawer" | Accessible name for the dialog panel |
| css_classes | String | "" | Additional CSS classes |
| html_options | Hash | {} | Additional HTML attributes |

### Trigger

Renders a `<button data-component="button">` with the `drawer-trigger` controller.

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| icon_name | Symbol | nil | Icon rendered before the block |
| for_id | String | nil | Drawer provider id or selector to control; defaults to every drawer (`[data-outlet='drawer']`). `for:` is accepted as an alias |
| variant | Symbol | :default | Button variant: :default, :outline, :secondary, :ghost, :destructive, :link |
| size | Symbol | :default | Button size: :default, :sm, :lg, :icon |
| css_classes | String | "" | Additional CSS classes |
| html_options | Hash | {} | Additional HTML attributes |

### Header

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| show_close | Boolean | true | Render a `drawer/close` button after the block |
| css_classes | String | "" | Additional CSS classes |
| html_options | Hash | {} | Additional HTML attributes |

### Close

A `<button type="button">` bound to `drawer#close`. It must be inside the provider.
Without `variant:` it is the drawer's small icon button (the one `drawer/header`
renders); with one it renders as a regular button, e.g. a footer "Cancel".

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| show_icon | Boolean | true | Render the X icon before the block |
| variant | Symbol | nil | Render as a `data-component="button"` in this variant (:default, :outline, :secondary, :ghost, :destructive, :link) |
| size | Symbol | nil | Button size when `variant:` is set |
| css_classes | String | "" | Additional CSS classes |
| html_options | Hash | {} | Additional HTML attributes |

### Title / Description

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| text | String | nil | Text content |
| content | String | nil | HTML content via `capture`, or use block |
| tag | Symbol | :h2 (title), :p (description) | Element to render |
| css_classes | String | "" | Additional CSS classes |
| html_options | Hash | {} | Additional HTML attributes |

### Separator

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| orientation | Symbol | :horizontal | Passed to the separator primitive |
| css_classes | String | "" | Additional CSS classes |
| html_options | Hash | {} | Additional HTML attributes |

### Other Parts

These take only `css_classes:` and `**html_options`, and yield a block.

| Partial | Description |
|---------|-------------|
| drawer/content | Scrollable middle section |
| drawer/footer | Bottom section for actions |
| drawer/section | Groups related rows inside the content area |

### Helper Methods

| Method | Description |
|--------|-------------|
| drawer_state(cookie_name = "drawer_state") | Returns `:open` or `:closed` from the cookie. Returns `:closed` when no cookie exists |
| drawer_open?(cookie_name = "drawer_state") | Returns true if open |
| drawer_closed?(cookie_name = "drawer_state") | Returns true if closed |

A missing cookie means `:closed`, matching the provider's `default_open: false`,
so `state: drawer_state` is safe on a first visit. The controller restores the
cookie state on connect either way.

## Stimulus Controllers

### drawer

Attached to `drawer/provider`.

| Value | Type | Default | Description |
|-------|------|---------|-------------|
| open | Boolean | false | Current state (the provider renders it from `default_open`) |
| defaultOpen | Boolean | false | Fallback when no cookie exists |
| cookieName | String | "drawer_state" | Cookie that persists the state |
| cookieMaxAge | Number | 31536000 | Cookie lifetime in seconds (one year) |
| keyboardShortcut | String | "d" | Key used with Cmd/Ctrl |

| Target | Element |
|--------|---------|
| drawer | The `<aside>` rendered by `components/drawer` |
| panel | The dialog panel (focused on open; `aria-hidden` + `inert` when closed) |
| backdrop | The overlay |

| Action | Description |
|--------|-------------|
| toggle / open / close | Change the open state |
| toggleWithKeyboard | Bound by the provider to `keydown.meta+<key>@window` and `keydown.ctrl+<key>@window` |
| closeOnEscape | Bound by the provider to `keydown.esc@window` |
| backdropClick | Closes the drawer; bound on the backdrop |

Opening locks body scroll and moves focus to the panel; closing restores focus
to the element that had it. The controller dispatches `drawer:stateChanged`
(bubbling) with `detail: { open, state }`.

### drawer-trigger

Attached to `drawer/trigger`, with a `drawer` outlet
(`data-drawer-trigger-drawer-outlet`). Its one action, `triggerClick`, toggles
every connected drawer. It sets `aria-haspopup="dialog"`, keeps `aria-expanded`
in sync via `drawer:stateChanged`, and sets `aria-controls` to the panel id(s).

## Turbo Drive

The drawer controller integrates with Turbo Drive to maintain correct state across navigations:

- **Cache teardown:** When you navigate to another page, the drawer closes and the backdrop is hidden before Turbo caches the page.
- **Page refreshes keep the drawer open:** A page refresh is a same-path `replace` visit. That includes `Turbo.visit(location.href, { action: "replace" })`, refresh broadcasts and form redirects back to the same URL. With `turbo_refresh_method_tag :morph`, the drawer keeps its live state through it, including the scroll lock and the trigger's `aria-expanded`.
- **Morph-safe attributes:** The morph doesn't overwrite the attributes the controller owns (`data-drawer-open-value`, the drawer's `data-state`, the backdrop's `data-state` and `class`, the panel's `aria-hidden` and `inert`, and the trigger's `aria-expanded`, `aria-controls` and `aria-haspopup`). The drawer's contents still morph normally.
- **Persistence:** The drawer state is stored in a cookie, so it survives full page loads and Turbo navigations.