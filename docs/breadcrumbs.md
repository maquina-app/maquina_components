# Breadcrumbs

> A composable breadcrumb navigation component with responsive collapsing support.

---

## Quick Reference

### Parts

| Partial | Description | Required |
|---------|-------------|----------|
| `components/breadcrumbs` | Nav container | Yes |
| `components/breadcrumbs/list` | Ordered list wrapper | Yes |
| `components/breadcrumbs/item` | List item wrapper | Yes |
| `components/breadcrumbs/link` | Clickable navigation link | Yes* |
| `components/breadcrumbs/page` | Current page (no link) | Yes* |
| `components/breadcrumbs/separator` | Visual separator between items | Yes |
| `components/breadcrumbs/ellipsis` | Collapsed items indicator | No |

*Use `link` for navigable items, `page` for current location

### Helper Methods

| Method | Description |
|--------|-------------|
| `breadcrumbs(links, current_page)` | Simple breadcrumbs from hash |
| `responsive_breadcrumbs(links, current_page)` | Auto-collapsing breadcrumbs |

### Parameters

#### `breadcrumbs` / `responsive_breadcrumbs` Helper

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `links` | Hash | `{}` | `{"Text" => path}` pairs |
| `current_page` | String | `nil` | Current page text (no link) |
| `css_classes` | String | `""` | Additional CSS classes |

#### `breadcrumbs/separator`

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `icon` | Symbol | `:chevron_right` | Icon name (pass `:custom` to use block content) |
| `css_classes` | String | `""` | Additional CSS classes |
| `**html_options` | Hash | `{}` | Additional HTML attributes |

#### All Other Partials

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `css_classes` | String | `""` | Additional CSS classes |
| `**html_options` | Hash | `{}` | Additional HTML attributes |

### Data Attributes

**Component Identifiers**

| Attribute | Element | Description |
|-----------|---------|-------------|
| `data-component="breadcrumbs"` | Nav container | Main component identifier |
| `data-breadcrumb-part="list"` | `<ol>` | Ordered list wrapper |
| `data-breadcrumb-part="item"` | `<li>` | List item wrapper |
| `data-breadcrumb-part="link"` | `<a>` | Navigation link |
| `data-breadcrumb-part="page"` | `<span>` | Current page indicator |
| `data-breadcrumb-part="separator"` | `<li>` | Visual separator |
| `data-breadcrumb-part="ellipsis"` | `<span>` | Collapsed items indicator |

**Size Variants**

| Attribute | Description |
|-----------|-------------|
| `data-size="sm"` | Smaller text and gaps |

**Stimulus Controller**

| Attribute | Description |
|-----------|-------------|
| `data-controller="breadcrumb"` | Enables responsive collapsing |
| `data-breadcrumb-target="item"` | Marks items that can be hidden |
| `data-breadcrumb-target="ellipsis"` | Ellipsis element |
| `data-breadcrumb-target="ellipsisSeparator"` | Separator next to ellipsis |
| `data-auto-collapse` | Marks wrapper with auto-collapse enabled |

---

## Basic Usage

### Using Helper Methods

```erb
<%%= breadcrumbs({"Home" => root_path, "Users" => users_path}, "John Doe") %>
```

Renders:
```
Home > Users > John Doe
```

### Responsive (Auto-Collapsing)

```erb
<%%= responsive_breadcrumbs(
  {
    "Home" => root_path,
    "Documentation" => docs_path,
    "Components" => components_path,
    "Forms" => forms_path
  },
  "Input"
) %>
```

On narrow screens, middle items collapse to an ellipsis:
```
Home > ... > Input
```

### Using Composable Partials

```erb
<%%= render "components/breadcrumbs" do %>
  <%%= render "components/breadcrumbs/list" do %>
    <%%= render "components/breadcrumbs/item" do %>
      <%%= render "components/breadcrumbs/link", href: root_path do %>
        Home
      <%% end %>
    <%% end %>
    
    <%%= render "components/breadcrumbs/separator" %>
    
    <%%= render "components/breadcrumbs/item" do %>
      <%%= render "components/breadcrumbs/link", href: users_path do %>
        Users
      <%% end %>
    <%% end %>
    
    <%%= render "components/breadcrumbs/separator" %>
    
    <%%= render "components/breadcrumbs/item" do %>
      <%%= render "components/breadcrumbs/page" do %>
        John Doe
      <%% end %>
    <%% end %>
  <%% end %>
<%% end %>
```

