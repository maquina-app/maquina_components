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

### Using the Helper

```erb
<%%= dropdown_menu do |menu| %>
  <%% menu.trigger { "Options" } %>
  <%% menu.content align: :end, width: :md do |content| %>
    <%% content.label "Actions" %>
    <%% content.item href: edit_project_path(@project) do |item| %>
      <%%= icon_for :pencil %>
      Edit
      <%% item.shortcut "⌘E" %>
    <%% end %>
    <%% content.separator %>
    <%% content.item "Delete", href: project_path(@project), method: :delete, variant: :destructive %>
  <%% end %>
<%% end %>
```

For a flat, data-driven menu:

```erb
<%%= dropdown_menu_simple "Actions", items: [
  { label: "Edit", href: edit_project_path(@project), icon: :pencil },
  { separator: true },
  { label: "Delete", href: project_path(@project), method: :delete, destructive: true }
] %>
```

> `components/dropdown` is **not** an alias of this component. It is the panel
> that pairs with `components/menu_button`; see [Menu Button](menu_button.md).

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

Without `as_child`, renders a `<button data-component="button">` with
`aria-haspopup="menu"`, `aria-expanded="false"`, the controller wiring and a
trailing chevron (`data-dropdown-menu-target="chevron"`). With `as_child: true`,
only the block is rendered — none of that wiring is added.

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

Renders `<a role="menuitem">` when `href` is present, otherwise
`<button type="button" role="menuitem">`.

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| href | String | nil | URL, renders link if provided |
| method | Symbol | nil | Sets `data-turbo-method` (:delete, :post, etc.) |
| variant | Symbol | :default | :default or :destructive |
| disabled | Boolean | false | Sets `aria-disabled="true"`, plus `disabled` on buttons. Disabled items are skipped by keyboard navigation |
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

### Content Widths

| Width | Size |
|-------|------|
| :default | `min-w-[8rem]` |
| :sm | `w-40` |
| :md | `w-56` |
| :lg | `w-72` |

### Helper Methods

| Method | Description |
|--------|-------------|
| `dropdown_menu(css_classes: "", **html_options) { \|menu\| }` | Builder. Options (including `auto_close:`) go to the root partial |
| `dropdown_menu_simple(trigger_text, items:, trigger_options: {}, content_options: {})` | Data-driven menu built on `dropdown_menu` |

Builder methods:

| Method | Description |
|--------|-------------|
| `menu.trigger(variant: :outline, size: :default, as_child: false, **options) { }` | Trigger; the block is its content |
| `menu.content(align: :start, side: :bottom, width: :default, **options) { \|content\| }` | Content panel |
| `content.item(label = nil, href: nil, method: nil, icon: nil, variant: :default, disabled: false, **options) { \|item\| }` | Item. Without a block, renders `icon` (via `icon_for`) and `label`; with a block, the block is the content and `label`/`icon` are ignored |
| `item.shortcut(text)` | Appends a `dropdown_menu/shortcut` to the item (inside an item block) |
| `content.label(text = nil, inset: false, **options)` | Label |
| `content.separator(**options)` | Separator |
| `content.group(**options) { \|group\| }` | Group; the block receives a builder with the same `item`/`label`/`separator`/`group` methods |

`dropdown_menu_simple` item hashes accept `label`, `href`, `method`, `icon`,
`destructive: true` (→ `variant: :destructive`), `disabled`, `action`, `data`,
`separator: true` and `type`. Each hash renders as:

| Hash | Renders |
|------|---------|
| `separator: true` or `type: :separator` | Separator |
| `type: :label` | Label (heading); `href`/`action` are ignored |
| `type: :item` | Item: an `<a>` with `href`, otherwise a `<button>` |
| `href:` or `action:` (no `type`) | Item |
| `label:` only (no `type`, `href` or `action`) | Label, for backwards compatibility |

`action:` becomes the item's Stimulus `data-action`; `data:` is merged onto the item.

```erb
<%%= dropdown_menu_simple "Share", items: [
  { label: "Share", type: :label },
  { label: "Copy link", action: "click->clipboard#copy" },
  { label: "Archive", type: :item, data: { turbo_frame: "modal" } }
] %>
```

## Stimulus Controller

The root renders `data-controller="dropdown-menu"`.

| Target | Element |
|--------|---------|
| trigger | The trigger button (receives `aria-expanded` and focus on close) |
| content | The menu panel |
| chevron | The trigger's chevron icon (styled, not used by JS) |

| Value | Type | Default | Description |
|-------|------|---------|-------------|
| open | Boolean | false | Current state |
| autoClose | Boolean | false | Set by `auto_close: true` |

| Action | Description |
|--------|-------------|
| toggle | Bound on the trigger as `dropdown-menu#toggle` |
| open / close | Programmatic open and close |

While open, the menu closes on outside click, <kbd>Escape</kbd> and <kbd>Tab</kbd>;
<kbd>↑</kbd>/<kbd>↓</kbd>/<kbd>Home</kbd>/<kbd>End</kbd> move focus between enabled items.
The controller writes `data-state` (`open` / `closing` / `closed`) to the root and
content.

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
