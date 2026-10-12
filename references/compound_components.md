# Compound Components Guide

> Patterns for building multi-part components like Card, Alert, Table and Sidebar.

## What Are Compound Components?

Components with multiple, related sub-parts that work together:
- **Card** → Header, Title, Description, Action, Content, Footer
- **Alert** → Icon (via `icon:`), Title, Description
- **Table** → Header, Body, Footer, Row, Head, Cell, Caption
- **Sidebar** → Provider, Sidebar, Header, Content, Group, Menu, MenuItem, MenuButton/MenuLink, Footer, Inset, Trigger
- Also: Breadcrumbs, Combobox, Drawer, Dropdown Menu, Empty, Pagination, Toast, Toggle Group, Stats

## Directory Structure

```
app/views/components/
├── _card.html.erb           # Main wrapper
└── card/                    # Sub-components
    ├── _header.html.erb
    ├── _title.html.erb
    ├── _description.html.erb
    ├── _action.html.erb
    ├── _content.html.erb
    └── _footer.html.erb
```

## Data Attribute Pattern

### Main Component

```erb
<%# app/views/components/_card.html.erb %>
<%# locals: (css_classes: "", **html_options) %>
<% merged_data = merge_component_data(html_options, component: :card) %>

<%= content_tag :div, class: css_classes.presence, data: merged_data, **html_options do %>
  <%= yield %>
<% end %>
```

### Sub-Component with Part Attribute

```erb
<%# app/views/components/card/_header.html.erb %>
<%# locals: (layout: :column, css_classes: "", **html_options) %>
<% merged_data = merge_component_data(html_options,
    card_part: :header,
    layout: (layout.to_sym == :row ? :row : nil)
  ).compact %>

<%= content_tag :div, class: css_classes.presence, data: merged_data, **html_options do %>
  <%= yield %>
<% end %>
```

`*_part` keys are component identity: `merge_component_data` never lets a caller's `data:` override them.

### CSS Selectors

Part rules are scoped under their root with `:where()`, keeping specificity at 0,1,0, inside `@layer components`:

```css
@layer components {
  /* Main component */
  [data-component="card"] {
    /* wrapper styles */
  }

  /* Sub-components use the {component}-part attribute */
  :where([data-component="card"]) [data-card-part="header"] {
    /* header styles */
  }

  :where([data-component="card"]) [data-card-part="content"] {
    /* content styles */
  }

  /* Variants on sub-components */
  :where([data-component="card"]) [data-card-part="header"]:where([data-layout="row"]) {
    flex-direction: row;
  }
}
```

## Card Component

### Structure

```
Card
├── CardHeader (optional; layout: :row puts Action beside the title)
│   ├── CardTitle (size: :sm for compact headers)
│   ├── CardDescription (optional)
│   └── CardAction (optional)
├── CardContent (spacing: :full when there is no header)
└── CardFooter (optional; align: :start/:between/:end/:center, spacing: :full)
```

### Implementation

**Leaf parts** take `text:`, `content:` or a block:

```erb
<%# card/_title.html.erb %>
<%# locals: (text: nil, content: nil, size: :default, css_classes: "", **html_options) %>
<% merged_data = merge_component_data(html_options,
    card_part: :title,
    size: (size == :sm ? :sm : nil)
  ).compact %>

<%= content_tag :div, class: css_classes.presence, data: merged_data, **html_options do %>
  <%= text.presence || content || yield %>
<% end %>
```

```erb
<%# card/_description.html.erb %>
<%# locals: (text: nil, content: nil, css_classes: "", **html_options) %>
<% merged_data = merge_component_data(html_options, card_part: :description) %>

<%= content_tag :div, class: css_classes.presence, data: merged_data, **html_options do %>
  <%= text.presence || content || yield %>
<% end %>
```

**Container parts with variants** only emit the attribute for non-default values:

```erb
<%# card/_content.html.erb %>
<%# locals: (spacing: :default, css_classes: "", **html_options) %>
<% merged_data = merge_component_data(html_options,
    card_part: :content,
    spacing: (spacing.to_sym == :full ? :full : nil)
  ).compact %>

<%= content_tag :div, class: css_classes.presence, data: merged_data, **html_options do %>
  <%= yield %>
<% end %>
```

