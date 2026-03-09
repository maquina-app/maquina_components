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

```erb
<%%= responsive_breadcrumbs(
  {"Home" => "/", "Docs" => "/docs", "Components" => "/components"},
  "Breadcrumbs"
) %>
```

### Responsive with Collapse Threshold

Force-collapse middle items when total breadcrumb count exceeds a threshold, regardless of available space. Useful when items have long text that CSS truncation absorbs before overflow detection kicks in.

```erb
<%%= responsive_breadcrumbs(
  {"Home" => "/", "Docs" => "/docs", "Components" => "/components"},
  "Breadcrumbs",
  collapse_after: 2
) %>
```

`collapse_after` is the maximum number of visible items (first + last count as visible):
- `collapse_after: 2` — show first + last, collapse all middle into ellipsis
- `collapse_after: 3` — show first + one middle + last, collapse the rest
- `collapse_after: 0` or omitted — current behavior (pure overflow-based)

## API Reference

### Breadcrumbs

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| responsive | Boolean | false | Enable auto-collapse on narrow screens |
| collapse_after | Integer | 0 | Max visible items before force-collapsing (0 = pure overflow-based) |
| css_classes | String | "" | Additional CSS classes |
| html_options | Hash | {} | Additional HTML attributes |

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
