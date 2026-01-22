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

## API Reference

### Pagination

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
| href | String | nil | URL for previous page |
| label | String | "Previous" | Button label |
| disabled | Boolean | false | Whether disabled |
| show_label | Boolean | true | Show text label |
| css_classes | String | "" | Additional CSS classes |
| html_options | Hash | {} | Additional HTML attributes |

### Pagination Next

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| href | String | nil | URL for next page |
| label | String | "Next" | Button label |
| disabled | Boolean | false | Whether disabled |
| show_label | Boolean | true | Show text label |
| css_classes | String | "" | Additional CSS classes |
| html_options | Hash | {} | Additional HTML attributes |

### Pagination Ellipsis

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| css_classes | String | "" | Additional CSS classes |
| html_options | Hash | {} | Additional HTML attributes |