```erb
<%# card/_footer.html.erb %>
<%# locals: (align: :start, spacing: :default, css_classes: "", **html_options) %>
<% merged_data = merge_component_data(html_options,
    card_part: :footer,
    align: align.to_sym.presence_in(%i[between end center]),
    spacing: (spacing.to_sym == :full ? :full : nil)
  ).compact %>

<%= content_tag :div, class: css_classes.presence, data: merged_data, **html_options do %>
  <%= yield %>
<% end %>
```

### Usage Examples

**Basic card:**
```erb
<%= render "components/card" do %>
  <%= render "components/card/header" do %>
    <%= render "components/card/title", text: "Account" %>
    <%= render "components/card/description", text: "Manage your settings" %>
  <% end %>
  <%= render "components/card/content" do %>
    <!-- form fields -->
  <% end %>
  <%= render "components/card/footer", align: :end do %>
    <%= button_to "Save", "#", data: { component: "button", variant: "primary" } %>
  <% end %>
<% end %>
```

**Card with row header (title + action):**
```erb
<%= render "components/card" do %>
  <%= render "components/card/header", layout: :row do %>
    <div>
      <%= render "components/card/title", text: "Team Members" %>
      <%= render "components/card/description", text: "Invite and manage team" %>
    </div>
    <%= render "components/card/action" do %>
      <%= link_to "Invite", new_invitation_path,
        data: { component: "button", variant: "primary", size: "sm" } %>
    <% end %>
  <% end %>
  <%= render "components/card/content" do %>
    <!-- member list -->
  <% end %>
<% end %>
```

### CSS

```css
/* card.css */
@layer components {
  [data-component="card"] {
    display: flex;
    flex-direction: column;
    @apply border;
    border-radius: var(--card-radius, var(--surface-radius, 0.5rem));
    box-shadow: var(--card-shadow, var(--elevation-raised, var(--shadow-sm, 0 1px 3px 0 rgb(0 0 0 / 0.1), 0 1px 2px -1px rgb(0 0 0 / 0.1))));
    border-color: var(--border);
    background-color: var(--card);
    color: var(--card-foreground);
  }

  :where([data-component="card"]) [data-card-part="header"] {
    display: flex;
    flex-direction: column;
    @apply gap-1.5 p-6;
  }

  :where([data-component="card"]) [data-card-part="header"]:where([data-layout="row"]) {
    flex-direction: row;
    align-items: center;
    justify-content: space-between;
    @apply gap-4;
  }

  :where([data-component="card"]) [data-card-part="title"] {
    @apply text-lg font-semibold leading-none tracking-tight;
  }

  :where([data-component="card"]) [data-card-part="title"]:where([data-size="sm"]) {
    @apply text-sm;
    font-weight: var(--label-weight, 500);
  }

  :where([data-component="card"]) [data-card-part="description"] {
    @apply text-sm;
    color: var(--muted-foreground);
  }

  :where([data-component="card"]) [data-card-part="action"] {
    display: flex;
    align-items: center;
    flex-shrink: 0;
    @apply gap-2;
  }

  :where([data-component="card"]) [data-card-part="content"] {
    @apply p-6 pt-0;
  }

  :where([data-component="card"]) [data-card-part="content"]:where([data-spacing="full"]) {
    @apply pt-6;
  }

  :where([data-component="card"]) [data-card-part="footer"] {
    display: flex;
    align-items: center;
    @apply p-6 pt-0;
  }

  :where([data-component="card"]) [data-card-part="footer"]:where([data-align="end"]) {
    justify-content: flex-end;
  }
}
```

## Alert Component

### Structure

```
Alert (icon: renders the icon and sets data-has-icon)
├── AlertTitle
└── AlertDescription
```

### Implementation

