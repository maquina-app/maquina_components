# Component Catalog

Complete reference for all maquina_components. Each entry includes when to use, props, variants, and examples.

---

## Component Philosophy

All maquina_components are **composable building blocks**. You have three approaches:

1. **Use partials directly** — Render components as documented for standard patterns
2. **Compress complexity** — Wrap multiple partials into application-specific components that encode your conventions (e.g., `_booking_card.html.erb` that internally uses Card, Badge, etc.)
3. **Copy and customize** — Copy component partials into your app and adapt them for specific needs

Choose the approach that fits your use case. There's no "right" level of abstraction — prioritize consistency within your application.

```erb
<%# Direct usage - explicit composition %>
<%= render "components/card" do %>
  <%= render "components/card/header" do %>
    <%= render "components/card/title", text: @booking.service.name %>
  <% end %>
<% end %>

<%# Application wrapper - compressed complexity %>
<%= render "bookings/card", booking: @booking %>
<%# Your partial handles the component composition internally %>
```

---

## Table of Contents

1. [Layout Components](#layout-components)
   - [Sidebar](#sidebar)
   - [Header](#header)
2. [Content Components](#content-components)
   - [Card](#card)
   - [Alert](#alert)
   - [Badge](#badge)
   - [Table](#table)
   - [Empty State](#empty-state)
   - [Separator](#separator)
3. [Feedback Components](#feedback-components)
   - [Toast](#toast)
4. [Navigation Components](#navigation-components)
   - [Breadcrumbs](#breadcrumbs)
   - [Dropdown Menu](#dropdown-menu)
   - [Pagination](#pagination)
5. [Interactive Components](#interactive-components)
   - [Combobox](#combobox)
   - [Toggle Group](#toggle-group)
6. [Form Components](#form-components)
   - [Button](#button)
   - [Input](#input)
   - [Textarea](#textarea)
   - [Select](#select)
   - [Checkbox](#checkbox)
   - [Radio](#radio)
   - [Switch](#switch)
   - [Form Layout](#form-layout)

---

## Layout Components

### Sidebar

Collapsible navigation sidebar with cookie-based persistence.

**When to Use:**
- Main application navigation
- Dashboard layouts
- Admin interfaces

**Structure:**
```erb
<%= render "components/sidebar/provider", default_open: sidebar_open? do %>
  <%= render "components/sidebar" do %>
    <%= render "components/sidebar/header" do %>...Logo...<% end %>
    <%= render "components/sidebar/content" do %>
      <%= render "components/sidebar/group", title: "Menu" do %>
        <%= render "components/sidebar/menu" do %>
          <%= render "components/sidebar/menu_item" do %>
            <%= render "components/sidebar/menu_button",
                title: "Dashboard",
                url: dashboard_path,
                icon_name: :home,
                active: current_page?(dashboard_path) %>
          <% end %>
        <% end %>
      <% end %>
    <% end %>
    <%= render "components/sidebar/footer" do %>...<% end %>
  <% end %>
  
  <%= render "components/sidebar/inset" do %>
    <%= render "components/header" do %>
      <%= render "components/sidebar/trigger", icon_name: :panel_left %>
    <% end %>
    <main><%= yield %></main>
  <% end %>
<% end %>
```

**Parts:**

| Part | Purpose |
|------|---------|
| `sidebar/provider` | Context wrapper, manages state |
| `sidebar` | Main sidebar container |
| `sidebar/header` | Logo/brand area |
| `sidebar/content` | Scrollable nav content |
| `sidebar/footer` | Bottom area (user menu) |
| `sidebar/group` | Navigation group with title |
| `sidebar/menu` | Menu container |
| `sidebar/menu_item` | Single menu item wrapper |
| `sidebar/menu_button` | Clickable nav item |
| `sidebar/menu_link` | Alternative link style |
| `sidebar/trigger` | Toggle button |
| `sidebar/inset` | Main content area |

**Provider Props:**

| Prop | Type | Default | Description |
|------|------|---------|-------------|
| `default_open` | Boolean | `true` | Initial state |
| `cookie_name` | String | `"sidebar_state"` | Cookie key |
| `variant` | Symbol | `:default` | `:default`, `:inset` |

**Menu Button Props:**

| Prop | Type | Description |
|------|------|-------------|
| `title` | String | Display text |
| `url` | String | Link path |
| `icon_name` | Symbol | Icon identifier |
| `active` | Boolean | Highlight current |
| `badge` | String | Optional badge text |

---

### Header

Top navigation bar, typically used with sidebar inset.

**When to Use:**
- Top of page header
- Contains sidebar trigger, breadcrumbs, actions

**Usage:**
```erb
<%= render "components/header" do %>
  <%= render "components/sidebar/trigger", icon_name: :panel_left %>
  
  <div class="flex-1">
    <%= render "components/breadcrumbs" do %>...breadcrumbs...<% end %>
  </div>
  
  <div class="flex items-center gap-2">
    <%# Header actions %>
  </div>
<% end %>
```

---

## Content Components

### Card

Versatile content container with header, content, and footer sections.

**When to Use:**
- Group related content
- Dashboard widgets
- Form containers
- List item containers

**Structure:**
```erb
<%= render "components/card" do %>
  <%= render "components/card/header" do %>
    <%= render "components/card/title", text: "Title" %>
    <%= render "components/card/description", text: "Description" %>
  <% end %>
  <%= render "components/card/content" do %>
    <!-- Main content -->
  <% end %>
  <%= render "components/card/footer" do %>
    <!-- Actions -->
  <% end %>
<% end %>
```

**Parts:**

| Part | Props | Description |
|------|-------|-------------|
| `card` | `css_classes` | Main container |
| `card/header` | `layout: :column\|:row` | Header section |
| `card/title` | `text`, `size: :default\|:sm` | Title text |
| `card/description` | `text` | Subtitle/description |
| `card/action` | — | Action button area (in header) |
| `card/content` | `css_classes` | Main content area |
| `card/footer` | `align: :start\|:end\|:between` | Footer with actions |

**Row Header with Action:**
```erb
<%= render "components/card/header", layout: :row do %>
  <div>
    <%= render "components/card/title", text: "Users" %>
    <%= render "components/card/description", text: "Manage team members" %>
  </div>
  <%= render "components/card/action" do %>
    <%= link_to "Add User", new_user_path, 
        data: { component: "button", variant: "primary", size: "sm" } %>
  <% end %>
<% end %>
```

**Stats Card Pattern:**
```erb
<%= render "components/card" do %>
  <%= render "components/card/header", css_classes: "pb-2" do %>
    <%= render "components/card/title", text: "Revenue", size: :sm %>
  <% end %>
  <%= render "components/card/content", css_classes: "pt-0" do %>
    <div class="text-2xl font-bold">$12,500</div>
    <div class="flex items-center gap-1 text-sm text-emerald-600">
      <%= icon_for :trending_up, class: "size-4" %> +12.5%
    </div>
  <% end %>
<% end %>
```

---

### Alert

Callout messages for important information, warnings, or errors.

**When to Use:**
- System notifications
- Form submission feedback
- Important warnings
- Destructive action confirmations

**Variants:**

| Variant | Usage |
|---------|-------|
| `:default` | General information |
| `:success` | Positive confirmations |
| `:warning` | Caution needed |
| `:destructive` | Errors, critical warnings |

**Usage:**
```erb
<%= render "components/alert", variant: :default do %>
  <%= render "components/alert/title", text: "Information" %>
  <%= render "components/alert/description" do %>
    Your changes have been saved successfully.
  <% end %>
<% end %>

<%= render "components/alert", variant: :destructive do %>
  <%= render "components/alert/title", text: "Error" %>
  <%= render "components/alert/description", text: "Unable to save changes." %>
<% end %>
```

**Props:**

| Prop | Values | Default |
|------|--------|---------|
| `variant` | `:default`, `:success`, `:warning`, `:destructive` | `:default` |

---

### Badge

Compact status indicators and labels.

**When to Use:**
- Status indicators (active, pending, failed)
- Counts and labels
- Tags and categories
- Inline metadata

**Variants:**

| Variant | Usage | Example |
|---------|-------|---------|
| `:default` | Neutral | Tags, counts |
| `:primary` | Brand emphasis | Featured |
| `:secondary` | Low emphasis | Categories |
| `:success` | Positive | Active, Completed |
| `:warning` | Attention | Pending, In Progress |
| `:destructive` | Negative | Failed, Cancelled |
| `:outline` | Minimal | Subtle labels |

**Sizes:**

| Size | Usage |
|------|-------|
| `:sm` | Compact tables, tight spaces |
| `:md` | Default |
| `:lg` | Standalone emphasis |

**Usage:**
```erb
<%# Basic %>
<%= render "components/badge", variant: :success do %>Active<% end %>

<%# With icon %>
<%= render "components/badge", variant: :warning do %>
  <%= icon_for :clock, class: "size-3" %> Pending
<% end %>

<%# With count %>
<%= render "components/badge", variant: :primary do %>
  <%= @notifications.count %> new
<% end %>
```

**Dynamic Status Pattern:**
```erb
<% variant = case record.status
   when "active" then :success
   when "pending" then :warning
   when "inactive" then :secondary
   when "error" then :destructive
   else :default
   end %>
<%= render "components/badge", variant: variant, size: :sm do %>
  <%= record.status.humanize %>
<% end %>
```

---

### Table

Data tables with header, body, and optional sorting.

**When to Use:**
- Data listings
- Admin tables
- Comparison views
- Any tabular data

**Structure:**
```erb
<%= render "components/table" do %>
  <%= render "components/table/header" do %>
    <%= render "components/table/row" do %>
      <%= render "components/table/head" do %>Name<% end %>
      <%= render "components/table/head" do %>Status<% end %>
      <%= render "components/table/head", css_classes: "w-10" do %>
        <span class="sr-only">Actions</span>
      <% end %>
    <% end %>
  <% end %>
  <%= render "components/table/body" do %>
    <% @items.each do |item| %>
      <%= render "components/table/row" do %>
        <%= render "components/table/cell", css_classes: "font-medium" do %>
          <%= item.name %>
        <% end %>
        <%= render "components/table/cell" do %>
          <%= render "components/badge", variant: :success do %><%= item.status %><% end %>
        <% end %>
        <%= render "components/table/cell" do %>
          <%= render "shared/row_actions", item: item %>
        <% end %>
      <% end %>
    <% end %>
  <% end %>
<% end %>
```

**Props:**

| Component | Props |
|-----------|-------|
| `table` | `container: true\|false` (scroll wrapper) |
| `table/head` | `css_classes`, sortable support |
| `table/cell` | `css_classes` |

**Inside Card (no container):**
```erb
<%= render "components/card" do %>
  <%= render "components/card/content" do %>
    <%= render "components/table", container: false do %>
      ...
    <% end %>
  <% end %>
<% end %>
```

---

### Empty State

Placeholder for empty data states.

**When to Use:**
- Zero results
- No data yet
- Search with no matches
- First-time user onboarding

**Structure:**
```erb
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
    <%= link_to t(".empty.action"), new_path, 
        data: { component: "button", variant: "primary" } %>
  <% end %>
<% end %>
```

**Conditional Pattern:**
```erb
<% if @items.any? %>
  <%= render "components/table" do %>...table...<% end %>
<% else %>
  <%= render "components/empty" do %>...empty state...<% end %>
<% end %>
```

---

### Separator

Visual divider between content sections.

**Usage:**
```erb
<%= render "components/separator" %>

<%# With orientation %>
<%= render "components/separator", orientation: :vertical %>
```

---

## Feedback Components

### Toast

Non-intrusive notifications that appear temporarily and dismiss automatically.

**When to Use:**
- Form submission feedback
- Background task completion
- Transient success/error messages
- Any temporary notification

**Setup:**
Add toaster container to your layout:
```erb
<!DOCTYPE html>
<html>
  <body>
    <%= yield %>
    <%= render "components/toaster", position: :bottom_right %>
  </body>
</html>
```

**Variants:**

| Variant | Usage |
|---------|-------|
| `:default` | Neutral notifications |
| `:success` | Positive confirmations |
| `:info` | Informational messages |
| `:warning` | Caution needed |
| `:error` | Errors, failures |

**Position Values:**
- `:top_left`, `:top_center`, `:top_right`
- `:bottom_left`, `:bottom_center`, `:bottom_right`

**Flash Messages (Most Common):**
```erb
<%= render "components/toaster", position: :bottom_right do %>
  <%= toast_flash_messages %>
<% end %>
```

Controller:
```ruby
def update
  if @user.update(user_params)
    flash[:success] = "Profile updated successfully!"
    redirect_to @user
  else
    flash[:error] = "Unable to save changes."
    render :edit, status: :unprocessable_entity
  end
end
```

**Single Toast:**
```erb
<%= toast :success, "Profile updated!" %>

<%= toast :error, "Save failed", description: "Please check your connection." %>

<%= toast :info, "New version available", duration: 10000 %>
```

**Toast with Action:**
```erb
<%= toast :info, "New version available" do %>
  <%= render "components/toast/action", label: "Refresh", href: root_path %>
<% end %>

<%= toast :warning, "Item pending deletion" do %>
  <%= render "components/toast/action",
              label: "Undo",
              href: restore_item_path(@item),
              method: :patch %>
<% end %>
```

**Turbo Stream Toasts:**
```erb
<%= turbo_stream.append "toaster" do %>
  <%= toast :success, "Post created!", description: "Your post is now live." %>
<% end %>
```

**JavaScript API:**
```javascript
// Basic toasts
Toast.success("Profile saved!")
Toast.error("Something went wrong")
Toast.warning("Session expiring soon")
Toast.info("New notification")

// With options
Toast.success("File uploaded", {
  description: "Your file has been processed.",
  duration: 8000
})

// No auto-dismiss
Toast.warning("Important notice", { duration: 0 })

// Dismiss programmatically
const toastId = Toast.success("Saved!")
Toast.dismiss(toastId)
Toast.dismissAll()
```

**Helper Methods:**

| Method | Description |
|--------|-------------|
| `toast_flash_messages` | Render all flash messages |
| `toast` | Single toast with variant |
| `toast_success` | Convenience helper |
| `toast_error` | Convenience helper |
| `toast_warning` | Convenience helper |
| `toast_info` | Convenience helper |

**Props:**

| Prop | Type | Default | Description |
|------|------|---------|-------------|
| `variant` | Symbol | `:default` | Toast variant |
| `title` | String | `nil` | Toast title |
| `description` | String | `nil` | Optional description |
| `duration` | Integer | `5000` | Auto-dismiss ms (0 = persistent) |
| `dismissible` | Boolean | `true` | Show close button |

**Flash Type Mapping:**

| Flash Type | Toast Variant |
|------------|---------------|
| `:notice`, `:success` | `:success` |
| `:alert`, `:error` | `:error` |
| `:warning`, `:warn` | `:warning` |
| `:info` | `:info` |

---

## Navigation Components

### Breadcrumbs

Navigation trail showing page hierarchy.

**When to Use:**
- Deep navigation structures
- Multi-level pages
- Show user's location

**Structure:**
```erb
<%= render "components/breadcrumbs" do %>
  <%= render "components/breadcrumbs/list" do %>
    <%= render "components/breadcrumbs/item" do %>
      <%= render "components/breadcrumbs/link", href: root_path, label: "Home" %>
    <% end %>
    <%= render "components/breadcrumbs/separator" %>
    <%= render "components/breadcrumbs/item" do %>
      <%= render "components/breadcrumbs/link", href: users_path, label: "Users" %>
    <% end %>
    <%= render "components/breadcrumbs/separator" %>
    <%= render "components/breadcrumbs/item" do %>
      <%= render "components/breadcrumbs/page", label: @user.name %>
    <% end %>
  <% end %>
<% end %>
```

**Helper Pattern:**
```erb
<%# In application_helper.rb %>
def breadcrumbs(links, current)
  render "components/breadcrumbs" do
    render "components/breadcrumbs/list" do
      safe_join(
        links.map do |label, path|
          render("components/breadcrumbs/item") do
            render("components/breadcrumbs/link", href: path, label: label)
          end + render("components/breadcrumbs/separator")
        end +
        [render("components/breadcrumbs/item") do
          render("components/breadcrumbs/page", label: current)
        end]
      )
    end
  end
end

<%# Usage %>
<%= breadcrumbs({ "Home" => root_path, "Users" => users_path }, @user.name) %>
```

---

### Dropdown Menu

Accessible dropdown with keyboard navigation.

**When to Use:**
- Action menus
- User profile menus
- Row actions in tables
- Any multi-option trigger

**Structure:**
```erb
<%= render "components/dropdown_menu" do %>
  <%= render "components/dropdown_menu/trigger" do %>
    Options
  <% end %>
  <%= render "components/dropdown_menu/content", align: :end do %>
    <%= render "components/dropdown_menu/label", text: "Actions" %>
    <%= render "components/dropdown_menu/separator" %>
    
    <%= render "components/dropdown_menu/item", href: edit_path do %>
      <%= icon_for :edit, class: "size-4" %> Edit
    <% end %>
    
    <%= render "components/dropdown_menu/item", href: duplicate_path do %>
      <%= icon_for :copy, class: "size-4" %> Duplicate
      <%= render "components/dropdown_menu/shortcut", text: "⌘D" %>
    <% end %>
    
    <%= render "components/dropdown_menu/separator" %>
    
    <%= render "components/dropdown_menu/item", href: delete_path, method: :delete, variant: :destructive do %>
      <%= icon_for :trash, class: "size-4" %> Delete
    <% end %>
  <% end %>
<% end %>
```

**Content Props:**

| Prop | Values | Default |
|------|--------|---------|
| `align` | `:start`, `:center`, `:end` | `:start` |

**Item Props:**

| Prop | Description |
|------|-------------|
| `href` | Link path |
| `method` | HTTP method (`:delete`, etc.) |
| `variant` | `:default`, `:destructive` |

**Table Row Actions Pattern:**
```erb
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
    ...items...
  <% end %>
<% end %>
```

---

### Pagination

Page navigation integrated with Pagy.

**When to Use:**
- Paginated lists
- Search results
- Any large data set

**Full Pagination:**
```erb
<%= pagination_nav(@pagy, :users_path) %>

<%# With options %>
<%= pagination_nav(@pagy, :users_path, show_labels: false) %>
```

**Simple Previous/Next:**
```erb
<%= pagination_simple(@pagy, :users_path) %>
```

**Inside Card Footer:**
```erb
<%= render "components/card/footer", align: :between do %>
  <span class="text-sm text-muted-foreground">
    Showing <%= @pagy.from %>-<%= @pagy.to %> of <%= @pagy.count %>
  </span>
  <%= pagination_nav(@pagy, :users_path, show_labels: false) %>
<% end %>
```

---

## Interactive Components

### Combobox

Autocomplete input with searchable dropdown list for selecting from many options.

**When to Use:**
- Selecting from large lists (countries, users, tags)
- When filtering/searching options is helpful
- Form fields needing autocomplete
- Any selection that benefits from search

**Parts:**

| Part | Purpose |
|------|---------|
| `combobox` | Root container with Stimulus controller |
| `combobox/trigger` | Button that opens the popover |
| `combobox/content` | Popover container |
| `combobox/input` | Search/filter input field |
| `combobox/list` | Scrollable options container |
| `combobox/option` | Selectable item with check indicator |
| `combobox/empty` | "No results" message |
| `combobox/group` | Logical grouping |
| `combobox/label` | Section heading |
| `combobox/separator` | Visual divider |

**Using the Helper (Recommended):**
```erb
<%= combobox placeholder: "Select framework..." do |cb| %>
  <% cb.trigger %>
  <% cb.content do %>
    <% cb.input placeholder: "Search frameworks..." %>
    <% cb.list do %>
      <% cb.option value: "rails" do %>Ruby on Rails<% end %>
      <% cb.option value: "django" do %>Django<% end %>
      <% cb.option value: "phoenix" do %>Phoenix<% end %>
    <% end %>
    <% cb.empty %>
  <% end %>
<% end %>
```

**Simple Data-Driven:**
```erb
<%= combobox_simple placeholder: "Select framework...",
                     name: "project[framework]",
                     options: [
                       { value: "rails", label: "Ruby on Rails" },
                       { value: "django", label: "Django" },
                       { value: "phoenix", label: "Phoenix" }
                     ] %>
```

**With Pre-selected Value:**
```erb
<%= combobox_simple placeholder: "Select framework...",
                     value: "rails",
                     options: Framework.all.map { |fw|
                       { value: fw.slug, label: fw.name }
                     } %>
```

**With Disabled Options:**
```erb
<%= combobox_simple placeholder: "Select framework...",
                     options: [
                       { value: "rails", label: "Ruby on Rails" },
                       { value: "angular", label: "Angular (deprecated)", disabled: true },
                       { value: "phoenix", label: "Phoenix" }
                     ] %>
```

**With Groups:**
```erb
<%= combobox placeholder: "Select technology..." do |cb| %>
  <% cb.trigger %>
  <% cb.content width: :md do %>
    <% cb.input %>
    <% cb.list do %>
      <% cb.group do %>
        <% cb.label "Frontend Frameworks" %>
        <% cb.option value: "react" do %>React<% end %>
        <% cb.option value: "vue" do %>Vue<% end %>
      <% end %>
      <% cb.separator %>
      <% cb.group do %>
        <% cb.label "Backend Frameworks" %>
        <% cb.option value: "rails" do %>Ruby on Rails<% end %>
        <% cb.option value: "phoenix" do %>Phoenix<% end %>
      <% end %>
    <% end %>
    <% cb.empty %>
  <% end %>
<% end %>
```

**Country Selector Pattern:**
```erb
<%= combobox placeholder: "Select country...", name: "user[country]" do |cb| %>
  <% cb.trigger %>
  <% cb.content width: :md do %>
    <% cb.input placeholder: "Search countries..." %>
    <% cb.list do %>
      <% Country.all.each do |country| %>
        <% cb.option value: country.code, selected: @user.country == country.code do %>
          <%= country.flag %> <%= country.name %>
        <% end %>
      <% end %>
    <% end %>
    <% cb.empty text: "No countries found." %>
  <% end %>
<% end %>
```

**User Selector Pattern:**
```erb
<%= combobox placeholder: "Assign to...", id: "assignee-select" do |cb| %>
  <% cb.trigger variant: :ghost %>
  <% cb.content width: :lg do %>
    <% cb.input placeholder: "Search team members..." %>
    <% cb.list do %>
      <% @team_members.each do |member| %>
        <% cb.option value: member.id do %>
          <div class="flex items-center gap-2">
            <%= image_tag member.avatar_url, class: "size-6 rounded-full" %>
            <span><%= member.name %></span>
            <span class="text-muted-foreground text-xs"><%= member.role %></span>
          </div>
        <% end %>
      <% end %>
    <% end %>
    <% cb.empty %>
  <% end %>
<% end %>
```

**With Form Builder:**
```erb
<%= form_with model: @project do |f| %>
  <div class="space-y-4">
    <%= render "components/label", for: "project_framework" do %>Framework<% end %>

    <%= combobox_simple id: "project_framework",
                         name: "project[framework]",
                         value: @project.framework,
                         placeholder: "Select framework...",
                         options: Framework.all.map { |fw|
                           { value: fw.slug, label: fw.name }
                         } %>

    <%= f.submit "Save", data: { component: "button", variant: "primary" } %>
  </div>
<% end %>
```

**Listening for Changes (Stimulus):**
```erb
<div data-controller="project-form">
  <%= combobox placeholder: "Select framework...",
               data: { action: "combobox:change->project-form#frameworkChanged" } do |cb| %>
  <% end %>
</div>
```

```javascript
// project_form_controller.js
export default class extends Controller {
  frameworkChanged(event) {
    const { value, label } = event.detail
    console.log(`Selected: ${label} (${value})`)
  }
}
```

**Content Props:**

| Prop | Values | Default |
|------|--------|---------|
| `align` | `:start`, `:center`, `:end` | `:start` |
| `width` | `:sm`, `:default`, `:md`, `:lg`, `:full` | `:default` |

**Option Props:**

| Prop | Type | Description |
|------|------|-------------|
| `value` | String | Option value (required) |
| `selected` | Boolean | Initially selected |
| `disabled` | Boolean | Whether disabled |

**Keyboard Navigation:**

| Key | Action |
|-----|--------|
| `Enter` / `Space` | Open combobox, select option |
| `Escape` | Close combobox |
| `↓` / `↑` | Navigate options |
| `Home` / `End` | First/last option |
| Type characters | Filter options |

**Browser Support (Popover API):**
The combobox uses the HTML5 Popover API. For older browsers, add the polyfill:

```ruby
# config/importmap.rb
pin "@oddbird/popover-polyfill", to: "https://cdn.jsdelivr.net/npm/@oddbird/popover-polyfill@latest/dist/popover.min.js"
```

```javascript
// app/javascript/application.js
import "@oddbird/popover-polyfill"
```

---

### Toggle Group

Single or multiple selection button group.

**When to Use:**
- View mode switching (list/grid)
- Text formatting (bold/italic)
- Filter options
- Any exclusive/inclusive selection

**Single Selection:**
```erb
<%= render "components/toggle_group", type: :single, variant: :outline do %>
  <%= render "components/toggle_group/item", value: "list", pressed: true, aria_label: "List view" do %>
    <%= icon_for :list, class: "size-4" %>
  <% end %>
  <%= render "components/toggle_group/item", value: "grid", aria_label: "Grid view" do %>
    <%= icon_for :grid, class: "size-4" %>
  <% end %>
<% end %>
```

**Multiple Selection:**
```erb
<%= render "components/toggle_group", type: :multiple, variant: :default do %>
  <%= render "components/toggle_group/item", value: "bold", pressed: true do %>
    <%= icon_for :bold, class: "size-4" %>
  <% end %>
  <%= render "components/toggle_group/item", value: "italic" do %>
    <%= icon_for :italic, class: "size-4" %>
  <% end %>
<% end %>
```

**Props:**

| Prop | Values | Default |
|------|--------|---------|
| `type` | `:single`, `:multiple` | `:single` |
| `variant` | `:default`, `:outline` | `:default` |
| `size` | `:sm`, `:md`, `:lg` | `:md` |

---

## Form Components

Form components use data attributes with Rails form helpers. No partials needed.

### Button

**Variants:**

| Variant | Usage |
|---------|-------|
| `default` | Standard actions |
| `primary` | Primary CTA |
| `secondary` | Secondary actions |
| `destructive` | Delete, dangerous actions |
| `outline` | Subtle, bordered |
| `ghost` | Minimal, icon buttons |
| `link` | Text link style |

**Sizes:**

| Size | Usage |
|------|-------|
| `sm` | Compact UIs, table actions |
| `md` | Default |
| `lg` | Hero CTAs |
| `icon` | Square icon buttons |
| `icon-sm` | Small icon buttons |
| `icon-lg` | Large icon buttons |

**Usage:**
```erb
<%# Submit button %>
<%= f.submit "Save", data: { component: "button", variant: "primary" } %>

<%# Link styled as button %>
<%= link_to "Cancel", root_path, data: { component: "button", variant: "outline" } %>

<%# Destructive with confirmation %>
<%= button_to "Delete", resource_path, 
    method: :delete,
    data: { 
      component: "button", 
      variant: "destructive",
      turbo_confirm: t(".confirm_delete")
    } %>

<%# Icon button %>
<%= link_to settings_path, data: { component: "button", variant: "ghost", size: "icon" } do %>
  <%= icon_for :settings, class: "size-4" %>
<% end %>

<%# Button with icon %>
<%= link_to new_path, data: { component: "button", variant: "primary" } do %>
  <%= icon_for :plus, class: "size-4 mr-1" %> Add New
<% end %>
```

---

### Input

**Usage:**
```erb
<%= f.text_field :name, data: { component: "input" }, placeholder: "Name" %>
<%= f.email_field :email, data: { component: "input" } %>
<%= f.password_field :password, data: { component: "input" } %>
<%= f.number_field :quantity, data: { component: "input" } %>
<%= f.file_field :avatar, data: { component: "input" } %>

<%# With size %>
<%= f.text_field :name, data: { component: "input", size: "sm" } %>
<%= f.text_field :name, data: { component: "input", size: "lg" } %>

<%# Disabled %>
<%= f.text_field :name, data: { component: "input" }, disabled: true %>
```

---

### Textarea

```erb
<%= f.text_area :bio, data: { component: "textarea" }, rows: 4 %>
```

---

### Select

```erb
<%= f.select :country, country_options, {}, data: { component: "select" } %>
<%= f.collection_select :category_id, @categories, :id, :name, {}, data: { component: "select" } %>
```

---

### Checkbox

```erb
<%= f.check_box :terms, data: { component: "checkbox" } %>

<%# With inline label %>
<div data-form-part="group" data-layout="inline">
  <%= f.check_box :newsletter, data: { component: "checkbox" } %>
  <%= f.label :newsletter, t(".subscribe"), data: { component: "label" } %>
</div>
```

---

### Radio

```erb
<div data-form-part="group" data-layout="inline">
  <%= f.radio_button :plan, "basic", data: { component: "radio" } %>
  <%= f.label :plan_basic, "Basic", data: { component: "label" } %>
</div>
<div data-form-part="group" data-layout="inline">
  <%= f.radio_button :plan, "pro", data: { component: "radio" } %>
  <%= f.label :plan_pro, "Pro", data: { component: "label" } %>
</div>
```

---

### Switch

Toggle switch for boolean values.

```erb
<div data-form-part="group" data-layout="inline">
  <%= f.check_box :notifications, data: { component: "switch" } %>
  <%= f.label :notifications, t(".enable_notifications"), data: { component: "label" } %>
</div>
```

---

### Form Layout

**Form Container:**
```erb
<%= form_with model: @user, data: { component: "form" } do |f| %>
  ...
<% end %>
```

**Field Group:**
```erb
<div data-form-part="group">
  <%= f.label :email, data: { component: "label" } %>
  <%= f.email_field :email, data: { component: "input" } %>
  <p data-form-part="description">We'll never share your email.</p>
</div>

<%# With error %>
<div data-form-part="group">
  <%= f.label :email, data: { component: "label" } %>
  <%= f.email_field :email, data: { component: "input" } %>
  <% if @user.errors[:email].any? %>
    <p data-form-part="error"><%= @user.errors[:email].first %></p>
  <% end %>
</div>
```

**Inline Layout (checkbox/radio with label):**
```erb
<div data-form-part="group" data-layout="inline">
  <%= f.check_box :terms, data: { component: "checkbox" } %>
  <%= f.label :terms, data: { component: "label" } %>
</div>
```

**Actions:**
```erb
<div data-form-part="actions">
  <%= f.submit "Save", data: { component: "button", variant: "primary" } %>
  <%= link_to "Cancel", root_path, data: { component: "button", variant: "outline" } %>
</div>

<%# Right aligned %>
<div data-form-part="actions" data-align="end">
  <%= f.submit "Save", data: { component: "button", variant: "primary" } %>
</div>

<%# Space between %>
<div data-form-part="actions" data-align="between">
  <%= link_to "Back", root_path, data: { component: "button", variant: "ghost" } %>
  <%= f.submit "Continue", data: { component: "button", variant: "primary" } %>
</div>
```

**Fieldset:**
```erb
<fieldset data-component="fieldset">
  <legend data-component="legend">Account Information</legend>
  
  <div data-form-part="group">...</div>
  <div data-form-part="group">...</div>
</fieldset>
```

**Input Group (prefix/suffix):**
```erb
<div data-component="input-group">
  <span data-input-group-part="prefix">$</span>
  <%= f.number_field :price, data: { component: "input" } %>
</div>

<div data-component="input-group">
  <%= f.text_field :domain, data: { component: "input" } %>
  <span data-input-group-part="suffix">.com</span>
</div>
```
