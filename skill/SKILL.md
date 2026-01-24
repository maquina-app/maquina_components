---
name: maquina-ui-standards
description: Build consistent, accessible UIs in Rails using maquina_components. Use this skill when implementing UI for features, creating views, building forms, or reviewing UI specs. Triggers on view creation, UI implementation, form building, layout design, or mentions of maquina_components usage.
---

# Maquina UI Standards

Build production-quality Rails UIs with maquina_components — ERB partials styled with Tailwind CSS 4 and data attributes, inspired by shadcn/ui.

## When to Use This Skill

- Implementing UI for a feature spec
- Creating new views or pages
- Building forms with validation
- Designing page layouts
- Reviewing UI implementation for consistency

## Quick Reference

### Component Rendering

```erb
<%# Partial components %>
<%= render "components/card" do %>
  <%= render "components/card/header" do %>
    <%= render "components/card/title", text: "Title" %>
  <% end %>
<% end %>

<%# Data-attribute components (forms) %>
<%= f.text_field :email, data: { component: "input" } %>
<%= f.submit "Save", data: { component: "button", variant: "primary" } %>
```

### Decision Framework

| Need | Component | Why |
|------|-----------|-----|
| Container with header/content/footer | **Card** | Structured content grouping |
| Important message to user | **Alert** | Draws attention, semantic variants |
| Status indicator | **Badge** | Compact, inline status |
| Data display | **Table** | Structured rows/columns |
| No data state | **Empty** | Consistent empty patterns |
| User actions menu | **Dropdown Menu** | Accessible, keyboard-navigable |
| Selection from options | **Toggle Group** | Visual, single/multi select |
| Selection from many options | **Combobox** | Searchable, filterable |
| Date selection (inline) | **Calendar** | Always-visible date picker |
| Date selection (popover) | **Date Picker** | Compact form date input |
| Page location | **Breadcrumbs** | Navigation context |
| Large result sets | **Pagination** | Pagy integration |
| App navigation | **Sidebar** | Collapsible, persistent state |
| Temporary notifications | **Toast** | Non-intrusive feedback |
| Form inputs | **Form components** | Consistent styling via data attrs |

## File References

| File | Content |
|------|---------|
| [component-catalog.md](component-catalog.md) | All components with props, variants, examples |
| [layout-patterns.md](layout-patterns.md) | Page structure, grids, responsive design |
| [form-patterns.md](form-patterns.md) | Forms, validation, field groups |
| [turbo-integration.md](turbo-integration.md) | Frames, Streams, Morph with components |
| [spec-checklist.md](spec-checklist.md) | UI implementation checklist for specs |

## Core Principles

### 1. Composition Over Configuration

Components are small, composable building blocks. You have full flexibility in how you use them:

**Option A: Use partials as-is** — Render maquina_components partials directly for standard patterns.

**Option B: Compress complexity** — Wrap multiple partials into your own application-specific components that encode your conventions.

**Option C: Copy and adapt** — Copy component partials into your app and customize for specific needs.

```erb
<%# Option A: Direct partial usage %>
<%= render "components/card" do %>
  <%= render "components/card/header" do %>
    <%= render "components/card/title", text: @resource.name %>
  <% end %>
<% end %>

<%# Option B: Application-specific wrapper %>
<%# app/views/components/_resource_card.html.erb %>
<%= render "components/card" do %>
  <%= render "components/card/header", layout: :row do %>
    <div>
      <%= render "components/card/title", text: resource.name %>
      <%= render "components/card/description", text: resource.summary %>
    </div>
    <%= render "components/card/action" do %>
      <%= yield :actions if content_for?(:actions) %>
    <% end %>
  <% end %>
  <%= render "components/card/content" do %>
    <%= yield %>
  <% end %>
<% end %>

<%# Usage: <%= render "components/resource_card", resource: @user do %>...content...<% end %>

<%# Option C: Copied and customized for booking-specific needs %>
<%# app/views/bookings/_booking_card.html.erb - your own component %>
```

Choose the approach that best fits your use case. The goal is consistency within your application, not rigid adherence to a single pattern.

```erb
<%# ✅ GOOD: Compose from parts %>
<%= render "components/card" do %>
  <%= render "components/card/header", layout: :row do %>
    <div>
      <%= render "components/card/title", text: @resource.name %>
      <%= render "components/card/description", text: @resource.summary %>
    </div>
    <%= render "components/card/action" do %>
      <%= link_to "Edit", edit_path, data: { component: "button", variant: "outline", size: "sm" } %>
    <% end %>
  <% end %>
  <%= render "components/card/content" do %>
    <!-- Content -->
  <% end %>
<% end %>

<%# ❌ BAD: Trying to configure everything via props %>
<%= render "components/card", 
    title: @resource.name, 
    description: @resource.summary,
    action_text: "Edit",
    action_path: edit_path %>
```

