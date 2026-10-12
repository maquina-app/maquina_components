# Menu Button

> A sidebar-flavored button with an avatar and title/subtitle that opens a dropdown panel, such as a workspace or account switcher.

## Usage

`components/menu_button` renders the trigger and yields its id, which you pass to
`components/dropdown` — the panel that pairs with it — so the trigger and panel
are wired together with `aria-labelledby`.

```erb
<%%= render "components/menu_button",
  title: "Acme Inc",
  subtitle: "Enterprise",
  text_icon: "A",
  submenu: true do |menu_id| %>
  <%%= render "components/dropdown", id: menu_id, side: :bottom do %>
    <%%= render "components/dropdown_menu/item", href: settings_path do %>Settings<%% end %>
    <%%= render "components/dropdown_menu/item", href: session_path, method: :delete do %>Sign out<%% end %>
  <%% end %>
<%% end %>
```

The panel has no item styling of its own; `dropdown_menu/item`,
`dropdown_menu/label` and `dropdown_menu/separator` are styled wherever they
appear, so they work inside it. Keyboard navigation between items is a
[Dropdown Menu](dropdown_menu.md) feature and is not provided here.

## Examples

### In the Sidebar Header

```erb
<%%= render "components/sidebar/header" do %>
  <%%= render "components/menu_button",
    title: "Máquina",
    subtitle: "Components",
    icon: "logo.svg",
    icon_classes: "size-8 rounded-md" do %>
  <%% end %>
<%% end %>
```

When the sidebar collapses to icons (`collapsible: :icon`), the trigger shrinks
to a 2rem square.

### Without a Panel

Pass an empty block when the button is purely decorative. The controller only
opens when a `components/dropdown` panel is present.

```erb
<%%= render "components/menu_button", title: "Acme Inc", text_icon: "A" do %><%% end %>
```

## Placement

The panel opens on `side:` (`:top` by default) and flips to the other side when
it would run past the viewport and the opposite side has room. `align: :start`
anchors its left edge to the trigger, `align: :end` its right edge. The panel is
a fixed `14rem` wide.

## API Reference

### Menu Button

Renders `<ul data-component="menu-button">` containing one `<li>` that carries the
`menu-button` controller, the trigger `<button>`, and the block.

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| title | String | "" | Primary text; also the image `alt` |
| subtitle | String | nil | Secondary text |
| icon | String | nil | Image path/URL for the avatar (`image_tag`) |
| text_icon | String | nil | Text for the avatar square, used when `icon` is blank |
| icon_classes | String | "" | Classes for the image or the text-icon span |
| submenu | Boolean | false | Shows a trailing up/down chevron |
| id | String | "menu-button-#{title.parameterize}" | Base id (`"menu-button-menu"` when `title` is blank). The trigger gets `#{id}-trigger`; the block receives `id` |
| css_classes | String | "" | Additional CSS classes |
| html_options | Hash | {} | Additional HTML attributes (on the `<ul>`) |

### Dropdown (`components/dropdown`)

Renders `<div role="menu" hidden>` with `data-menu-button-part="content"`. It
must be rendered inside the `menu_button` block.

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| id | String | nil | Pass the id yielded by `menu_button`. Sets the panel id to `#{id}-content` and `aria-labelledby` to `#{id}-trigger` |
| side | Symbol | :top | :top or :bottom — a preference; see [Placement](#placement) |
| align | Symbol | :start | :start or :end |
| css_classes | String | "" | Additional CSS classes |
| html_options | Hash | {} | Additional HTML attributes |

## Stimulus Controller

`menu-button`, attached to the `<li>`.

| Target | Element |
|--------|---------|
| button | The trigger |
| content | The `components/dropdown` panel |

| Value | Type | Default | Description |
|-------|------|---------|-------------|
| open | Boolean | false | Current state |

| Action | Description |
|--------|-------------|
| toggle | Bound on the trigger as `menu-button#toggle` |
| open / close | Programmatic open and close |

While open, the panel closes on outside click and <kbd>Escape</kbd>, and focus
returns to the trigger. The controller keeps `aria-expanded` and `data-state`
(`open` / `closing` / `closed`) in sync on the trigger and panel, and resets to
closed before Turbo caches the page.
