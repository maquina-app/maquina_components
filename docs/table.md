# Table

> A responsive table component for displaying structured data.

<!-- preview:default height:280 -->

## Usage

```erb
<%%= render "components/table" do %>
  <%%= render "components/table/header" do %>
    <%%= render "components/table/row" do %>
      <%%= render "components/table/head", text: "Name" %>
      <%%= render "components/table/head", text: "Email" %>
      <%%= render "components/table/head", text: "Amount", css_classes: "text-right" %>
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

Every partial passes unknown keywords through as HTML attributes, so
standard table attributes like colspan and rowspan work directly on
cells, and id, aria, or data attributes work on any part.

## Examples

### With Footer

The footer cell spans two columns via the colspan passthrough.

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
      <%%= render "components/table/cell", colspan: 2, text: "Total" %>
      <%%= render "components/table/cell", text: "$750.00", css_classes: "text-right" %>
    <%% end %>
  <%% end %>
<%% end %>
```

### Selected Row

```erb
<%%= render "components/table/row", selected: true do %>
  <%%= render "components/table/cell", text: "Selected item" %>
<%% end %>
```

### Bordered Variant

Draws a border around the scroll container.

<!-- preview:bordered height:240 -->

```erb
<%%= render "components/table", variant: :bordered do %>
  <%# ... %>
<%% end %>
```

### Striped Variant

Alternates row backgrounds on the table itself.

<!-- preview:striped height:280 -->

```erb
<%%= render "components/table", table_variant: :striped do %>
  <%# ... %>
<%% end %>
```

### Simple Table Helper

For collection-driven tables, the simple_table helper renders the whole
structure from a column definition. Keys can be attribute names, hash
keys, or procs.

```erb
<%%= simple_table @invoices, caption: "Recent invoices", columns: [
  { key: :number, label: "Invoice" },
  { key: :customer, label: "Customer" },
  { key: ->(i) { i.amount.format }, label: "Amount", align: :right }
], row_id: :id, table_variant: :striped %>
```

## API Reference

### Table

The table renders two elements: a scrollable container div and the table
element inside it. The variant parameter styles the container (that is
why :bordered lives there), while table_variant styles the table element
itself.

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| container | Boolean | true | Wrap in scrollable container |
| variant | Symbol | nil | Container variant, :bordered draws a border around the scroll container |
| table_variant | Symbol | nil | Table variant, :striped alternates row backgrounds |
| css_classes | String | "" | Additional CSS classes |
| html_options | Hash | {} | Additional HTML attributes, including data |

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
| text | String | nil | Heading text |
| content | String | nil | Captured HTML via capture, or use block |
| scope | String | "col" | Scope attribute for accessibility |
| css_classes | String | "" | Additional CSS classes |
| html_options | Hash | {} | Additional HTML attributes |

### Table Cell

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| text | String | nil | Cell text |
| content | String | nil | Captured HTML via capture, or use block |
| css_classes | String | "" | Additional CSS classes |
| html_options | Hash | {} | Additional HTML attributes, e.g. colspan, rowspan |

### Table Caption

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| text | String | nil | Caption text |
| content | String | nil | Captured HTML via capture, or use block |
| css_classes | String | "" | Additional CSS classes |
| html_options | Hash | {} | Additional HTML attributes |

### Table Body / Footer

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| css_classes | String | "" | Additional CSS classes |
| html_options | Hash | {} | Additional HTML attributes |

### simple_table Helper

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| collection | Enumerable | required | Objects or hashes to render |
| columns | Array | required | Hashes with key (attribute, hash key, or proc), label, and optional align (:center, :right; left by default) |
| caption | String | nil | Table caption |
| variant | Symbol | nil | Container variant, :bordered |
| table_variant | Symbol | nil | Table variant, :striped |
| empty_message | String | "No data available" | Shown when the collection is empty |
| row_id | Symbol | nil | Method used to build each row id, row-{value} |
| html_options | Hash | {} | Additional HTML attributes for the table |
