# Table

> A responsive table component for displaying structured data.

---

## Quick Reference

### Parts

| Partial | Element | Description |
|---------|---------|-------------|
| `components/table` | `<table>` | Main table container |
| `components/table/header` | `<thead>` | Table header section |
| `components/table/body` | `<tbody>` | Table body section |
| `components/table/footer` | `<tfoot>` | Table footer section |
| `components/table/row` | `<tr>` | Table row |
| `components/table/head` | `<th>` | Header cell |
| `components/table/cell` | `<td>` | Body cell |
| `components/table/caption` | `<caption>` | Table caption |

### Parameters

#### `table`

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `container` | Boolean | `true` | Wrap in scrollable container |
| `variant` | Symbol | `:default` | Table style variant |
| `table_variant` | Symbol | `nil` | Additional table styling |
| `css_classes` | String | `""` | Additional CSS classes |
| `**html_options` | Hash | `{}` | HTML attributes |

#### `table/header`

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `sticky` | Boolean | `false` | Sticky header on scroll |
| `css_classes` | String | `""` | Additional CSS classes |
| `**html_options` | Hash | `{}` | HTML attributes |

#### `table/head`

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `sortable` | Boolean | `false` | Show sort indicator |
| `sorted` | Symbol | `nil` | Sort direction (`:asc`, `:desc`) |
| `align` | Symbol | `:left` | Text alignment (`:left`, `:center`, `:right`) |
| `css_classes` | String | `""` | Additional CSS classes |
| `**html_options` | Hash | `{}` | HTML attributes |

#### `table/cell`

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `align` | Symbol | `:left` | Text alignment (`:left`, `:center`, `:right`) |
| `css_classes` | String | `""` | Additional CSS classes |
| `**html_options` | Hash | `{}` | HTML attributes |

#### `table/row`

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `selected` | Boolean | `false` | Highlight as selected |
| `css_classes` | String | `""` | Additional CSS classes |
| `**html_options` | Hash | `{}` | HTML attributes |

### Data Attributes

**Component Identifiers**

| Attribute | Element | Description |
|-----------|---------|-------------|
| `data-component="table"` | `<table>` | Main component identifier |
| `data-table-part="container"` | Container div | Scrollable wrapper |
| `data-table-part="header"` | `<thead>` | Header section |
| `data-table-part="body"` | `<tbody>` | Body section |
| `data-table-part="footer"` | `<tfoot>` | Footer section |
| `data-table-part="row"` | `<tr>` | Table row |
| `data-table-part="head"` | `<th>` | Header cell |
| `data-table-part="cell"` | `<td>` | Body cell |
| `data-table-part="caption"` | `<caption>` | Table caption |

**State Attributes**

| Attribute | Description |
|-----------|-------------|
| `data-selected="true"` | Selected row |
| `data-sticky="true"` | Sticky header |
| `data-sortable="true"` | Sortable column |
| `data-sorted="asc"` | Ascending sort |
| `data-sorted="desc"` | Descending sort |
| `data-align="center"` | Center alignment |
| `data-align="right"` | Right alignment |

---

## Basic Usage

### Using Partials

```erb
<%%= render "components/table" do %>
  <%%= render "components/table/header" do %>
    <%%= render "components/table/row" do %>
      <%%= render "components/table/head" do %>Name<%% end %>
      <%%= render "components/table/head" do %>Email<%% end %>
      <%%= render "components/table/head" do %>Role<%% end %>
    <%% end %>
  <%% end %>
  
  <%%= render "components/table/body" do %>
    <%% @users.each do |user| %>
      <%%= render "components/table/row" do %>
        <%%= render "components/table/cell" do %><%%= user.name %><%% end %>
        <%%= render "components/table/cell" do %><%%= user.email %><%% end %>
        <%%= render "components/table/cell" do %><%%= user.role %><%% end %>
      <%% end %>
    <%% end %>
  <%% end %>
<%% end %>
```

### Using Data Attributes Directly

```erb
<div data-table-part="container">
  <table data-component="table">
    <thead data-table-part="header">
      <tr data-table-part="row">
        <th data-table-part="head">Name</th>
        <th data-table-part="head">Email</th>
      </tr>
    </thead>
    <tbody data-table-part="body">
      <%% @users.each do |user| %>
        <tr data-table-part="row">
          <td data-table-part="cell"><%%= user.name %></td>
          <td data-table-part="cell"><%%= user.email %></td>
        </tr>
      <%% end %>
    </tbody>
  </table>
</div>
```

---

## Examples

### With Caption

```erb
<%%= render "components/table" do %>
  <%%= render "components/table/caption" do %>
    A list of recent invoices
  <%% end %>
  
  <%%= render "components/table/header" do %>
    <!-- ... -->
  <%% end %>
  
  <%%= render "components/table/body" do %>
    <!-- ... -->
  <%% end %>
<%% end %>
```

### Sticky Header

```erb
<%%= render "components/table" do %>
  <%%= render "components/table/header", sticky: true do %>
    <!-- Header stays visible on scroll -->
  <%% end %>
  
  <%%= render "components/table/body" do %>
    <!-- ... -->
  <%% end %>
<%% end %>
```

### Sortable Columns

```erb
<%%= render "components/table/header" do %>
  <%%= render "components/table/row" do %>
    <%%= render "components/table/head", sortable: true, sorted: :asc do %>
      Name
    <%% end %>
    <%%= render "components/table/head", sortable: true do %>
      Email
    <%% end %>
    <%%= render "components/table/head" do %>
      Actions
    <%% end %>
  <%% end %>
<%% end %>
```

### Column Alignment

