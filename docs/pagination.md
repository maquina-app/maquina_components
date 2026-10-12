# Pagination

> Navigation for paginated content.

<!-- preview:default height:80 -->

## Usage

```erb
<%%= render "components/pagination" do %>
  <%%= render "components/pagination/content" do %>
    <%%= render "components/pagination/item" do %>
      <%%= render "components/pagination/previous", href: "/page/1" %>
    <%% end %>
    <%%= render "components/pagination/item" do %>
      <%%= render "components/pagination/link", href: "/page/1" do %>1<%% end %>
    <%% end %>
    <%%= render "components/pagination/item" do %>
      <%%= render "components/pagination/link", href: "/page/2", active: true do %>2<%% end %>
    <%% end %>
    <%%= render "components/pagination/item" do %>
      <%%= render "components/pagination/link", href: "/page/3" do %>3<%% end %>
    <%% end %>
    <%%= render "components/pagination/item" do %>
      <%%= render "components/pagination/ellipsis" %>
    <%% end %>
    <%%= render "components/pagination/item" do %>
      <%%= render "components/pagination/next", href: "/page/3" %>
    <%% end %>
  <%% end %>
<%% end %>
```

### Using the Helper (Pagy)

```erb
<%%= pagination_nav(@pagy, :users_path) %>
<%%= pagination_nav(@pagy, :search_users_path, params: { q: params[:q] }) %>
<%%= pagination_nav(@pagy, :users_path, turbo: { action: :advance, frame: "users" }) %>
<%%= pagination_simple(@pagy, :users_path) %>
```

`pagination_nav` renders previous, the page series from `pagy.series` (with
`:gap` as an ellipsis) and next. `pagination_simple` renders only previous and
next. Both return `nil` when there is a single page, and preserve the current
query string apart from the page param.

The helpers work with Pagy 9 and earlier (`pagy.vars[:page_param]`, `pagy.prev`)
and with Pagy 43 and later (`pagy.options[:page_key]`, `pagy.previous`). The page
param falls back to `page` when neither is set.

## Examples

### Icon-only Previous and Next

```erb
<%%= render "components/pagination/previous", href: prev_path, show_label: false %>
<%%= render "components/pagination/next", href: next_path, show_label: false %>
```

The label stays as the link's `aria-label`.

## API Reference

### Pagination

Renders `<nav role="navigation" aria-label="Pagination">`. Pass `"aria-label":`
to override the label.

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| css_classes | String | "" | Additional CSS classes |
| html_options | Hash | {} | Additional HTML attributes |

### Pagination Content

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| css_classes | String | "" | Additional CSS classes |
| html_options | Hash | {} | Additional HTML attributes |

### Pagination Item

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| css_classes | String | "" | Additional CSS classes |
| html_options | Hash | {} | Additional HTML attributes |

### Pagination Link

Renders an `<a>` (with `aria-current="page"` and `data-active="true"` when
active), or a `<span aria-disabled="true">` when disabled. An inactive link has
no `data-active` attribute.

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| href | String | required | URL for the page |
| active | Boolean | false | Whether current page |
| disabled | Boolean | false | Whether disabled |
| css_classes | String | "" | Additional CSS classes |
| html_options | Hash | {} | Additional HTML attributes |

### Pagination Previous

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| href | String | nil | URL for previous page; `nil` renders the disabled state |
| label | String | nil | Label; falls back to `t("maquina_components.pagination.previous", default: "Previous")` |
| disabled | Boolean | false | Render a `<span aria-disabled="true">` instead of a link |
| show_label | Boolean | true | Show text label |
| css_classes | String | "" | Additional CSS classes |
| html_options | Hash | {} | Additional HTML attributes |

### Pagination Next

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| href | String | nil | URL for next page; `nil` renders the disabled state |
| label | String | nil | Label; falls back to `t("maquina_components.pagination.next", default: "Next")` |
| disabled | Boolean | false | Render a `<span aria-disabled="true">` instead of a link |
| show_label | Boolean | true | Show text label |
| css_classes | String | "" | Additional CSS classes |
| html_options | Hash | {} | Additional HTML attributes |

### Pagination Ellipsis

Renders a `<span>` with a dots icon (`aria-hidden`) and an sr-only label from
`t("maquina_components.pagination.more_pages", default: "More pages")`, which
screen readers announce.

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| css_classes | String | "" | Additional CSS classes |
| html_options | Hash | {} | Additional HTML attributes (`data:` is merged) |

### Helper Methods

| Method | Description |
|--------|-------------|
| `pagination_nav(pagy, route_helper, params: {}, turbo: { action: :replace }, show_labels: true, css_classes: "", **html_options)` | Full pagination from a Pagy object |
| `pagination_simple(pagy, route_helper, params: {}, turbo: { action: :replace }, css_classes: "", **html_options)` | Previous/next only |
| `paginated_path(route_helper, pagy, page, extra_params = {})` | Builds the URL for a page, keeping the current query params |

`route_helper` is the route helper's name as a symbol (`:users_path`). `turbo:`
accepts `action:` and `frame:`, rendered as `data-turbo-action` and
`data-turbo-frame` on every enabled link; pass `turbo: {}` to omit them.

### Translations

| Key | Default |
|-----|---------|
| `maquina_components.pagination.previous` | "Previous" |
| `maquina_components.pagination.next` | "Next" |
| `maquina_components.pagination.more_pages` | "More pages" |
