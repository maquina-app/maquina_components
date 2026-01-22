# Table

> A responsive table component for displaying structured data.

<!-- preview:default height:280 -->

## Usage

```erb
<%%= render "components/table" do %>
  <%%= render "components/table/header" do %>
    <%%= render "components/table/row" do %>
      <%%= render "components/table/head" do %>Name<%% end %>
      <%%= render "components/table/head" do %>Email<%% end %>
      <%%= render "components/table/head", css_classes: "text-right" do %>Amount<%% end %>
    <%% end %>
  <%% end %>

  <%%= render "components/table/body" do %>
    <%% @users.each do |user| %>
      <%%= render "components/table/row" do %>
        <%%= render "components/table/cell" do %><%%= user.name %><%% end %>
        <%%= render "components/table/cell" do %><%%= user.email %><%% end %>
        <%%= render "components/table/cell", css_classes: "text-right" do %><%%= user.amount %><%% end %>
      <%% end %>
    <%% end %>
  <%% end %>
<%% end %>
```

## Examples

### With Footer

```erb
<%%= render "components/table" do %>
  <%%= render "components/table/header" do %>
    <%# ... %>
  <%% end %>
  <%%= render "components/table/body" do %>
    <%# ... %>
  <%% end %>
  <%%= render "components/table/footer" do %>
    <%%= render "components/table/row" do %>
      <%%= render "components/table/cell", colspan: 2 do %>Total<%% end %>
      <%%= render "components/table/cell", css_classes: "text-right" do %>$750.00<%% end %>
    <%% end %>
  <%% end %>
<%% end %>
```

### Selected Row

```erb
<%%= render "components/table/row", selected: true do %>
  <%%= render "components/table/cell" do %>Selected item<%% end %>
<%% end %>
```

### Bordered Variant

```erb
<%%= render "components/table", variant: :bordered do %>
  <%# ... %>
<%% end %>
```

### Striped Variant

```erb
<%%= render "components/table", table_variant: :striped do %>
  <%# ... %>
<%% end %>
```

## API Reference

### Table

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| container | Boolean | true | Wrap in scrollable container |
| variant | Symbol | nil | Container variant (:bordered) |
| table_variant | Symbol | nil | Table variant (:striped) |
| css_classes | String | "" | Additional CSS classes |
| html_options | Hash | {} | Additional HTML attributes |

### Table Header

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| sticky | Boolean | false | Sticky header on scroll |
| css_classes | String | "" | Additional CSS classes |
| html_options | Hash | {} | Additional HTML attributes |

### Table Row

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| selected | Boolean | false | Highlight as selected |
| css_classes | String | "" | Additional CSS classes |
| html_options | Hash | {} | Additional HTML attributes |

### Table Head

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| scope | String | "col" | Scope attribute for accessibility |
| css_classes | String | "" | Additional CSS classes |
| html_options | Hash | {} | Additional HTML attributes |

### Table Cell

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| css_classes | String | "" | Additional CSS classes |
| html_options | Hash | {} | Additional HTML attributes |

### Table Body / Footer / Caption

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| css_classes | String | "" | Additional CSS classes |
| html_options | Hash | {} | Additional HTML attributes |