```erb
<%# _alert.html.erb %>
<%# locals: (variant: :default, icon: nil, css_classes: "", **html_options) %>
<%# :error is accepted as an alias of the canonical :destructive variant %>
<% variant = :destructive if variant.to_s == "error" %>
<% merged_data = merge_component_data(html_options,
    component: :alert,
    variant: variant,
    has_icon: icon.present? || nil
  ).compact %>

<%= content_tag :div, role: :alert, class: css_classes.presence, data: merged_data, **html_options do %>
  <%= icon_for(icon) if icon.present? %>

  <div><%= yield %></div>
<% end %>
```

```erb
<%# alert/_title.html.erb %>
<%# locals: (text: nil, content: nil, css_classes: "", **html_options) %>
<% merged_data = merge_component_data(html_options, alert_part: :title) %>

<%= content_tag :div, class: css_classes.presence, data: merged_data, **html_options do %>
  <%= text.presence || content || yield %>
<% end %>
```

`alert/_description.html.erb` is identical with `alert_part: :description`.

### Usage

```erb
<%= render "components/alert", variant: :destructive, icon: :circle_alert do %>
  <%= render "components/alert/title", text: "Error" %>
  <%= render "components/alert/description" do %>
    Your session has expired. Please <%= link_to "log in again", login_path %>.
  <% end %>
<% end %>
```

Variants: `:default`, `:destructive` (alias `:error`), `:success`, `:warning`, `:info`.

### CSS

```css
/* alert.css */
@layer components {
  [data-component="alert"] {
    position: relative;
    display: grid;
    grid-template-columns: 1fr;
    @apply w-full border p-4 text-sm;
    border-radius: var(--alert-radius, var(--surface-radius, 0.5rem));
    /* an alert sits on a surface: --card, not the page background */
    background-color: var(--card, var(--background));
    color: var(--foreground);
    border-color: var(--border);
  }

  [data-component="alert"]:where([data-has-icon="true"]) {
    grid-template-columns: auto 1fr;
    @apply gap-3;
  }

  [data-component="alert"] > svg:where(:first-child),
  :where([data-component="alert"]) [data-alert-part="icon"] {
    @apply size-4 shrink-0;
    margin-top: 0.125rem;
  }

  :where([data-component="alert"]) [data-alert-part="title"] {
    @apply leading-none tracking-tight;
    font-weight: var(--label-weight, 500);
  }

  :where([data-component="alert"]) [data-alert-part="description"] {
    @apply text-sm;
    color: var(--muted-foreground);
  }

  /* Variant propagation into parts lives in the variant tier */
  [data-component="alert"]:where([data-variant="destructive"]) {
    background-color: var(--destructive);
    color: var(--destructive-foreground);
    border-color: var(--destructive);
  }

  :where([data-component="alert"][data-variant="destructive"]) [data-alert-part="description"] {
    color: var(--destructive-foreground);
    opacity: 0.9;
  }
}
```

(Abridged — see `app/assets/stylesheets/alert.css` for the full variant set.)

## Table Component

### Structure

```
Table (optional container div + table element)
├── Caption (optional)
├── Header (sticky: true)
│   └── Row
│       └── Head (th cells, scope: "col")
├── Body
│   └── Row(s) (selected: true)
│       └── Cell (td cells)
└── Footer (optional)
    └── Row
        └── Cell
```

### Implementation

**Main wrapper with container:**
```erb
<%# _table.html.erb %>
<%# locals: (css_classes: "", container: true, variant: nil, table_variant: nil, **html_options) %>
<%
  table_data = merge_component_data(html_options, component: :table)
  table_data[:variant] = table_variant if table_variant

  container_data = { table_part: :container }
  container_data[:variant] = variant if variant
%>
<% if container %>
<%= tag.div data: container_data do %>
  <%= content_tag :table, class: css_classes.presence, data: table_data, **html_options do %>
    <%= yield %>
  <% end %>
<% end %>
<% else %>
<%= content_tag :table, class: css_classes.presence, data: table_data, **html_options do %>
  <%= yield %>
<% end %>
<% end %>
```

`variant:` styles the container (`:bordered`); `table_variant:` styles the table (`:striped`).

