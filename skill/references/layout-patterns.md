# Layout Patterns

Page structure, grid systems, and responsive design patterns using maquina_components.

---

## Page Structure

### Standard App Layout

The sidebar + inset pattern provides the foundation for dashboard-style applications:

```erb
<!DOCTYPE html>
<html lang="<%= I18n.locale %>" class="h-full">
<head>
  <title><%= content_for(:title) || "App" %></title>
  <%= csrf_meta_tags %>
  <%= csp_meta_tag %>
  <%= stylesheet_link_tag "application", data_turbo_track: "reload" %>
  <%= javascript_importmap_tags %>
</head>

<body class="h-full overflow-hidden bg-background font-sans antialiased">
  <%= render "components/sidebar/provider", 
      default_open: app_sidebar_open?,
      variant: :inset do %>
    
    <%= render "layouts/sidebar" %>
    
    <%= render "components/sidebar/inset" do %>
      <%= render "components/header" do %>
        <%= render "components/sidebar/trigger", icon_name: :panel_left %>
        
        <div class="flex-1">
          <%= yield :header %>
        </div>
        
        <div class="flex items-center gap-2">
          <%= yield :header_actions %>
        </div>
      <% end %>
      
      <main class="flex-1 overflow-y-auto p-6">
        <%= yield %>
      </main>
    <% end %>
  <% end %>
</body>
</html>
```

### Public Page Layout (No Sidebar)

For public-facing pages like booking pages:

```erb
<!DOCTYPE html>
<html lang="<%= I18n.locale %>" class="h-full">
<head>
  <title><%= content_for(:title) %></title>
  <%= csrf_meta_tags %>
  <%= stylesheet_link_tag "application", data_turbo_track: "reload" %>
  <%= javascript_importmap_tags %>
</head>

<body class="min-h-full bg-background font-sans antialiased">
  <header class="border-b bg-card">
    <div class="container mx-auto px-4 py-4">
      <%= yield :header %>
    </div>
  </header>
  
  <main class="container mx-auto px-4 py-8">
    <%= yield %>
  </main>
  
  <footer class="border-t bg-muted/50 mt-auto">
    <div class="container mx-auto px-4 py-6">
      <%= yield :footer %>
    </div>
  </footer>
</body>
</html>
```

---

## Content Layouts

### Dashboard Page

Stats cards at top, main content below:

```erb
<% content_for :title, t(".title") %>

<% content_for :header do %>
  <%= breadcrumbs({ t("nav.home") => root_path }, t(".title")) %>
<% end %>

<div class="space-y-6">
  <%# Stats Row %>
  <div class="grid gap-4 md:grid-cols-2 lg:grid-cols-4">
    <%= render "dashboard/stat_card", 
        title: t(".stats.revenue"),
        value: format_money(@stats[:revenue]),
        trend: @stats[:revenue_trend],
        trend_label: t(".stats.vs_last_month") %>
    
    <%= render "dashboard/stat_card",
        title: t(".stats.bookings"),
        value: @stats[:bookings_count],
        trend: @stats[:bookings_trend] %>
    
    <%# More stat cards... %>
  </div>
  
  <%# Main Content Grid %>
  <div class="grid gap-6 lg:grid-cols-3">
    <%# Primary content - 2 columns %>
    <div class="lg:col-span-2 space-y-6">
      <%= render "dashboard/bookings_table", bookings: @today_bookings %>
    </div>
    
    <%# Sidebar content - 1 column %>
    <div class="space-y-6">
      <%= render "dashboard/activity_feed", activities: @recent_activities %>
      <%= render "dashboard/quick_actions" %>
    </div>
  </div>
</div>
```

### List Page

Header with actions, table/list, pagination:

