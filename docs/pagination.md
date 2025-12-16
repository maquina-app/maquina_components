# Pagination

> Navigation for paginated content with Pagy integration.

---

## Quick Reference

### Helper Methods

| Method | Description |
|--------|-------------|
| `pagination_nav(pagy)` | Full pagination with page numbers |
| `pagination_simple(pagy)` | Previous/Next only (no page numbers) |
| `paginated_path(pagy, page)` | Build URL for a specific page |

### Parts

| Partial | Description |
|---------|-------------|
| `components/pagination` | Root nav container |
| `components/pagination/content` | List wrapper (`<ul>`) |
| `components/pagination/item` | List item (`<li>`) |
| `components/pagination/link` | Page link |
| `components/pagination/previous` | Previous page button |
| `components/pagination/next` | Next page button |
| `components/pagination/ellipsis` | Gap indicator (`...`) |

### Parameters

#### `pagination_nav` / `pagination_simple` Helper

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `pagy` | Pagy | — | Pagy instance (required) |
| `css_classes` | String | `""` | Additional CSS classes |

#### `pagination/link`

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `href` | String | — | URL for the page |
| `current` | Boolean | `false` | Whether this is the current page |
| `disabled` | Boolean | `false` | Whether the link is disabled |

### Data Attributes

**Component Identifiers**

| Attribute | Element | Description |
|-----------|---------|-------------|
| `data-component="pagination"` | `<nav>` | Main component identifier |
| `data-pagination-part="content"` | `<ul>` | List wrapper |
| `data-pagination-part="item"` | `<li>` | List item |
| `data-pagination-part="link"` | `<a>` / `<span>` | Page link |
| `data-pagination-part="previous"` | `<a>` | Previous button |
| `data-pagination-part="next"` | `<a>` | Next button |
| `data-pagination-part="ellipsis"` | `<span>` | Gap indicator |

**State Attributes**

| Attribute | Description |
|-----------|-------------|
| `aria-current="page"` | Current page indicator |
| `aria-disabled="true"` | Disabled link |
| `data-active="true"` | Current page styling |

---

## Basic Usage

### Using Helper (Recommended)

```erb
<%%# In controller %%>
@pagy, @records = pagy(Record.all)

<%%# In view %%>
<%%%= pagination_nav(@pagy) %%>
```

### Simple Pagination (Prev/Next Only)

```erb
<%%%= pagination_simple(@pagy) %%>
```

---

## Examples

### Full Pagination

```erb
<%%%= pagination_nav(@pagy) %%>
```

Renders:
```
[<] [1] [2] [3] ... [10] [>]
```

### Using Partials

```erb
<%%%= render "components/pagination" do %%>
  <%%%= render "components/pagination/content" do %%>
    <%%%= render "components/pagination/item" do %%>
      <%%%= render "components/pagination/previous", href: paginated_path(@pagy, @pagy.prev), disabled: !@pagy.prev %%>
    <%%% end %%>
    
    <%%% @pagy.series.each do |item| %%>
      <%%% case item %%>
      <%%% when Integer %%>
        <%%%= render "components/pagination/item" do %%>
          <%%%= render "components/pagination/link", href: paginated_path(@pagy, item), current: item == @pagy.page do %%>
            <%%%= item %%>
          <%%% end %%>
        <%%% end %%>
      <%%% when :gap %%>
        <%%%= render "components/pagination/item" do %%>
          <%%%= render "components/pagination/ellipsis" %%>
        <%%% end %%>
      <%%% end %%>
    <%%% end %%>
    
    <%%%= render "components/pagination/item" do %%>
      <%%%= render "components/pagination/next", href: paginated_path(@pagy, @pagy.next), disabled: !@pagy.next %%>
    <%%% end %%>
  <%%% end %%>
<%%% end %%>
```

### With Page Info

```erb
<div class="flex items-center justify-between">
  <p class="text-sm text-muted-foreground">
    Showing <%%%= @pagy.from %%>-<%%%= @pagy.to %%> of <%%%= @pagy.count %%> results
  </p>
  <%%%= pagination_nav(@pagy) %%>
</div>
```

### With Per-Page Selector

```erb
<div class="flex items-center justify-between">
  <div class="flex items-center gap-2">
    <span class="text-sm text-muted-foreground">Show</span>
    <%%%= form_with url: request.path, method: :get, class: "contents" do |f| %%>
      <%%%= f.select :per_page, [10, 25, 50, 100], { selected: params[:per_page] || 25 }, 
        data: { component: "select", action: "change->this.form.requestSubmit()" } %%>
    <%%% end %%>
    <span class="text-sm text-muted-foreground">per page</span>
  </div>
  <%%%= pagination_nav(@pagy) %%>
</div>
```

---

## Real-World Patterns

### In a Table Footer

```erb
<%%%= render "components/card" do %%>
  <%%%= render "components/card/content", spacing: :full do %%>
    <%%%= render "components/table" do %%>
      <%%# Table content %%>
    <%%% end %%>
  <%%% end %%>
  
  <%%%= render "components/card/footer", align: :between do %%>
    <p class="text-sm text-muted-foreground">
      <%%%= @pagy.count %%> total records
    </p>
    <%%%= pagination_nav(@pagy) %%>
  <%%% end %%>
<%%% end %%>
```

### With Turbo Frames

```erb
<%%%= turbo_frame_tag "users_list" do %%>
  <table data-component="table">
    <%%# Table content %%>
  </table>
  
  <%%%= pagination_nav(@pagy) %%>
<%%% end %%>
```

### Infinite Scroll Trigger

```erb
<%%% if @pagy.next %%>
  <%%%= turbo_frame_tag "page_#{@pagy.next}", 
    src: paginated_path(@pagy, @pagy.next),
    loading: :lazy do %%>
    <div class="flex justify-center py-4">
      <span class="text-sm text-muted-foreground">Loading more...</span>
    </div>
  <%%% end %%>
<%%% end %%>
```

---

## Theme Variables

```css
var(--border)
var(--background)
var(--foreground)
var(--muted-foreground)
var(--accent)
var(--accent-foreground)
var(--primary)
var(--primary-foreground)
```

---

## Customization

### Custom Page Size

```ruby
# In controller
@pagy, @records = pagy(Record.all, items: 50)
```

### Custom Window

```ruby
# In controller - show more page numbers
@pagy, @records = pagy(Record.all, size: [2, 4, 4, 2])
```

### Compact Pagination

```erb
<%%%= pagination_nav(@pagy, css_classes: "scale-90") %%%>
```

---

## Accessibility

- Uses semantic `<nav>` with `aria-label="Pagination"`
- Current page has `aria-current="page"`
- Disabled links have `aria-disabled="true"`
- Previous/Next have descriptive text (can use `sr-only`)
- Focus states are clearly visible

---

## File Structure

```
app/views/components/
├── _pagination.html.erb
└── pagination/
    ├── _content.html.erb
    ├── _item.html.erb
    ├── _link.html.erb
    ├── _previous.html.erb
    ├── _next.html.erb
    └── _ellipsis.html.erb

app/assets/stylesheets/pagination.css
app/helpers/maquina_components/pagination_helper.rb
docs/pagination.md
```

---

## Migration Notes

### From Pagy Built-in Helpers

Replace Pagy's default helpers with maquina_components:

**Before:**
```erb
<%%== pagy_nav(@pagy) %%%>
```

**After:**
```erb
<%%%= pagination_nav(@pagy) %%%>
```

The new helpers provide consistent styling with the rest of your components.
