# Dropdown Menu

> Displays a menu of actions triggered by a button.

<!-- preview:default height:200 -->

## Usage

```erb
<%%= render "components/dropdown_menu" do %>
  <%%= render "components/dropdown_menu/trigger" do %>Open Menu<%% end %>

  <%%= render "components/dropdown_menu/content" do %>
    <%%= render "components/dropdown_menu/item", href: "#" do %>Profile<%% end %>
    <%%= render "components/dropdown_menu/item", href: "#" do %>Settings<%% end %>
    <%%= render "components/dropdown_menu/separator" %>
    <%%= render "components/dropdown_menu/item", href: "#" do %>Logout<%% end %>
  <%% end %>
<%% end %>
```

## Examples

### With Icons

<!-- preview:with_icons height:240 -->

```erb
<%%= render "components/dropdown_menu/item", href: "#" do %>
  <%%= icon_for :user, class: "size-4" %>
  Profile
<%% end %>
<%%= render "components/dropdown_menu/item", href: "#", variant: :destructive do %>
  <%%= icon_for :log_out, class: "size-4" %>
  Logout
<%% end %>
```

### With Shortcuts

<!-- preview:with_shortcuts height:240 -->

```erb
<%%= render "components/dropdown_menu/item", href: "#" do %>
  Undo
  <%%= render "components/dropdown_menu/shortcut" do %>⌘Z<%% end %>
<%% end %>
```

### Icon Trigger

The default trigger renders its own chevron, which rotates 180° while the menu is
open. Reach for `as_child` when you need different content — an icon-only button,
an `sr-only` label — not merely to get an affordance. Note that `as_child` hands
you the whole button: `data-dropdown-menu-target="trigger"`,
`data-action="dropdown-menu#toggle"`, `aria-haspopup` and `aria-expanded` are all
yours to write. The controller updates `aria-expanded` at runtime, but only if the
attribute is there to begin with.

<!-- preview:icon_trigger height:180 -->

```erb
<%%= render "components/dropdown_menu/trigger", as_child: true do %>
  <button type="button"
          data-component="button"
          data-variant="ghost"
          data-size="icon"
          data-dropdown-menu-target="trigger"
          data-action="dropdown-menu#toggle"
          aria-haspopup="menu"
          aria-expanded="false">
    <%%= icon_for :more_horizontal, class: "size-4" %>
  </button>
<%% end %>
```

## Placement

<!-- preview:placement height:320 -->

Since 0.7.1 the menu measures itself when it opens and flips above the trigger if
it would otherwise open past the bottom of the viewport. It flips only when the
space above genuinely fits — flipping into a gap that is also too small trades
one clipped menu for another — and it re-measures from the placement you asked
for each time, so a menu that flipped in a short window returns to its default
once the window grows.

`side:` is therefore an initial preference rather than a fixed position. The
controller writes the resolved side to `data-side` on the content element, which
is what the CSS positions against. Only the block axis flips; `:left` and
`:right` are left alone.

The menu button behaves the same way. If you carry your own collision or flip
controller, you can delete it — `bin/rails maquina:doctor` reports it as
`app-level-dropdown-flip`.

## API Reference

### Dropdown Menu

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| auto_close | Boolean | false | Close on item click before Turbo navigates |
| css_classes | String | "" | Additional CSS classes |
| html_options | Hash | {} | Additional HTML attributes |

### Dropdown Menu Trigger

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| variant | Symbol | :outline | Button variant when as_child is false |
| size | Symbol | :default | Button size when as_child is false |
| as_child | Boolean | false | Use custom trigger markup |
| css_classes | String | "" | Additional CSS classes |
| html_options | Hash | {} | Additional HTML attributes |

### Dropdown Menu Content

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| align | Symbol | :start | :start, :center, :end |
| side | Symbol | :bottom | :top, :bottom, :left, :right — a preference; see [Placement](#placement) |
| width | Symbol | :default | :default, :sm, :md, :lg |
| css_classes | String | "" | Additional CSS classes |
| html_options | Hash | {} | Additional HTML attributes |

### Dropdown Menu Item

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| href | String | nil | URL, renders link if provided |
| method | Symbol | nil | HTTP method (:delete, :post, etc.) |
| variant | Symbol | :default | :default or :destructive |
| disabled | Boolean | false | Whether disabled |
| css_classes | String | "" | Additional CSS classes |
| html_options | Hash | {} | Additional HTML attributes |

### Dropdown Menu Label

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| text | String | nil | Label text |
| content | String | nil | HTML content via `capture`, or use block |
| inset | Boolean | false | Align with icon items |
| css_classes | String | "" | Additional CSS classes |
| html_options | Hash | {} | Additional HTML attributes |

### Dropdown Menu Separator

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| css_classes | String | "" | Additional CSS classes |
| html_options | Hash | {} | Additional HTML attributes |

### Dropdown Menu Group

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| css_classes | String | "" | Additional CSS classes |
| html_options | Hash | {} | Additional HTML attributes |

### Dropdown Menu Shortcut

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| text | String | nil | Shortcut text |
| content | String | nil | HTML content via `capture`, or use block |
| css_classes | String | "" | Additional CSS classes |
| html_options | Hash | {} | Additional HTML attributes |

## Turbo Drive

The dropdown menu controller automatically resets to a closed state before Turbo caches the page. This prevents stale open menus from appearing when the user navigates back.

### Auto Close for Navigation Menus

When a dropdown contains navigation links, use `auto_close: true` so the menu closes immediately on item click — before Turbo starts navigating:

```erb
<%%= render "components/dropdown_menu", auto_close: true do %>
  <%%= render "components/dropdown_menu/trigger" do %>Navigate<%% end %>

  <%%= render "components/dropdown_menu/content" do %>
    <%%= render "components/dropdown_menu/item", href: dashboard_path do %>Dashboard<%% end %>
    <%%= render "components/dropdown_menu/item", href: settings_path do %>Settings<%% end %>
  <%% end %>
<%% end %>
```

Without `auto_close`, the dropdown stays open during navigation and Turbo may cache the page with it visible. With `auto_close: true`, clicking an item closes the dropdown instantly, so the cached snapshot is always clean.