```erb
<% content_for :title, t(".title") %>

<% content_for :header do %>
  <%= breadcrumbs({ t("nav.home") => root_path }, t(".title")) %>
<% end %>

<% content_for :header_actions do %>
  <%= link_to new_booking_path, data: { component: "button", variant: "primary" } do %>
    <%= icon_for :plus, class: "size-4 mr-1" %><%= t(".new") %>
  <% end %>
<% end %>

<%= render "components/card" do %>
  <%= render "components/card/header", layout: :row do %>
    <div>
      <%= render "components/card/title", text: t(".title") %>
      <%= render "components/card/description", text: t(".description") %>
    </div>
    <%= render "components/card/action" do %>
      <%# Filters or view toggles %>
      <%= render "bookings/filters", filter: @filter %>
    <% end %>
  <% end %>
  
  <%= render "components/card/content" do %>
    <% if @bookings.any? %>
      <%= render "components/table", container: false do %>
        <%= render "bookings/table_header" %>
        <%= render "components/table/body" do %>
          <% @bookings.each do |booking| %>
            <%= render "bookings/table_row", booking: booking %>
          <% end %>
        <% end %>
      <% end %>
    <% else %>
      <%= render "bookings/empty_state" %>
    <% end %>
  <% end %>
  
  <% if @pagy.pages > 1 %>
    <%= render "components/card/footer", align: :between do %>
      <span class="text-sm text-muted-foreground">
        <%= t(".showing", from: @pagy.from, to: @pagy.to, count: @pagy.count) %>
      </span>
      <%= pagination_nav(@pagy, :bookings_path, show_labels: false) %>
    <% end %>
  <% end %>
<% end %>
```

### Detail/Show Page

Resource detail with sections:

```erb
<% content_for :title, @booking.title %>

<% content_for :header do %>
  <%= breadcrumbs({ 
    t("nav.home") => root_path, 
    t("nav.bookings") => bookings_path 
  }, @booking.title) %>
<% end %>

<% content_for :header_actions do %>
  <%= render "bookings/header_actions", booking: @booking %>
<% end %>

<div class="grid gap-6 lg:grid-cols-3">
  <%# Main content %>
  <div class="lg:col-span-2 space-y-6">
    <%= render "components/card" do %>
      <%= render "components/card/header" do %>
        <%= render "components/card/title", text: t(".details") %>
      <% end %>
      <%= render "components/card/content" do %>
        <%= render "bookings/detail_fields", booking: @booking %>
      <% end %>
    <% end %>
    
    <%= render "components/card" do %>
      <%= render "components/card/header" do %>
        <%= render "components/card/title", text: t(".history") %>
      <% end %>
      <%= render "components/card/content" do %>
        <%= render "bookings/history", booking: @booking %>
      <% end %>
    <% end %>
  </div>
  
  <%# Sidebar %>
  <div class="space-y-6">
    <%= render "bookings/status_card", booking: @booking %>
    <%= render "bookings/client_card", client: @booking.client %>
  </div>
</div>
```

### Form Page

Simple centered form layout:

```erb
<% content_for :title, t(".title") %>

<% content_for :header do %>
  <%= breadcrumbs({
    t("nav.home") => root_path,
    t("nav.bookings") => bookings_path
  }, t(".title")) %>
<% end %>

<div class="max-w-2xl mx-auto">
  <%= render "components/card" do %>
    <%= render "components/card/header" do %>
      <%= render "components/card/title", text: t(".title") %>
      <%= render "components/card/description", text: t(".description") %>
    <% end %>
    <%= render "components/card/content" do %>
      <%= render "bookings/form", booking: @booking %>
    <% end %>
  <% end %>
</div>
```

---

## Grid Patterns

### Responsive Column Grids

```erb
<%# 2 columns on tablet, 4 on desktop %>
<div class="grid gap-4 md:grid-cols-2 lg:grid-cols-4">
  ...
</div>

<%# 2 columns, main + sidebar %>
<div class="grid gap-6 lg:grid-cols-3">
  <div class="lg:col-span-2">Main content</div>
  <div>Sidebar</div>
</div>

<%# Equal columns %>
<div class="grid gap-4 md:grid-cols-2">
  <div>Left</div>
  <div>Right</div>
</div>

<%# Three equal columns %>
<div class="grid gap-4 md:grid-cols-2 lg:grid-cols-3">
  ...
</div>
```

### Auto-fit Cards Grid

```erb
<%# Cards that auto-fit available space %>
<div class="grid gap-4 grid-cols-[repeat(auto-fit,minmax(280px,1fr))]">
  <% @services.each do |service| %>
    <%= render "services/card", service: service %>
  <% end %>
</div>
```