**Header with sticky option:**
```erb
<%# table/_header.html.erb %>
<%# locals: (css_classes: "", sticky: false, **html_options) %>
<%
  merged_data = merge_component_data(html_options, table_part: :header)
  merged_data[:sticky] = "true" if sticky
%>
<%= content_tag :thead, class: css_classes.presence, data: merged_data, **html_options do %>
  <%= yield %>
<% end %>
```

**Row with selected state:**
```erb
<%# table/_row.html.erb %>
<%# locals: (css_classes: "", selected: false, **html_options) %>
<%
  merged_data = merge_component_data(html_options, table_part: :row)
  merged_data[:state] = :selected if selected
%>
<%= content_tag :tr, class: css_classes.presence, data: merged_data, **html_options do %>
  <%= yield %>
<% end %>
```

**Head cell with scope:**
```erb
<%# table/_head.html.erb %>
<%# locals: (text: nil, content: nil, css_classes: "", scope: "col", **html_options) %>
<%
  merged_data = merge_component_data(html_options, table_part: :head)
  html_options[:scope] = scope if scope
%>
<%= content_tag :th, class: css_classes.presence, data: merged_data, **html_options do %>
  <%= text.presence || content || yield %>
<% end %>
```

### Usage Examples

**Basic table:**
```erb
<%= render "components/table" do %>
  <%= render "components/table/header" do %>
    <%= render "components/table/row" do %>
      <%= render "components/table/head", text: "Name" %>
      <%= render "components/table/head", text: "Email" %>
    <% end %>
  <% end %>
  <%= render "components/table/body" do %>
    <% @users.each do |user| %>
      <%= render "components/table/row" do %>
        <%= render "components/table/cell", text: user.name %>
        <%= render "components/table/cell", text: user.email %>
      <% end %>
    <% end %>
  <% end %>
<% end %>
```

**Table with variants and footer:**
```erb
<%= render "components/table", variant: :bordered, table_variant: :striped do %>
  <%= render "components/table/caption", text: "Order Summary" %>
  <%= render "components/table/header" do %>
    <%= render "components/table/row" do %>
      <%= render "components/table/head", text: "Product" %>
      <%= render "components/table/head", text: "Amount", css_classes: "text-right" %>
    <% end %>
  <% end %>
  <%= render "components/table/body" do %>
    <% @orders.each do |order| %>
      <%= render "components/table/row" do %>
        <%= render "components/table/cell", text: order.product %>
        <%= render "components/table/cell", text: order.amount, css_classes: "text-right" %>
      <% end %>
    <% end %>
  <% end %>
  <%= render "components/table/footer" do %>
    <%= render "components/table/row" do %>
      <%= render "components/table/cell", text: "Total" %>
      <%= render "components/table/cell", text: @total, css_classes: "text-right font-bold" %>
    <% end %>
  <% end %>
<% end %>
```

**Using simple_table helper:**
```erb
<%= simple_table @invoices, columns: [
  { key: :number, label: "Invoice" },
  { key: :status, label: "Status" },
  { key: :amount, label: "Amount", align: :right }
], caption: "Recent invoices", variant: :bordered %>
```

### CSS

```css
/* table.css (abridged) */
@layer components {
  [data-table-part="container"] {
    position: relative;
    width: 100%;
    overflow-x: auto;
  }

  [data-table-part="container"]:where([data-variant="bordered"]) {
    border: 1px solid var(--border);
    @apply overflow-hidden;
    border-radius: var(--table-radius, var(--surface-radius, 0.5rem));
  }

  [data-component="table"] {
    width: 100%;
    caption-side: bottom;
    border-collapse: collapse;
    @apply text-sm;
  }

  [data-table-part="row"] {
    border-bottom: 1px solid var(--border);
    transition-property: background-color;
    @apply duration-150;
  }

  [data-table-part="row"]:where(:hover) {
    background-color: color-mix(in oklch, var(--muted) 50%, transparent);
  }

  /* Selected wins over hover: declared later, same 0,1,0 */
  [data-table-part="row"]:where([data-state="selected"]) {
    background-color: var(--muted);
  }

  /* Variant on an ancestor goes inside :where() */
  :where([data-component="table"][data-variant="striped"] [data-table-part="body"]) [data-table-part="row"]:where(:nth-child(even)) {
    background-color: color-mix(in oklch, var(--muted) 30%, transparent);
  }
}
```