---

## Examples

### With Icons

```erb
<%%= render "components/breadcrumbs" do %>
  <%%= render "components/breadcrumbs/list" do %>
    <%%= render "components/breadcrumbs/item" do %>
      <%%= render "components/breadcrumbs/link", href: root_path do %>
        <%%= icon_for(:home) %>
        Home
      <%% end %>
    <%% end %>
    
    <%%= render "components/breadcrumbs/separator" %>
    
    <%%= render "components/breadcrumbs/item" do %>
      <%%= render "components/breadcrumbs/page" do %>
        <%%= icon_for(:file) %>
        Document
      <%% end %>
    <%% end %>
  <%% end %>
<%% end %>
```

### Custom Separator Icon

Use a different icon by passing the `icon:` parameter:

```erb
<%# Use slash icon %>
<%%= render "components/breadcrumbs/separator", icon: :slash %>

<%# Use dot icon %>
<%%= render "components/breadcrumbs/separator", icon: :dot %>

<%# Use arrow-right icon %>
<%%= render "components/breadcrumbs/separator", icon: :arrow_right %>
```

### Fully Custom Separator Content

For complete control over separator content, use `icon: :custom` with a block:

```erb
<%%= render "components/breadcrumbs/separator", icon: :custom do %>
  <span class="text-muted-foreground">/</span>
<%% end %>

<%# Or with custom SVG %>
<%%= render "components/breadcrumbs/separator", icon: :custom do %>
  <svg class="size-4" viewBox="0 0 24 24" fill="currentColor">
    <circle cx="12" cy="12" r="3" />
  </svg>
<%% end %>
```

### With Ellipsis (Manual)

```erb
<%%= render "components/breadcrumbs" do %>
  <%%= render "components/breadcrumbs/list" do %>
    <%%= render "components/breadcrumbs/item" do %>
      <%%= render "components/breadcrumbs/link", href: root_path do %>
        Home
      <%% end %>
    <%% end %>
    
    <%%= render "components/breadcrumbs/separator" %>
    
    <%%= render "components/breadcrumbs/item" do %>
      <%%= render "components/breadcrumbs/ellipsis" %>
    <%% end %>
    
    <%%= render "components/breadcrumbs/separator" %>
    
    <%%= render "components/breadcrumbs/item" do %>
      <%%= render "components/breadcrumbs/page" do %>
        Current Page
      <%% end %>
    <%% end %>
  <%% end %>
<%% end %>
```

### Hidden on Mobile

```erb
<%%= render "components/breadcrumbs/item", css_classes: "hidden md:inline-flex" do %>
  <%%= render "components/breadcrumbs/link", href: middle_path do %>
    Middle Section
  <%% end %>
<%% end %>
```

---

## Real-World Patterns

### In Header with Sidebar

```erb
<%%= render "components/header" do %>
  <%%= render "components/sidebar/trigger", icon_name: :menu %>
  <%%= render "components/separator", orientation: :vertical %>
  
  <%%= breadcrumbs(
    {"Dashboard" => dashboard_path},
    @page_title
  ) %>
<%% end %>
```

### Dynamic from Controller

```ruby
# In controller
def show
  @breadcrumb_links = {
    "Home" => root_path,
    @category.name => category_path(@category)
  }
  @breadcrumb_current = @product.name
end
```

```erb
<%# In view %>
<%%= breadcrumbs(@breadcrumb_links, @breadcrumb_current) %>
```

### With Turbo Frame

```erb
<%%= render "components/breadcrumbs", data: { turbo_frame: "_top" } do %>
  <%# Links navigate the top frame %>
<%% end %>
```

---

## Stimulus Controller

The `breadcrumb_controller.js` handles responsive collapsing.

