# ERB Patterns Guide

> Conventions and patterns for ERB partials in maquina_components.

## Strict Locals

All partials **must** use strict locals declaration as the first line:

```erb
<%# locals: (variant: :default, size: :md, css_classes: "", **html_options) %>
```

### Rules

1. **First line** of the partial (comment doesn't count as content)
2. **Symbol defaults** - Use `:default` not `"default"`
3. **Required params** - Omit default value: `(href:, css_classes: "", **html_options)`
4. **Splat for passthrough** - Always include `**html_options`
5. **No Ruby keywords as local names** - `for` cannot be a strict local, so the label partial uses `for_id:`

### Common Parameter Patterns

```erb
<%# Simple component %>
<%# locals: (variant: :default, css_classes: "", **html_options) %>

<%# With size %>
<%# locals: (variant: :default, size: :md, css_classes: "", **html_options) %>

<%# Leaf part (text, content or block) %>
<%# locals: (text: nil, content: nil, css_classes: "", **html_options) %>

<%# With required param %>
<%# locals: (href:, active: false, disabled: false, css_classes: "", **html_options) %>

<%# Layout variant %>
<%# locals: (layout: :column, css_classes: "", **html_options) %>

<%# Boolean flags %>
<%# locals: (disabled: false, required: false, css_classes: "", **html_options) %>
```

## Parameter Naming Conventions

| Parameter | Type | Purpose |
|-----------|------|---------|
| `variant` | Symbol | Visual style (`:default`, `:primary`, `:destructive`) |
| `size` | Symbol | Size variant (`:sm`, `:md`/`:default`, `:lg`) |
| `layout` / `align` / `spacing` | Symbol | Layout variants (`:row`, `:end`, `:full`) |
| `css_classes` | String | Additional CSS classes (NOT `class:`) |
| `**html_options` | Hash | HTML attribute passthrough (`id:`, `aria:`, `data:`, …) |
| `text` / `content` | String | Content (alternatives to a block) |
| `icon` / `icon_name` | Symbol | Icon name for `icon_for` |
| `id` | String | Stable DOM id (used to wire triggers and aria) |
| `for_id` | String | Id of the element a trigger/label controls |
| `disabled`, `active`, `selected` | Boolean | State |

### Vocabulary aliases

The library accepts a few aliases and normalizes them at the top of the partial:

- `variant: :error` → `:destructive` (alert, badge, toast)
- `size: :default` → `:md` on badge (`:default` is the canonical middle size elsewhere)

```erb
<%
  size = :md if size.to_s == "default"
  variant = :destructive if variant.to_s == "error"
%>
```

**Why `css_classes` not `class`?**
- `class` is a Ruby reserved word
- More explicit about purpose
- Avoids confusion with CSS class attribute

Utilities passed through `css_classes:` **win** over the engine's styles (component CSS lives in `@layer components`).

## Data Attribute Merging

Always merge the caller's `data:` with the component's data attributes using `merge_component_data` (`app/helpers/maquina_components/components_helper.rb`):

```erb
<%# locals: (variant: :default, size: :md, css_classes: "", **html_options) %>
<% merged_data = merge_component_data(html_options,
    component: :badge,
    variant: variant,
    size: size
  ) %>

<%= content_tag :span, class: css_classes.presence, data: merged_data, **html_options do %>
  <%= yield %>
<% end %>
```

`merge_component_data(html_options, **component_data)` removes `:data` from `html_options` and returns the merged hash.

### Precedence Rules

| Key | Who wins |
|-----|----------|
| `:component`, `:variant`, `:size`, any key ending in `_part` / `-part` | **Component** — callers can't break styling hooks |
| `:controller`, `:action` | **Concatenated** — component's tokens first, then the caller's |
| Everything else (`:state`, Stimulus values, outlets, custom keys) | **Caller** — enables per-instance overrides |

The result is `.compact`ed: a `nil` value emits no attribute at all. `false` still renders `"false"`, so for presence-style flags pass `nil` when off:

```erb
<% merged_data = merge_component_data(html_options,
    sidebar_part: "menu-button",
    active: (active ? true : nil)   # data-active="true" or no attribute
  ) %>
```

### Complete Example

```erb
<%# Caller: %>
<%= render "components/badge",
  variant: :success,
  id: "status-badge",
  data: { controller: "tooltip", tooltip_text: "Active", variant: "primary" } do %>
  Active
<% end %>

<%# Produces (the caller's variant is ignored; component identity wins): %>
<span
  id="status-badge"
  data-controller="tooltip"
  data-tooltip-text="Active"
  data-component="badge"
  data-variant="success"
  data-size="md">
  Active
</span>
```

```erb
<%# Controller concatenation %>
<%= render "components/combobox", name: "country",
      data: { controller: "analytics", action: "change->analytics#track" } %>
<%# => data-controller="combobox analytics" %>
```

### Key Naming

- Symbol keys are dasherized: `card_part:` → `data-card-part`, `sidebar_open_value:` → `data-sidebar-open-value`.
- **Values are not.** Multi-word component and part names are written as kebab-case strings: `component: "dropdown-menu"`, `"dropdown-menu-part": "item"`, `sidebar_part: "menu-button"`.

## Content Patterns

Every leaf partial takes its content three ways, interchangeably: `text:` wins when present, then `content:`, then the block. `text: ""` falls through to the block.

### The Standard Leaf

```erb
<%# app/views/components/card/_title.html.erb %>
<%# locals: (text: nil, content: nil, size: :default, css_classes: "", **html_options) %>
<% merged_data = merge_component_data(html_options,
    card_part: :title,
    size: (size == :sm ? :sm : nil)
  ).compact %>

<%= content_tag :div, class: css_classes.presence, data: merged_data, **html_options do %>
  <%= text.presence || content || yield %>
<% end %>
```

```erb
<%# Usage - all three work %>
<%= render "components/card/title", text: "Welcome" %>
<%= render "components/card/title", content: "Welcome" %>
<%= render "components/card/title" do %>Welcome <%= icon_for :check %><% end %>
```

Pass a block whenever the content is markup rather than a string.

### Block Content (containers)

```erb
<%# locals: (variant: :default, css_classes: "", **html_options) %>
<% merged_data = merge_component_data(html_options, component: :badge, variant: variant) %>

<%= content_tag :span, class: css_classes.presence, data: merged_data, **html_options do %>
  <%= yield %>
<% end %>

<%# Usage %>
<%= render "components/badge", variant: :success do %>
  <%= icon_for :check, class: "size-3" %>
  Active
<% end %>
```

## Compound Components

For components with multiple parts (Card, Alert, Sidebar):

### Directory Structure

```
app/views/components/
├── _card.html.erb           # Main wrapper
└── card/
    ├── _header.html.erb     # CardHeader
    ├── _title.html.erb      # CardTitle
    ├── _description.html.erb
    ├── _action.html.erb
    ├── _content.html.erb
    └── _footer.html.erb
```

### Main Wrapper

```erb
<%# app/views/components/_card.html.erb %>
<%# locals: (css_classes: "", **html_options) %>
<% merged_data = merge_component_data(html_options, component: :card) %>

<%= content_tag :div, class: css_classes.presence, data: merged_data, **html_options do %>
  <%= yield %>
<% end %>
```

### Sub-Component with Part Attribute

Emit a variant attribute only when it differs from the default (`nil` drops it):

```erb
<%# app/views/components/card/_header.html.erb %>
<%# locals: (layout: :column, css_classes: "", **html_options) %>
<% merged_data = merge_component_data(html_options,
    card_part: :header,
    layout: (layout.to_sym == :row ? :row : nil)
  ).compact %>

<%= content_tag :div, class: css_classes.presence, data: merged_data, **html_options do %>
  <%= yield %>
<% end %>
```

### Usage

```erb
<%= render "components/card" do %>
  <%= render "components/card/header", layout: :row do %>
    <div>
      <%= render "components/card/title", text: "Settings" %>
      <%= render "components/card/description", text: "Manage preferences" %>
    </div>
    <%= render "components/card/action" do %>
      <%= button_to "Save", save_path, data: { component: "button", variant: "primary" } %>
    <% end %>
  <% end %>

  <%= render "components/card/content" do %>
    <!-- Form fields -->
  <% end %>

  <%= render "components/card/footer", align: :end do %>
    <%= link_to "Cancel", cancel_path, data: { component: "button", variant: "outline" } %>
  <% end %>
<% end %>
```

## Conditional Rendering

### Optional Sections

```erb
<%# locals: (title: nil, description: nil, css_classes: "", **html_options) %>
<% merged_data = merge_component_data(html_options, component: :my_widget) %>

<%= content_tag :div, class: css_classes.presence, data: merged_data, **html_options do %>
  <% if title.present? %>
    <div data-my-widget-part="title"><%= title %></div>
  <% end %>

  <% if description.present? %>
    <p data-my-widget-part="description"><%= description %></p>
  <% end %>

  <%= yield %>
<% end %>
```

### Conditional Attributes

```erb
<%# locals: (variant: :default, disabled: false, css_classes: "", **html_options) %>
<% merged_data = merge_component_data(html_options,
    component: :my_widget,
    variant: variant,
    disabled: (disabled ? true : nil)
  ) %>

<%= content_tag :button,
      type: :button,
      disabled: (disabled || nil),
      aria: { disabled: (disabled ? "true" : nil) }.compact,
      class: css_classes.presence,
      data: merged_data,
      **html_options do %>
  <%= yield %>
<% end %>
```

### Attributes on a Literal Tag

When a partial writes HTML by hand, pass the rest through `tag.attributes`:

```erb
<aside id="<%= stable_id %>" <%= tag.attributes(data: merged_data, **html_options) %>>
  <%= yield %>
</aside>
```

## Link and Button Patterns

Buttons are a CSS-only form component — there is no `components/button` partial. Put the data attributes on Rails helpers:

### As Link

```erb
<%= link_to users_path, data: { component: "badge", variant: "primary" } do %>
  View Users
<% end %>
```

### As Button

```erb
<%# Using button_to %>
<%= button_to save_path, data: { component: "button", variant: "primary" } do %>
  Save Changes
<% end %>

<%# Using form submit %>
<%= form.submit "Create", data: { component: "button", variant: "primary" } %>

<%# Icon button %>
<%= button_tag type: :button, aria: { label: "Settings" },
      data: { component: "button", variant: "ghost", size: "icon" } do %>
  <%= icon_for :settings %>
<% end %>
```

### Component That Can Be Either

```erb
<%# locals: (href: nil, variant: :default, css_classes: "", **html_options) %>
<% merged_data = merge_component_data(html_options, component: :badge, variant: variant) %>

<% if href.present? %>
  <%= link_to href, class: css_classes.presence, data: merged_data, **html_options do %>
    <%= yield %>
  <% end %>
<% else %>
  <%= content_tag :span, class: css_classes.presence, data: merged_data, **html_options do %>
    <%= yield %>
  <% end %>
<% end %>
```

## Icon Helper

Use `icon_for(name, options = {})` for icons:

```erb
<%= render "components/badge", variant: :success do %>
  <%= icon_for :check, class: "size-3" %>
  Success
<% end %>
```

- The host app's `main_icon_svg_for(name)` (in `app/helpers/maquina_components_helper.rb`) is tried first; `nil` falls back to the engine's built-in set.
- An unknown name raises `MaquinaComponents::UnknownIconError` when `MaquinaComponents.strict_icons` is on (default in development and test) and renders nothing in production.
- Engine partials that need an icon of their own (chevrons, close buttons) use `builtin_icon_for`, which never consults the host override.
- Built-in names include `:check`, `:x`, `:chevron_down`, `:chevron_right`, `:chevron_left`, `:chevrons_up_down`, `:circle_alert`, `:circle_check`, `:triangle_alert`, `:info`, `:search`, `:settings`, `:home`, `:folder`, `:inbox`, `:user`, `:users`, `:mail`, `:trash`, `:pencil`, `:download`, `:upload`, `:calendar`, `:ellipsis`, `:left_panel`, `:log_out` — see `icons_helper.rb` for the full list.

## Accessibility Patterns

### ARIA Labels

`aria:` passes through `**html_options`:

```erb
<%= render "components/sidebar/trigger", aria: { label: "Toggle navigation" } %>
```

### Current Page / Active

```erb
<%= link_to url, data: merged_data, "aria-current": (active ? "page" : nil), **html_options do %>
  ...
<% end %>
```

### Disabled Links

```erb
<%# Links can't be :disabled — use aria-disabled and remove from tab order %>
<%= link_to "#",
  class: css_classes.presence,
  data: merged_data,
  aria: { disabled: "true" },
  tabindex: "-1",
  **html_options do %>
  <%= yield %>
<% end %>
```

### Server-rendered State

Render the initial state in the partial so the page is correct before Stimulus connects (e.g. the sidebar renders `inert` on its container when collapsed off-canvas; menus render `hidden` and `data-state="closed"`).

## Testing Locals

Strict locals raise `ActionView::Template::Error` for unknown or missing required locals:

```ruby
# This will error - missing required `href:` param
render "components/breadcrumbs/link"

# This works
render "components/breadcrumbs/link", href: root_path
```

Partial rendering is covered in `test/components/components_render_test.rb`.

## Anti-Patterns to Avoid

### ❌ String Defaults

```erb
<%# Wrong %>
<%# locals: (variant: "default") %>

<%# Correct %>
<%# locals: (variant: :default) %>
```

### ❌ Using `class:` Parameter

```erb
<%# Wrong %>
<%# locals: (class: "") %>

<%# Correct %>
<%# locals: (css_classes: "") %>
```

### ❌ Not Merging Data Attributes

```erb
<%# Wrong - overwrites the caller's data %>
<%= content_tag :div, data: { component: :card } %>

<%# Wrong - caller can clobber data-component / data-*-part %>
<% merged_data = { component: :card }.merge(html_options.delete(:data) || {}) %>

<%# Correct %>
<% merged_data = merge_component_data(html_options, component: :card) %>
<%= content_tag :div, data: merged_data, **html_options %>
```

### ❌ Dropping the Block

```erb
<%# Wrong - silently ignores a block %>
<%= text || content %>

<%# Correct %>
<%= text.presence || content || yield %>
```

### ❌ Inline Tailwind Classes

```erb
<%# Wrong %>
<%= content_tag :div, class: "p-4 rounded-md bg-white" %>

<%# Correct - use css_classes for additions only %>
<%= content_tag :div, class: css_classes.presence, data: merged_data %>
```

### ❌ Emitting `data-x="false"`

```erb
<%# Wrong - [data-active] presence selectors match "false" too %>
<% merged_data = merge_component_data(html_options, active: active) %>

<%# Correct %>
<% merged_data = merge_component_data(html_options, active: (active ? true : nil)) %>
```

### ❌ Forgetting **html_options

```erb
<%# Wrong - can't pass id, aria, etc. %>
<%# locals: (variant: :default, css_classes: "") %>

<%# Correct %>
<%# locals: (variant: :default, css_classes: "", **html_options) %>
```
