# Header

> A page header component for use with sidebar layouts.

<!-- preview:default height:60 -->

## Usage

```erb
<%%= render "components/header" do %>
  <h1 data-header-part="title">Dashboard</h1>
<%% end %>
```

## Examples

### With Breadcrumbs

<!-- preview:with_breadcrumbs height:60 -->

```erb
<%%= render "components/header" do %>
  <%%= render "components/breadcrumbs" do %>
    <%%= render "components/breadcrumbs/list" do %>
      <%%= render "components/breadcrumbs/item" do %>
        <%%= render "components/breadcrumbs/link", href: "#" do %>Dashboard<%% end %>
      <%% end %>
      <%%= render "components/breadcrumbs/separator" %>
      <%%= render "components/breadcrumbs/item" do %>
        <%%= render "components/breadcrumbs/page" do %>Settings<%% end %>
      <%% end %>
    <%% end %>
  <%% end %>
<%% end %>
```

### With Actions

<!-- preview:with_actions height:60 -->

```erb
<%%= render "components/header" do %>
  <h1 data-header-part="title">Projects</h1>

  <div data-header-part="actions">
    <button data-component="button" data-variant="outline" data-size="sm">Cancel</button>
    <button data-component="button" data-variant="primary" data-size="sm">Save</button>
  </div>
<%% end %>
```

## API Reference

### Header

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| css_classes | String | "" | Additional CSS classes |
| html_options | Hash | {} | Additional HTML attributes |

### Data Attributes

| Attribute | Element | Description |
|-----------|---------|-------------|
| data-component="header" | header | Main container |
| data-header-part="inner" | div | Inner flex container |
| data-header-part="title" | h1/span | Title text styling |
| data-header-part="actions" | div | Right-aligned actions container |
