# Breadcrumbs

> Displays the current location within a hierarchy.

<!-- preview:default height:60 -->

## Usage

```erb
<%%= render "components/breadcrumbs" do %>
  <%%= render "components/breadcrumbs/list" do %>
    <%%= render "components/breadcrumbs/item" do %>
      <%%= render "components/breadcrumbs/link", href: "/" do %>Home<%% end %>
    <%% end %>
    <%%= render "components/breadcrumbs/separator" %>
    <%%= render "components/breadcrumbs/item" do %>
      <%%= render "components/breadcrumbs/link", href: "/components" do %>Components<%% end %>
    <%% end %>
    <%%= render "components/breadcrumbs/separator" %>
    <%%= render "components/breadcrumbs/item" do %>
      <%%= render "components/breadcrumbs/page" do %>Breadcrumbs<%% end %>
    <%% end %>
  <%% end %>
<%% end %>
```

### Using Helper

```erb
<%%= breadcrumbs({"Home" => root_path, "Users" => users_path}, "John Doe") %>
```

The hash maps link text to path, in order. The second argument is the current
page (rendered with `breadcrumbs/page`); omit it and the last link ends the trail.

## Examples

### With Icons

<!-- preview:with_icons height:60 -->

```erb
<%%= render "components/breadcrumbs/link", href: "/" do %>
  <%%= icon_for(:home, class: "size-4") %>
  Home
<%% end %>
```

### Custom Separators

<!-- preview:custom_separators height:100 -->

```erb
<%%= render "components/breadcrumbs/separator", icon: :slash %>
<%%= render "components/breadcrumbs/separator", icon: :arrow_right %>
```

### Compact Size and Text Separators

The root picks up two styling hooks through `data:`. `size: :sm` tightens the gap
and drops the text to `text-xs`; `separator:` replaces every separator's icon with
a text glyph.

```erb
<%%= render "components/breadcrumbs", data: { size: :sm, separator: :slash } do %>
  <%# list, items and separators as usual %>
<%% end %>
```

| `data-separator` | Glyph |
|------------------|-------|
| slash | / |
| dot | • |
| arrow | → |

### With Ellipsis

<!-- preview:with_ellipsis height:60 -->

```erb
<%%= render "components/breadcrumbs/item" do %>
  <%%= render "components/breadcrumbs/ellipsis" %>
<%% end %>
```

### Responsive

<!-- preview:responsive height:120 -->

```erb
<%%= responsive_breadcrumbs(
  {"Home" => "/", "Docs" => "/docs", "Components" => "/components"},
  "Breadcrumbs"
) %>
```

Items collapse **only when they do not fit**, and come back when they do. The
controller measures the trail against its container and hides middle items one at
a time, from the first one inward, until the row fits — so the ellipsis always
stands for the items directly behind it. Widen the container and the hidden items
return; there is no one-way collapse and no item-count threshold.

The container is what is measured, not the window, so a breadcrumb inside a
collapsing sidebar or a resizing panel re-fits when that panel moves.

If a single current-page title is too long to help by collapsing anything, it
truncates with an ellipsis as a last resort.

### The ellipsis dropdown

When items are collapsed, the `…` becomes a button. Clicking it opens a menu
listing the hidden items as links, so nothing in the trail becomes unreachable.
It renders in the top layer as a popover — light dismiss and <kbd>Escape</kbd>
work natively — and needs no markup from you beyond `responsive_breadcrumbs`.

## API Reference

### Breadcrumbs

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| responsive | Boolean | false | Collapse middle items when the trail does not fit its container, and restore them when it does |
| collapse_after | Integer | — | **Deprecated, ignored.** Removed in 0.8.0 — see below |
| css_classes | String | "" | Additional CSS classes |
| html_options | Hash | {} | Additional HTML attributes |

`collapse_after` existed only because the width-based collapse never fired: the
last item was flex-shrinkable, so it absorbed the overflow and the row never
reported being too wide. The threshold faked collapsing by counting items, which
meant it also collapsed a trail with plenty of room. Measurement works now, so
the parameter is accepted and ignored; delete it from your calls.

The root renders `<nav aria-label="Breadcrumb">`. Pass `"aria-label":` (or
`aria: { label: }`) to replace the label, e.g. for a translated page. With
`responsive: true` it also attaches the `breadcrumb` Stimulus controller (see
below).

```erb
<%%= render "components/breadcrumbs", "aria-label": t(".breadcrumb") do %>
  <!-- list -->
<%% end %>
```

### Breadcrumbs List

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| css_classes | String | "" | Additional CSS classes |
| html_options | Hash | {} | Additional HTML attributes |

### Breadcrumbs Item

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| css_classes | String | "" | Additional CSS classes |
| html_options | Hash | {} | Additional HTML attributes |

Renders an `<li>`.

### Breadcrumbs Link

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| href | String | required | Link destination |
| css_classes | String | "" | Additional CSS classes |
| html_options | Hash | {} | Additional HTML attributes |

### Breadcrumbs Page

Renders `<span role="link" aria-current="page" aria-disabled="true">` around the block.

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| css_classes | String | "" | Additional CSS classes |
| html_options | Hash | {} | Additional HTML attributes |

### Breadcrumbs Separator

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| icon | Symbol | :chevron_right | Icon name passed to `icon_for`, or `:custom` to render the block instead |
| css_classes | String | "" | Additional CSS classes |
| html_options | Hash | {} | Additional HTML attributes |

### Breadcrumbs Ellipsis

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| css_classes | String | "" | Additional CSS classes |
| html_options | Hash | {} | Additional HTML attributes |

`breadcrumbs/separator` renders its own `<li role="presentation" aria-hidden="true">`,
so place it directly in the list — not inside an item. `breadcrumbs/ellipsis`
renders a `<span>` with an ellipsis icon and an sr-only "More" label; wrap it in
an item.

### Helper Methods

| Method | Description |
|--------|-------------|
| `breadcrumbs(links = {}, current_page = nil, css_classes: "")` | Renders a static trail from a `{ text => path }` hash |
| `responsive_breadcrumbs(links = {}, current_page = nil, css_classes: "", collapse_after: nil)` | Same, with `responsive: true`, the ellipsis item and the Stimulus targets wired in. `collapse_after` is deprecated and ignored |

## Stimulus Controller

`responsive: true` adds `data-controller="breadcrumb"` to the root.
`responsive_breadcrumbs` renders all of the targets for you; when you compose the
partials by hand you must add them yourself.

| Target | Element |
|--------|---------|
| item | A collapsible middle `breadcrumbs/item` (`data: { breadcrumb_target: "item" }`) |
| ellipsis | The `breadcrumbs/item` wrapping `breadcrumbs/ellipsis`, rendered with `css_classes: "hidden"` |
| ellipsisSeparator | The separator after the ellipsis item, also starting hidden |

The controller has no values and no public actions. It re-fits on container
resize (`ResizeObserver`), on font load and on `turbo:morph`, and removes the
overflow popover on `turbo:before-cache`. The separator directly after each
`item` target is hidden along with it.