---

## Card Patterns

### Stats Card

```erb
<%# _stat_card.html.erb %>
<%# locals: (title:, value:, trend: nil, trend_label: nil, icon: nil) %>

<%= render "components/card" do %>
  <%= render "components/card/header", css_classes: "pb-2" do %>
    <div class="flex items-center justify-between">
      <%= render "components/card/title", text: title, size: :sm %>
      <% if icon %>
        <%= icon_for icon, class: "size-4 text-muted-foreground" %>
      <% end %>
    </div>
  <% end %>
  <%= render "components/card/content", css_classes: "pt-0" do %>
    <div class="text-2xl font-bold"><%= value %></div>
    <% if trend %>
      <div class="flex items-center gap-1 text-sm <%= trend_color(trend) %>">
        <%= icon_for trend_icon(trend), class: "size-4" %>
        <%= format_trend(trend) %>
      </div>
    <% end %>
    <% if trend_label %>
      <p class="text-xs text-muted-foreground mt-1"><%= trend_label %></p>
    <% end %>
  <% end %>
<% end %>
```

### Action Card

Card with prominent action button:

```erb
<%= render "components/card" do %>
  <%= render "components/card/header" do %>
    <%= render "components/card/title", text: t(".title") %>
    <%= render "components/card/description", text: t(".description") %>
  <% end %>
  <%= render "components/card/content" do %>
    <%# Card content %>
  <% end %>
  <%= render "components/card/footer" do %>
    <%= link_to t(".action"), action_path, 
        data: { component: "button", variant: "primary" } %>
  <% end %>
<% end %>
```

### Card List Item

Using card as list item:

```erb
<div class="space-y-4">
  <% @items.each do |item| %>
    <%= render "components/card", css_classes: "hover:border-primary/50 transition-colors" do %>
      <%= render "components/card/content", css_classes: "p-4" do %>
        <div class="flex items-center justify-between">
          <div class="flex items-center gap-3">
            <div class="flex h-10 w-10 items-center justify-center rounded-full bg-muted">
              <%= icon_for item_icon(item), class: "size-5" %>
            </div>
            <div>
              <p class="font-medium"><%= item.name %></p>
              <p class="text-sm text-muted-foreground"><%= item.description %></p>
            </div>
          </div>
          <%= render "components/badge", variant: status_variant(item.status) do %>
            <%= item.status.humanize %>
          <% end %>
        </div>
      <% end %>
    <% end %>
  <% end %>
</div>
```

---

## Responsive Patterns

### Mobile-First Approach

Always start with mobile layout, add breakpoints for larger screens:

```erb
<%# Mobile: stack, Tablet+: side by side %>
<div class="flex flex-col md:flex-row gap-4">
  <div class="md:w-1/3">Sidebar</div>
  <div class="md:w-2/3">Main</div>
</div>

<%# Mobile: full width, Desktop: max width %>
<div class="w-full max-w-2xl mx-auto">
  ...
</div>

<%# Hide on mobile, show on desktop %>
<div class="hidden lg:block">Desktop only</div>

<%# Show on mobile, hide on desktop %>
<div class="lg:hidden">Mobile only</div>
```

### Breakpoint Reference

| Prefix | Min Width | Typical Device |
|--------|-----------|----------------|
| (none) | 0px | Mobile phones |
| `sm:` | 640px | Large phones |
| `md:` | 768px | Tablets |
| `lg:` | 1024px | Laptops |
| `xl:` | 1280px | Desktops |
| `2xl:` | 1536px | Large desktops |

### Responsive Table Pattern

Table on desktop, cards on mobile:

```erb
<%# Desktop: Table %>
<div class="hidden md:block">
  <%= render "components/table" do %>
    ...
  <% end %>
</div>

<%# Mobile: Card list %>
<div class="md:hidden space-y-4">
  <% @items.each do |item| %>
    <%= render "items/mobile_card", item: item %>
  <% end %>
</div>
```

---

## Spacing Patterns

### Vertical Sections

```erb
<%# Page sections with consistent spacing %>
<div class="space-y-6">
  <section>...</section>
  <section>...</section>
</div>

<%# Tighter spacing %>
<div class="space-y-4">...</div>

<%# Looser spacing %>
<div class="space-y-8">...</div>
```