---

## Sidebar Component

Complex compound component with many sub-parts and two Stimulus controllers (`sidebar`, `sidebar-trigger`).

### Structure

```
SidebarProvider (data-component="sidebar", controller: "sidebar", outlet target)
├── Sidebar (<aside data-sidebar-part="root">; state, collapsible, variant, side)
│   ├── SidebarHeader
│   ├── SidebarContent
│   │   └── SidebarGroup (title: renders the group label)
│   │       └── SidebarMenu
│   │           └── SidebarMenuItem
│   │               ├── SidebarMenuButton (icon + title) / SidebarMenuLink (avatar style)
│   │               ├── SidebarMenuBadge (optional)
│   │               └── SidebarMenuAction (optional)
│   └── SidebarFooter
└── SidebarInset (<main> content area)
    └── SidebarTrigger (anywhere; reaches the provider via a Stimulus outlet)
```

### Key Patterns

**Provider with Stimulus controller, values and keyboard shortcut:**
```erb
<%# sidebar/_provider.html.erb %>
<%# locals: (id: nil, default_open: true, variant: :inset, css_classes: "", cookie_name: "sidebar_state", keyboard_shortcut: "b", **html_options) %>
<% merged_data = merge_component_data(html_options,
    component: :sidebar,
    variant: variant,
    controller: "sidebar",
    outlet: "sidebar",
    sidebar_default_open_value: default_open,
    sidebar_open_value: default_open,
    sidebar_cookie_name_value: cookie_name,
    sidebar_keyboard_shortcut_value: keyboard_shortcut,
    action: "keydown.meta+#{keyboard_shortcut}@window->sidebar#toggleWithKeyboard keydown.ctrl+#{keyboard_shortcut}@window->sidebar#toggleWithKeyboard"
  ) %>

<%= content_tag :div, id: id || "sidebar-provider", class: css_classes, data: merged_data, **html_options do %>
  <%= yield %>
<% end %>
```

**Menu button with active state** (`data-active` only when true, plus `aria-current`):
```erb
<%# sidebar/_menu_button.html.erb %>
<%# locals: (title:, url:, icon_name: nil, size: :default, active: false, css_classes: "", **html_options) %>
<% merged_data = merge_component_data(html_options,
    sidebar_part: "menu-button",
    size: size,
    active: (active ? true : nil)
  ) %>

<%= link_to url, class: css_classes, data: merged_data,
      "aria-current": (active ? "page" : nil), **html_options do %>
  <% if icon_name.present? %>
    <%= icon_for(icon_name) %>
  <% end %>

  <span><%= title %></span>
<% end %>
```

**Trigger wired to the provider through an outlet:**
```erb
<%# sidebar/_trigger.html.erb %>
<% merged_data = merge_component_data(html_options,
    sidebar_part: :trigger,
    controller: "sidebar-trigger",
    action: "click->sidebar-trigger#triggerClick",
    sidebar_trigger_sidebar_outlet: "[data-outlet='sidebar']"
  ) %>
```

State helpers (`app/helpers/maquina_components/sidebar_helper.rb`) read the cookie the controller writes: `sidebar_state` → `:expanded`/`:collapsed`, `sidebar_open?`, `sidebar_closed?`.

### Usage