```erb
<%%= render "components/table/row" do %>
  <%%= render "components/table/cell" do %>Product Name<%% end %>
  <%%= render "components/table/cell", align: :center do %>Quantity<%% end %>
  <%%= render "components/table/cell", align: :right do %>$99.00<%% end %>
<%% end %>
```

### Selected Rows

```erb
<%% @items.each do |item| %>
  <%%= render "components/table/row", selected: item.selected? do %>
    <%%= render "components/table/cell" do %><%%= item.name %><%% end %>
  <%% end %>
<%% end %>
```

### With Actions Column

```erb
<%%= render "components/table/row" do %>
  <%%= render "components/table/cell" do %><%%= user.name %><%% end %>
  <%%= render "components/table/cell" do %><%%= user.email %><%% end %>
  <%%= render "components/table/cell", align: :right do %>
    <%%= dropdown_menu do |menu| %>
      <%% menu.trigger as_child: true do %>
        <button type="button" data-component="button" data-variant="ghost" data-size="icon-sm">
          <%%= icon_for :more_horizontal, class: "size-4" %>
        </button>
      <%% end %>
      <%% menu.content align: :end do %>
        <%% menu.item "Edit", href: edit_user_path(user), icon: :pencil %>
        <%% menu.separator %>
        <%% menu.item "Delete", href: user_path(user), method: :delete, icon: :trash, variant: :destructive %>
      <%% end %>
    <%% end %>
  <%% end %>
<%% end %>
```

---

## Real-World Patterns

### In a Card

```erb
<%%= render "components/card" do %>
  <%%= render "components/card/header", layout: :row do %>
    <div>
      <%%= render "components/card/title", text: "Users" %>
      <%%= render "components/card/description", text: "Manage your team members." %>
    </div>
    <%%= render "components/card/action" do %>
      <%%= link_to "Add User", new_user_path, data: { component: "button", variant: "primary", size: "sm" } %>
    <%% end %>
  <%% end %>
  
  <%%= render "components/card/content", spacing: :full do %>
    <%%= render "components/table", container: false do %>
      <!-- Table content -->
    <%% end %>
  <%% end %>
  
  <%%= render "components/card/footer", align: :between do %>
    <p class="text-sm text-muted-foreground"><%%= @pagy.count %> users</p>
    <%%= pagination_nav(@pagy) %>
  <%% end %>
<%% end %>
```

### With Empty State

```erb
<%%= render "components/table" do %>
  <%%= render "components/table/header" do %>
    <%%= render "components/table/row" do %>
      <%%= render "components/table/head" do %>Name<%% end %>
      <%%= render "components/table/head" do %>Email<%% end %>
    <%% end %>
  <%% end %>
  
  <%%= render "components/table/body" do %>
    <%% if @users.empty? %>
      <tr>
        <td colspan="2">
          <%%= empty_list_state(resource: "users", new_path: new_user_path) %>
        </td>
      </tr>
    <%% else %>
      <%% @users.each do |user| %>
        <%%= render "components/table/row" do %>
          <%%= render "components/table/cell" do %><%%= user.name %><%% end %>
          <%%= render "components/table/cell" do %><%%= user.email %><%% end %>
        <%% end %>
      <%% end %>
    <%% end %>
  <%% end %>
<%% end %>
```

### With Selection Checkboxes

```erb
<%%= render "components/table/header" do %>
  <%%= render "components/table/row" do %>
    <%%= render "components/table/head", css_classes: "w-12" do %>
      <input type="checkbox" data-component="checkbox" data-action="change->bulk-select#toggleAll">
    <%% end %>
    <%%= render "components/table/head" do %>Name<%% end %>
  <%% end %>
<%% end %>

<%%= render "components/table/body" do %>
  <%% @items.each do |item| %>
    <%%= render "components/table/row" do %>
      <%%= render "components/table/cell" do %>
        <input type="checkbox" name="selected[]" value="<%%= item.id %>" data-component="checkbox" data-bulk-select-target="checkbox">
      <%% end %>
      <%%= render "components/table/cell" do %><%%= item.name %><%% end %>
    <%% end %>
  <%% end %>
<%% end %>
```

---

## Theme Variables

```css
var(--border)
var(--background)
var(--foreground)
var(--muted)
var(--muted-foreground)
var(--accent)
```

---

## Customization

### Striped Rows

Add to your CSS:

```css
[data-component="table"][data-variant="striped"] [data-table-part="body"] [data-table-part="row"]:nth-child(even) {
  background-color: var(--muted);
}
```

Usage:

```erb
<%%= render "components/table", table_variant: :striped do %>
  <!-- ... -->
<%% end %>
```

### Compact Table

```erb
<%%= render "components/table", css_classes: "[&_th]:py-2 [&_td]:py-2" do %>
  <!-- ... -->
<%% end %>
```

### Without Container (No Scroll)

```erb
<%%= render "components/table", container: false do %>
  <!-- Table will not have horizontal scroll wrapper -->
<%% end %>
```

---

## Accessibility

- Uses semantic `<table>`, `<thead>`, `<tbody>`, `<th>`, `<td>` elements
- Headers use `scope="col"` for column headers
- Caption provides table description for screen readers
- Sortable columns indicate sort state via `aria-sort`
- Selected rows can use `aria-selected`

---

## File Structure

```
app/views/components/
├── _table.html.erb
└── table/
    ├── _header.html.erb
    ├── _body.html.erb
    ├── _footer.html.erb
    ├── _row.html.erb
    ├── _head.html.erb
    ├── _cell.html.erb
    └── _caption.html.erb

app/assets/stylesheets/table.css
docs/table.md
```