### Content Containers

```erb
<%# Constrained content width %>
<div class="max-w-2xl">...</div>      <%# ~672px - Forms %>
<div class="max-w-4xl">...</div>      <%# ~896px - Content %>
<div class="max-w-6xl">...</div>      <%# ~1152px - Wide content %>
<div class="max-w-7xl">...</div>      <%# ~1280px - Full pages %>

<%# Centered constrained %>
<div class="max-w-2xl mx-auto">...</div>
```

### Card Padding

```erb
<%# Standard card padding is p-6 %>
<%= render "components/card/content" do %>...content...<% end %>

<%# Override for tighter content %>
<%= render "components/card/content", css_classes: "p-4" do %>...tighter...<% end %>

<%# Remove padding for edge-to-edge table %>
<%= render "components/card/content", css_classes: "p-0" do %>
  <%= render "components/table", container: false do %>...<% end %>
<% end %>
```

---

## Common Partial Patterns

### Page Header Partial

```erb
<%# app/views/shared/_page_header.html.erb %>
<%# locals: (title:, description: nil, actions: nil) %>

<div class="flex flex-col gap-4 md:flex-row md:items-center md:justify-between">
  <div>
    <h1 class="text-2xl font-bold tracking-tight"><%= title %></h1>
    <% if description %>
      <p class="text-muted-foreground"><%= description %></p>
    <% end %>
  </div>
  <% if actions %>
    <div class="flex items-center gap-2">
      <%= actions %>
    </div>
  <% end %>
</div>
```

### Section Header Partial

```erb
<%# app/views/shared/_section_header.html.erb %>
<%# locals: (title:, description: nil) %>

<div class="mb-4">
  <h2 class="text-lg font-semibold"><%= title %></h2>
  <% if description %>
    <p class="text-sm text-muted-foreground"><%= description %></p>
  <% end %>
</div>
```

### Row Actions Partial

```erb
<%# app/views/shared/_row_actions.html.erb %>
<%# locals: (edit_path:, delete_path:, additional_items: nil) %>

<%= render "components/dropdown_menu" do %>
  <%= render "components/dropdown_menu/trigger", as_child: true do %>
    <button type="button"
            data-component="button"
            data-variant="ghost"
            data-size="icon-sm"
            data-dropdown-menu-target="trigger"
            data-action="dropdown-menu#toggle">
      <%= icon_for :more_horizontal, class: "size-4" %>
    </button>
  <% end %>
  <%= render "components/dropdown_menu/content", align: :end do %>
    <%= render "components/dropdown_menu/item", href: edit_path do %>
      <%= icon_for :edit, class: "size-4" %> <%= t("actions.edit") %>
    <% end %>
    
    <% if additional_items %>
      <%= additional_items %>
    <% end %>
    
    <%= render "components/dropdown_menu/separator" %>
    
    <%= render "components/dropdown_menu/item", 
        href: delete_path, 
        method: :delete,
        variant: :destructive,
        data: { turbo_confirm: t("confirm.delete") } do %>
      <%= icon_for :trash, class: "size-4" %> <%= t("actions.delete") %>
    <% end %>
  <% end %>
<% end %>
```

---

## Dark Mode

Components automatically support dark mode via CSS variables. Add `.dark` class to `<html>`:

```erb
<html lang="<%= I18n.locale %>" class="h-full <%= dark_mode? ? 'dark' : '' %>">
```

Toggle implementation:

```erb
<%# Dark mode toggle button %>
<button type="button"
        data-controller="theme-toggle"
        data-action="theme-toggle#toggle"
        data-component="button"
        data-variant="ghost"
        data-size="icon">
  <%= icon_for :sun, class: "size-4 dark:hidden" %>
  <%= icon_for :moon, class: "size-4 hidden dark:block" %>
</button>
```

```javascript
// theme_toggle_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  toggle() {
    document.documentElement.classList.toggle("dark")
    const isDark = document.documentElement.classList.contains("dark")
    localStorage.setItem("theme", isDark ? "dark" : "light")
  }
}
```