### 2. Inline Errors Over Error Lists

**Always prefer inline field errors with a flash message** over an alert containing a list of all validation errors.

```erb
<%# ✅ RECOMMENDED: Inline errors + flash %>
<%= form_with model: @user, data: { component: "form" } do |f| %>
  <div data-form-part="group">
    <%= f.label :email, data: { component: "label" } %>
    <%= f.email_field :email, data: { component: "input" } %>
    <% if @user.errors[:email].any? %>
      <p data-form-part="error"><%= @user.errors[:email].first %></p>
    <% end %>
  </div>
  <%# Flash shows brief summary: "Please fix the errors below" %>
<% end %>

<%# ❌ AVOID: Alert with error list %>
<% if @user.errors.any? %>
  <%= render "components/alert", variant: :destructive do %>
    <ul>
      <% @user.errors.full_messages.each do |msg| %>
        <li><%= msg %></li>
      <% end %>
    </ul>
  <% end %>
<% end %>
```

Inline errors are more accessible — users see the problem next to the field that needs fixing. The flash provides a brief notification that something needs attention.

### 3. Robust Input Attributes

**Every input should have appropriate HTML5 attributes** for validation, accessibility, and mobile optimization:

| Attribute | Purpose | Example |
|-----------|---------|---------|
| `type` | Correct keyboard, validation | `email`, `tel`, `url`, `number` |
| `required` | Mark mandatory fields | `required: true` |
| `maxlength` | Prevent overflow, guide user | `maxlength: 100` |
| `minlength` | Minimum input | `minlength: 2` |
| `pattern` | Custom validation | `pattern: "[0-9]{10}"` |
| `inputmode` | Mobile keyboard hint | `inputmode: "numeric"` |
| `autocomplete` | Autofill hints | `autocomplete: "email"` |

```erb
<%# ✅ GOOD: Complete input attributes %>
<%= f.email_field :email,
    data: { component: "input" },
    required: true,
    maxlength: 254,
    autocomplete: "email",
    placeholder: "you@example.com" %>

<%= f.phone_field :phone,
    data: { component: "input" },
    required: true,
    maxlength: 20,
    pattern: "[+]?[0-9\\s\\-()]+",
    inputmode: "tel",
    autocomplete: "tel" %>

<%= f.text_field :name,
    data: { component: "input" },
    required: true,
    minlength: 2,
    maxlength: 100,
    autocomplete: "name" %>

<%# ❌ BAD: Missing attributes %>
<%= f.text_field :name, data: { component: "input" } %>
```

### 4. Data Attributes for Styling

Components use `data-component` and `data-*-part` attributes. CSS targets these, not classes:

```erb
<%# Component identifies itself %>
<div data-component="card">
  <div data-card-part="header">...</div>
  <div data-card-part="content">...</div>
</div>

<%# Variants via data attributes %>
<%= render "components/badge", variant: :success do %>Active<% end %>
<%# Renders: <span data-component="badge" data-variant="success">Active</span> %>
```

### 5. Form Components via Rails Helpers

Form elements don't need partials — use data attributes directly:

```erb
<%= form_with model: @user, data: { component: "form" } do |f| %>
  <div data-form-part="group">
    <%= f.label :email, data: { component: "label" } %>
    <%= f.email_field :email, data: { component: "input" } %>
  </div>
  
  <div data-form-part="actions">
    <%= f.submit "Save", data: { component: "button", variant: "primary" } %>
  </div>
<% end %>
```

### 6. Icons via Helper

Use `icon_for` helper, which delegates to your app's icon system:

```erb
<%= icon_for :check, class: "size-4" %>
<%= icon_for :chevron_right, class: "size-4 text-muted-foreground" %>
```

### 7. Theme Variables

Colors come from CSS variables (shadcn/ui convention):

| Variable | Usage |
|----------|-------|
| `--primary` / `--primary-foreground` | Primary actions, CTAs |
| `--secondary` / `--secondary-foreground` | Secondary elements |
| `--muted` / `--muted-foreground` | Subdued content |
| `--accent` / `--accent-foreground` | Highlights |
| `--destructive` / `--destructive-foreground` | Dangerous actions |
| `--card` / `--card-foreground` | Card backgrounds |
| `--border` | Borders |
| `--ring` | Focus rings |

## Implementation Workflow

### Step 1: Identify Components Needed

Read the feature spec. Map UI requirements to components:

