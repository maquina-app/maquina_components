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

### Breadcrumbs Link

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| href | String | required | Link destination |
| css_classes | String | "" | Additional CSS classes |
| html_options | Hash | {} | Additional HTML attributes |

### Breadcrumbs Page

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| css_classes | String | "" | Additional CSS classes |
| html_options | Hash | {} | Additional HTML attributes |

### Breadcrumbs Separator

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| icon | Symbol | :chevron_right | Icon name, or :custom to use block |
| css_classes | String | "" | Additional CSS classes |
| html_options | Hash | {} | Additional HTML attributes |

### Breadcrumbs Ellipsis

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| css_classes | String | "" | Additional CSS classes |
| html_options | Hash | {} | Additional HTML attributes |