```erb
<%= render "components/sidebar/provider", default_open: sidebar_open? do %>
  <%= render "components/sidebar", state: sidebar_state do %>
    <%= render "components/sidebar/header" do %>
      <%= link_to root_path, class: "flex items-center gap-2" do %>
        <%= image_tag "logo.svg", class: "size-8" %>
        <span class="font-semibold">App Name</span>
      <% end %>
    <% end %>

    <%= render "components/sidebar/content" do %>
      <%= render "components/sidebar/group", title: "Main" do %>
        <%= render "components/sidebar/menu" do %>
          <%= render "components/sidebar/menu_item" do %>
            <%= render "components/sidebar/menu_button",
              title: "Dashboard",
              icon_name: :home,
              url: dashboard_path,
              active: current_page?(dashboard_path) %>
          <% end %>
          <%= render "components/sidebar/menu_item" do %>
            <%= render "components/sidebar/menu_button",
              title: "Inbox",
              icon_name: :inbox,
              url: inbox_path %>
            <%= render "components/sidebar/menu_badge", text: "24" %>
          <% end %>
        <% end %>
      <% end %>
    <% end %>

    <%= render "components/sidebar/footer" do %>
      <%= render "components/menu_button",
        title: current_user.name, subtitle: current_user.email,
        text_icon: current_user.name.first, submenu: true do |menu_id| %>
        <%= render "components/dropdown", id: menu_id do %>
          <%= render "components/dropdown_menu/item", href: session_path, method: :delete do %>Sign out<% end %>
        <% end %>
      <% end %>
    <% end %>
  <% end %>

  <%= render "components/sidebar/inset" do %>
    <%= render "components/header" do %>
      <%= render "components/sidebar/trigger" %>
    <% end %>
    <%= yield %>
  <% end %>
<% end %>
```

Menu badge and menu action must be rendered **inside** `menu_item`, as siblings of the menu button — the item is their positioning context.

## Design Principles

### 1. Explicit Part Naming

Use `data-{component}-part` for sub-components:
- Card: `data-card-part="header"`
- Alert: `data-alert-part="title"`
- Sidebar: `data-sidebar-part="menu-button"`
- Multi-word components: `data-dropdown-menu-part="item"`, `data-toggle-group-part="item"`

### 2. Flexible Content

Every leaf part accepts `text:`, `content:` or a block (in that order of precedence):
```erb
<%= render "components/card/title", text: "Simple" %>
<%= render "components/card/title" do %>
  Complex with <%= icon_for :check %>
<% end %>
```

### 3. Semantic Elements

Use appropriate HTML elements where the role is fixed:
- Tables → `<table>`, `<thead>`, `<tr>`, `<th scope="col">`, `<td>`
- Sidebar → `<aside>`, inset → `<main>`
- Navigation → `<nav>` (breadcrumbs, pagination), lists → `<ol>`/`<ul>`, `<li>`
- Drawer title/description accept `tag:` (`:h2` / `:p` by default)

Card and alert titles/descriptions render `<div>`; wrap them or pass a heading in the block if the document outline needs one.

### 4. Optional Parts

Not all parts are required:
```erb
<%# Card without header or footer %>
<%= render "components/card" do %>
  <%= render "components/card/content", spacing: :full do %>
    Just content, no header or footer
  <% end %>
<% end %>
```

### 5. Variant Propagation

Variants on the root style the parts through CSS. Put the root and its variant inside `:where()` so the part stays at 0,1,0:
```css
:where([data-component="alert"][data-variant="destructive"]) [data-alert-part="title"] {
  color: var(--destructive-foreground);
}
```

### 6. Parts Reach the Root via Stimulus, Not IDs

Controllers live on the root (or provider) and find parts through targets (`data-{controller}-target`) or outlets (`sidebar-trigger` → `sidebar`, `drawer-trigger` → `drawer`). Render stable `id`s when aria wiring needs them (`aria-controls`, `aria-labelledby`).

## Testing Compound Components

Partial rendering is covered by `test/components/components_render_test.rb`; visual checks live in the dummy app previews (`test/dummy/app/views/previews/<component>/`).

```erb
<%# Minimal %>
<%= render "components/card" do %>
  <%= render "components/card/content", spacing: :full do %>
    Content only
  <% end %>
<% end %>

<%# Full %>
<%= render "components/card" do %>
  <%= render "components/card/header", layout: :row do %>
    <div>
      <%= render "components/card/title", text: "Title" %>
      <%= render "components/card/description", text: "Description" %>
    </div>
    <%= render "components/card/action" do %>
      Button
    <% end %>
  <% end %>
  <%= render "components/card/content" do %>
    Content
  <% end %>
  <%= render "components/card/footer", align: :between do %>
    Footer
  <% end %>
<% end %>
```