```
Feature: User Dashboard
- Summary cards → Card (stats variant)
- User list → Table with Badge for status
- Empty state when no users → Empty
- Actions per row → Dropdown Menu
- Page navigation → Pagination
```

### Step 2: Plan Layout Structure

Decide grid/layout before coding:

```erb
<%# Dashboard layout %>
<div class="space-y-6">
  <%# Stats row %>
  <div class="grid gap-4 md:grid-cols-2 lg:grid-cols-4">
    <%= render "dashboard/stat_card", ... %>
  </div>
  
  <%# Main content %>
  <%= render "components/card" do %>
    ...
  <% end %>
</div>
```

### Step 3: Build with Components

Use component catalog, follow composition patterns.

### Step 4: Verify Against Checklist

Run through [spec-checklist.md](spec-checklist.md) before marking complete.

## Anti-Patterns

| ❌ Don't | ✅ Do Instead |
|----------|---------------|
| Inline Tailwind for component styling | Use data attributes, let CSS handle it |
| Create custom card/alert/badge divs | Use maquina_components |
| Skip empty states | Always handle zero-data case |
| Hardcode button styles | Use `data-component="button"` |
| Forget loading/disabled states | Include all interaction states |
| Mix icon libraries | Use `icon_for` consistently |
| Nest components incorrectly | Follow documented composition |
| Skip accessibility attributes | Include ARIA labels, roles |

## Haab-Specific Patterns

For the Haab project, these additional conventions apply:

### Brand Colors

Override theme variables in application.css:

```css
:root {
  --primary: oklch(0.467 0.175 3.95);      /* Dusty Rose #BE185D */
  --primary-foreground: oklch(0.985 0 0);
}
```

### Booking Status Badges

```erb
<% variant = case booking.status
   when "confirmed" then :success
   when "pending" then :warning
   when "cancelled", "no_show" then :destructive
   else :secondary
   end %>
<%= render "components/badge", variant: variant do %>
  <%= t("enums.booking.status.#{booking.status}") %>
<% end %>
```

### Money Display

```erb
<%= render "components/badge", variant: :outline do %>
  <%= format_money(service.price_cents) %>
<% end %>
```

### Time Display

```erb
<%# Use monospace for times %>
<span class="font-mono text-sm">
  <%= l(booking.starts_at, format: :time) %>
</span>
```

## Quick Component Examples

### Card with Action Header

```erb
<%= render "components/card" do %>
  <%= render "components/card/header", layout: :row do %>
    <div>
      <%= render "components/card/title", text: t(".title") %>
      <%= render "components/card/description", text: t(".description") %>
    </div>
    <%= render "components/card/action" do %>
      <%= link_to new_resource_path, data: { component: "button", variant: "primary", size: "sm" } do %>
        <%= icon_for :plus, class: "size-4 mr-1" %><%= t(".add") %>
      <% end %>
    <% end %>
  <% end %>
  <%= render "components/card/content" do %>
    <!-- Content here -->
  <% end %>
<% end %>
```

### Table with Actions

```erb
<%= render "components/table" do %>
  <%= render "components/table/header" do %>
    <%= render "components/table/row" do %>
      <%= render "components/table/head" do %><%= t(".name") %><% end %>
      <%= render "components/table/head" do %><%= t(".status") %><% end %>
      <%= render "components/table/head", css_classes: "w-10" do %>
        <span class="sr-only"><%= t(".actions") %></span>
      <% end %>
    <% end %>
  <% end %>
  <%= render "components/table/body" do %>
    <% @items.each do |item| %>
      <%= render "components/table/row" do %>
        <%= render "components/table/cell" do %><%= item.name %><% end %>
        <%= render "components/table/cell" do %>
          <%= render "components/badge", variant: status_variant(item) do %>
            <%= item.status.titleize %>
          <% end %>
        <% end %>
        <%= render "components/table/cell" do %>
          <%= render "shared/row_actions", item: item %>
        <% end %>
      <% end %>
    <% end %>
  <% end %>
<% end %>
```

### Empty State

```erb
<% if @items.empty? %>
  <%= render "components/empty" do %>
    <%= render "components/empty/header" do %>
      <%= render "components/empty/media" do %>
        <div class="flex h-16 w-16 items-center justify-center rounded-full bg-muted">
          <%= icon_for :inbox, class: "size-8 text-muted-foreground" %>
        </div>
      <% end %>
      <%= render "components/empty/title", text: t(".empty.title") %>
      <%= render "components/empty/description", text: t(".empty.description") %>
    <% end %>
    <%= render "components/empty/content" do %>
      <%= link_to t(".empty.action"), new_path, data: { component: "button", variant: "primary" } %>
    <% end %>
  <% end %>
<% end %>
```

See individual reference files for complete documentation.