### How It Works

1. Monitors container width on resize
2. When items overflow, hides middle items (not first/last)
3. Shows ellipsis element in place of hidden items
4. Recalculates on window resize

### Targets

| Target | Purpose |
|--------|---------|
| `item` | Middle items that can be hidden |
| `ellipsis` | Ellipsis element (shown when items hidden) |
| `ellipsisSeparator` | Separator next to ellipsis |

### Manual Wiring

If not using `responsive_breadcrumbs` helper:

```erb
<%%= render "components/breadcrumbs", responsive: true do %>
  <%%= render "components/breadcrumbs/list" do %>
    <%# First item - never hidden %>
    <%%= render "components/breadcrumbs/item" do %>
      <%%= render "components/breadcrumbs/link", href: root_path do %>
        Home
      <%% end %>
    <%% end %>
    
    <%%= render "components/breadcrumbs/separator" %>
    
    <%# Ellipsis - hidden by default, shown when items collapse %>
    <%%= render "components/breadcrumbs/item", 
      css_classes: "hidden", 
      data: {breadcrumb_target: "ellipsis"} do %>
      <%%= render "components/breadcrumbs/ellipsis" %>
    <%% end %>
    
    <%%= render "components/breadcrumbs/separator", 
      css_classes: "hidden",
      data: {breadcrumb_target: "ellipsisSeparator"} %>
    
    <%# Middle items - can be hidden %>
    <%%= render "components/breadcrumbs/item", 
      data: {breadcrumb_target: "item"} do %>
      <%%= render "components/breadcrumbs/link", href: docs_path do %>
        Documentation
      <%% end %>
    <%% end %>
    
    <%%= render "components/breadcrumbs/separator" %>
    
    <%# Last item - never hidden %>
    <%%= render "components/breadcrumbs/item" do %>
      <%%= render "components/breadcrumbs/page" do %>
        Current
      <%% end %>
    <%% end %>
  <%% end %>
<%% end %>
```

---

## Theme Variables

The component uses these CSS variables:

```css
var(--foreground)        /* text color */
var(--muted-foreground)  /* secondary text color */
```

---

## Customization

### Custom Link Styles

```erb
<%%= render "components/breadcrumbs/link", 
  href: path,
  css_classes: "text-blue-600 hover:text-blue-800" do %>
  Custom Styled
<%% end %>
```

### Compact Size

```erb
<%%= render "components/breadcrumbs", data: {size: "sm"} do %>
  <%# Smaller text and gaps %>
<%% end %>
```

---

## Accessibility

- Uses semantic `<nav>`, `<ol>`, `<li>` structure
- `aria-label="Breadcrumb"` on nav element
- `aria-current="page"` on current item
- Separators have `aria-hidden="true"` and `role="presentation"`
- `.sr-only` text on ellipsis ("More")

---

## File Structure

```
app/views/components/
├── _breadcrumbs.html.erb
└── breadcrumbs/
    ├── _list.html.erb
    ├── _item.html.erb
    ├── _link.html.erb
    ├── _page.html.erb
    ├── _separator.html.erb
    └── _ellipsis.html.erb

app/assets/stylesheets/breadcrumbs.css
app/javascript/controllers/breadcrumb_controller.js
app/helpers/maquina_components/breadcrumbs_helper.rb
docs/breadcrumbs.md
```

---

## Migration Notes

### From Previous Version

**Fixed:**
- Helper paths corrected (`breadcrumb` → `breadcrumbs`)
- All partials now accept `**html_options`

**Changed:**
- Inline Tailwind moved to `breadcrumbs.css`
- Data attributes added: `data-breadcrumb-part="..."`
- Separator now uses `icon:` parameter (default: `:chevron_right`)
- For custom separator content, use `icon: :custom` with a block

**New:**
- `responsive_breadcrumbs` helper for auto-collapse
- Stimulus targets wired in responsive mode
- `icon:` parameter on separator for easy icon switching

**Deprecated:**
- Using block without `icon: :custom` — block is now ignored unless `icon: :custom` is passed
