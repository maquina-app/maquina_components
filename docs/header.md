# Header

> A page header component for use with sidebar layouts.

---

## Quick Reference

### Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `css_classes` | String | `""` | Additional CSS classes |
| `**html_options` | Hash | `{}` | HTML attributes (`id:`, `data:`, etc.) |

### Data Attributes

**Component Identifier**

| Attribute | Element | Description |
|-----------|---------|-------------|
| `data-component="header"` | `<header>` | Main component identifier |

---

## Basic Usage

```erb
<%%= render "components/header" do %>
  <%%= render "components/sidebar/trigger" %>
  <%%= render "components/separator", orientation: :vertical %>
  <%%= breadcrumbs({"Dashboard" => dashboard_path}, @page_title) %>
<%% end %>
```

---

## Examples

### With Breadcrumbs

```erb
<%%= render "components/header" do %>
  <%%= render "components/sidebar/trigger" %>
  <%%= render "components/separator", orientation: :vertical %>
  <%%= breadcrumbs(
    {"Dashboard" => dashboard_path, "Users" => users_path},
    "John Doe"
  ) %>
<%% end %>
```

### With Actions

```erb
<%%= render "components/header" do %>
  <%%= render "components/sidebar/trigger" %>
  <%%= render "components/separator", orientation: :vertical %>
  <%%= breadcrumbs({"Projects" => projects_path}, @project.name) %>
  
  <div class="ml-auto flex items-center gap-2">
    <%%= link_to "Edit", edit_project_path(@project), data: { component: "button", variant: "outline", size: "sm" } %>
    <%%= link_to "Delete", project_path(@project), data: { component: "button", variant: "destructive", size: "sm" }, method: :delete %>
  </div>
<%% end %>
```

### With Search

```erb
<%%= render "components/header" do %>
  <%%= render "components/sidebar/trigger" %>
  <%%= render "components/separator", orientation: :vertical %>
  
  <div class="flex-1 max-w-md">
    <%%= form_with url: search_path, method: :get, class: "relative" do |f| %>
      <%%= icon_for :search, class: "absolute left-3 top-1/2 -translate-y-1/2 size-4 text-muted-foreground" %>
      <%%= f.search_field :q, data: { component: "input" }, class: "pl-10 h-8", placeholder: "Search..." %>
    <%% end %>
  </div>
  
  <div class="ml-auto flex items-center gap-2">
    <%%= render "components/dropdown_menu" do %>
      <%# User menu %>
    <%% end %>
  </div>
<%% end %>
```

### Simple Page Title

```erb
<%%= render "components/header" do %>
  <%%= render "components/sidebar/trigger" %>
  <%%= render "components/separator", orientation: :vertical %>
  <h1 class="text-sm font-medium">Dashboard</h1>
<%% end %>
```

---

## Real-World Patterns

### Standard App Header

```erb
<%%= render "components/header" do %>
  <%# Mobile menu trigger %>
  <%%= render "components/sidebar/trigger" %>
  <%%= render "components/separator", orientation: :vertical %>
  
  <%# Breadcrumbs %>
  <%%= responsive_breadcrumbs(@breadcrumb_links, @breadcrumb_current) %>
  
  <%# Actions %>
  <div class="ml-auto flex items-center gap-3">
    <%# Notifications %>
    <button type="button" data-component="button" data-variant="ghost" data-size="icon-sm" class="relative">
      <%%= icon_for :bell, class: "size-4" %>
      <span class="absolute -top-1 -right-1 size-4 rounded-full bg-destructive text-destructive-foreground text-xs flex items-center justify-center">3</span>
    </button>
    
    <%# User menu %>
    <%%= dropdown_menu do |menu| %>
      <%% menu.trigger variant: :ghost, size: :sm do %>
        <%%= image_tag current_user.avatar, class: "size-6 rounded-full" %>
      <%% end %>
      <%% menu.content align: :end do %>
        <%% menu.label { current_user.name } %>
        <%% menu.separator %>
        <%% menu.item "Profile", href: profile_path, icon: :user %>
        <%% menu.item "Settings", href: settings_path, icon: :settings %>
        <%% menu.separator %>
        <%% menu.item "Logout", href: logout_path, method: :delete, icon: :log_out %>
      <%% end %>
    <%% end %>
  </div>
<%% end %>
```

### With Tabs

```erb
<%%= render "components/header" do %>
  <%%= render "components/sidebar/trigger" %>
  <%%= render "components/separator", orientation: :vertical %>
  
  <nav class="flex items-center gap-1">
    <%%= link_to "Overview", project_path(@project), 
      class: "px-3 py-1.5 text-sm rounded-md #{'bg-accent text-accent-foreground' if current_page?(project_path(@project))}" %>
    <%%= link_to "Tasks", project_tasks_path(@project),
      class: "px-3 py-1.5 text-sm rounded-md #{'bg-accent text-accent-foreground' if current_page?(project_tasks_path(@project))}" %>
    <%%= link_to "Settings", edit_project_path(@project),
      class: "px-3 py-1.5 text-sm rounded-md #{'bg-accent text-accent-foreground' if current_page?(edit_project_path(@project))}" %>
  </nav>
<%% end %>
```

---

## Theme Variables

```css
var(--background)
var(--border)
```

---

## Customization

### Fixed Height

The header has a fixed height for consistency with sidebar layouts:

```css
[data-component="header"] {
  @apply h-14;
}
```

### Sticky Header

```erb
<%%= render "components/header", css_classes: "sticky top-0 z-50" do %>
  <%# ... %>
<%% end %>
```

---

## Accessibility

- Uses semantic `<header>` element
- Works with skip links for keyboard navigation
- Provides consistent landmark for screen readers

---

## File Structure

```
app/views/components/
└── _header.html.erb

app/assets/stylesheets/header.css
docs/header.md
```
