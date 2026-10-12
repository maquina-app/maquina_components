# Available Components

> Index of every UI component in maquina_components: files, key parameters, and a working usage snippet. The full API for each component lives in `docs/{component}.md`; this file is the one-glance map.

Paths are relative to the engine root. Partials live under `app/views/components/`, styles under `app/assets/stylesheets/` (imported by `app/assets/tailwind/maquina_components_engine/engine.css`), helpers under `app/helpers/maquina_components/`, and Stimulus controllers under `app/javascript/controllers/`.

## Component Categories

| Category | Components | JavaScript |
|----------|------------|------------|
| **Static** | Alert, Badge, Card, Separator, Empty, Stats | No |
| **Interactive** | Sidebar, Dropdown Menu, Menu Button (+ Dropdown panel), Breadcrumbs (responsive), Drawer, Combobox, Calendar, Date Picker, Toggle Group, Toast / Toaster | Yes (Stimulus) |
| **Form** | Input, Textarea, Select, Checkbox, Radio, Switch, Button, Fieldset, Input Group (CSS only), Label (partial) | No |
| **Layout** | Header, Table (+ `simple_table`), Pagination | No |

## Shared Conventions

Every partial takes `css_classes: ""` and `**html_options`; a `data:` hash you pass is merged with the component's own attributes by `merge_component_data` (component identity keys `component`/`variant`/`size`/`*_part` win, `controller` and `action` concatenate, everything else is yours). Text parts (titles, descriptions, labels, cells) accept `text:`, `content:` (a `capture`), or a block. Most enum locals also accept strings (`"row"` for `:row`).

---

## Static Components

### Alert

**Purpose:** Callout for important messages and feedback.
**Files:** `_alert`, `alert/_title`, `alert/_description` · `alert.css` · `docs/alert.md`

| Partial | Key locals |
|---------|------------|
| `alert` | `variant: :default` (`:default`, `:destructive`, `:success`, `:warning`, `:info`; `:error` aliases `:destructive`), `icon: nil` |
| `alert/title`, `alert/description` | `text: nil`, `content: nil` |

```erb
<%= render "components/alert", variant: :destructive, icon: :triangle_alert do %>
  <%= render "components/alert/title", text: "Error" %>
  <%= render "components/alert/description", text: "Your session has expired." %>
<% end %>
```

---

### Badge

**Purpose:** Small label for status, tags, or counts.
**Files:** `_badge` · `badge.css` · `docs/badge.md`

| Local | Default | Values |
|-------|---------|--------|
| `variant` | `:default` | `:default`, `:primary`, `:secondary`, `:destructive`, `:success`, `:warning`, `:info`, `:outline` (`:error` aliases `:destructive`) |
| `size` | `:md` | `:sm`, `:md`, `:lg` (`:default` aliases `:md`) |

```erb
<%= render "components/badge", variant: :success, size: :sm do %>
  <%= icon_for :check, class: "size-3" %>
  Active
<% end %>

<%# Data attributes work on any element %>
<%= link_to "Users", users_path, data: { component: "badge", variant: "primary" } %>
```

---

### Card

**Purpose:** Contained box with optional header, action, content, and footer.
**Files:** `_card`, `card/_header`, `card/_title`, `card/_description`, `card/_action`, `card/_content`, `card/_footer` · `card.css` · `docs/card.md`

| Partial | Key locals |
|---------|------------|
| `card` | (only `css_classes`, `html_options`) |
| `card/header` | `layout: :column` (`:column`, `:row`) |
| `card/title` | `text:`, `content:`, `size: :default` (`:default`, `:sm`) |
| `card/description` | `text:`, `content:` |
| `card/content` | `spacing: :default` (`:default`, `:full` when there is no header) |
| `card/footer` | `align: :start` (`:start`, `:center`, `:end`, `:between`), `spacing: :default` (`:full` when there is no content) |
| `card/action` | (only `css_classes`, `html_options`) |

```erb
<%= render "components/card" do %>
  <%= render "components/card/header", layout: :row do %>
    <div>
      <%= render "components/card/title", text: "Team Members" %>
      <%= render "components/card/description", text: "Manage your team." %>
    </div>
    <%= render "components/card/action" do %>
      <%= link_to "Add", new_member_path, data: { component: "button", variant: "primary", size: "sm" } %>
    <% end %>
  <% end %>
  <%= render "components/card/content" do %>
    <p>No members yet.</p>
  <% end %>
  <%= render "components/card/footer", align: :end do %>
    <%= link_to "View all", members_path, data: { component: "button", variant: "outline" } %>
  <% end %>
<% end %>
```

---

### Separator

**Purpose:** Visual or semantic divider.
**Files:** `_separator` · `separator.css` · `docs/separator.md`

| Local | Default | Values |
|-------|---------|--------|
| `orientation` | `:horizontal` | `:horizontal`, `:vertical` |

```erb
<%= render "components/separator", css_classes: "my-4" %>
<%= render "components/separator", orientation: :vertical %>
```

---

### Empty

**Purpose:** Placeholder for lists or views with no data.
**Files:** `_empty`, `empty/_header`, `empty/_media`, `empty/_title`, `empty/_description`, `empty/_content` · `empty.css` · `empty_helper.rb` · `docs/empty.md`

| Partial | Key locals |
|---------|------------|
| `empty` | `variant: :default` (`:default`, `:outline`), `size: :default` (`:default`, `:compact`) |
| `empty/media` | `icon: nil`, `content: nil`, `variant: :icon` (`:icon`, `:avatar`) |
| `empty/title`, `empty/description` | `text:`, `content:` |
| `empty/header`, `empty/content` | (only `css_classes`, `html_options`) |

```erb
<%= empty_state title: "No projects yet",
  description: "Get started by creating your first project.",
  icon: :folder do %>
  <%= link_to "Create project", new_project_path, data: { component: "button", variant: "primary" } %>
<% end %>
```

Helpers: `empty_state`, `empty_search_state`, `empty_list_state` (see [Helper Modules](#helper-modules)).

---

### Stats

**Purpose:** Key metrics as cards in a responsive grid.
**Files:** `stats/_stats_grid`, `stats/_stats_card` (no root partial) · `stats.css` · `docs/stats.md`

| Partial | Key locals |
|---------|------------|
| `stats/stats_grid` | `cards: []` (hashes of stats_card locals), `columns: 3` (1-6), `action: nil` (captured HTML), `action_position: :end` (`:start`, `:end`) |
| `stats/stats_card` | `title:` (required), `value:` (required), `icon: nil`, `subtitle: nil`, `icon_classes: ""`, `value_classes: ""` |

Legacy aliases still accepted: `container_class` (for `css_classes`), `icon_class`, `value_class`.

```erb
<%= render "components/stats/stats_grid", columns: 3, cards: [
  { title: "Total Revenue", value: "$1,250.00", icon: :dollar, subtitle: "Trending up this month" },
  { title: "New Customers", value: "1,234", icon: :users },
  { title: "Open Tickets", value: "12", icon: :circle_alert, icon_classes: "text-amber-500" }
] %>
```

---

## Interactive Components

### Sidebar

**Purpose:** Collapsible app navigation with cookie persistence, icon rail, and mobile off-canvas.
**Files:**
- `_sidebar`, `sidebar/_provider`, `sidebar/_header`, `sidebar/_content`, `sidebar/_footer`, `sidebar/_group`, `sidebar/_group_action`, `sidebar/_menu`, `sidebar/_menu_item`, `sidebar/_menu_button`, `sidebar/_menu_link`, `sidebar/_menu_badge`, `sidebar/_menu_action`, `sidebar/_separator`, `sidebar/_trigger`, `sidebar/_inset`
- `sidebar.css` · `sidebar_controller.js`, `sidebar_trigger_controller.js` · `sidebar_helper.rb` · `docs/sidebar.md`

| Partial | Key locals |
|---------|------------|
| `sidebar/provider` | `id: nil` (→ `"sidebar-provider"`), `default_open: true`, `variant: :inset`, `cookie_name: "sidebar_state"`, `keyboard_shortcut: "b"` |
| `sidebar` | `id: nil` (→ `"sidebar-#{side}"`), `state: :collapsed` (`:expanded`, `:collapsed`), `collapsible: :offcanvas` (`:offcanvas`, `:icon`, `:none`), `variant: :inset` (`:sidebar`, `:floating`, `:inset`), `side: :left` |
| `sidebar/group` | `title: nil` |
| `sidebar/group_action` | `label:` (required), `url: nil`, `icon_name: :ellipsis` |
| `sidebar/menu_button` | `title:`, `url:` (required), `icon_name: nil`, `size: :default` (`:sm`, `:lg`), `active: false` |
| `sidebar/menu_link` | `url: "#"`, `title:`, `subtitle:`, `icon:` (image path), `text_icon:`, `icon_classes:`, `active: false` |
| `sidebar/menu_badge` | `text:`, `content:` |
| `sidebar/menu_action` | `label:` (required), `url: nil`, `icon_name: :ellipsis`, `show_on_hover: false` |
| `sidebar/trigger` | `icon_name: :left_panel` |
| `sidebar/separator` | `orientation: :horizontal` |
| `header`, `content`, `footer`, `menu`, `menu_item`, `inset` | (only `css_classes`, `html_options`) |

```erb
<%= render "components/sidebar/provider", default_open: sidebar_open? do %>
  <%= render "components/sidebar", state: sidebar_state, collapsible: :icon do %>
    <%= render "components/sidebar/header" do %>
      <%# Logo or menu_button %>
    <% end %>
    <%= render "components/sidebar/content" do %>
      <%= render "components/sidebar/group", title: "Navigation" do %>
        <%= render "components/sidebar/menu" do %>
          <%= render "components/sidebar/menu_item" do %>
            <%= render "components/sidebar/menu_button",
              title: "Dashboard", icon_name: :home, url: root_path,
              active: current_page?(root_path) %>
            <%= render "components/sidebar/menu_badge", text: "3" %>
          <% end %>
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

---

### Dropdown Menu

**Purpose:** Button-triggered menu of actions or links, with keyboard navigation and viewport flipping.
**Files:** `_dropdown_menu`, `dropdown_menu/_trigger`, `dropdown_menu/_content`, `dropdown_menu/_item`, `dropdown_menu/_label`, `dropdown_menu/_separator`, `dropdown_menu/_group`, `dropdown_menu/_shortcut` · `dropdown_menu.css` · `dropdown_menu_controller.js` · `dropdown_menu_helper.rb` · `docs/dropdown_menu.md`

| Partial | Key locals |
|---------|------------|
| `dropdown_menu` | `auto_close: false` (close on item click before Turbo navigates) |
| `dropdown_menu/trigger` | `variant: :outline`, `size: :default`, `as_child: false` (with `true` you write the trigger wiring yourself) |
| `dropdown_menu/content` | `align: :start` (`:start`, `:center`, `:end`), `side: :bottom` (`:top`, `:bottom`, `:left`, `:right`; a preference), `width: :default` (`:sm`, `:md`, `:lg`) |
| `dropdown_menu/item` | `href: nil` (link vs button), `method: nil`, `variant: :default` (`:destructive`), `disabled: false` |
| `dropdown_menu/label` | `text:`, `content:`, `inset: false` |
| `dropdown_menu/shortcut` | `text:`, `content:` |
| `separator`, `group` | (only `css_classes`, `html_options`) |

```erb
<%= render "components/dropdown_menu" do %>
  <%= render "components/dropdown_menu/trigger" do %>Options<% end %>
  <%= render "components/dropdown_menu/content", align: :end do %>
    <%= render "components/dropdown_menu/label", text: "Actions" %>
    <%= render "components/dropdown_menu/item", href: edit_project_path(@project) do %>
      <%= icon_for :pencil, class: "size-4" %>
      Edit
      <%= render "components/dropdown_menu/shortcut", text: "⌘E" %>
    <% end %>
    <%= render "components/dropdown_menu/separator" %>
    <%= render "components/dropdown_menu/item", href: project_path(@project), method: :delete, variant: :destructive do %>Delete<% end %>
  <% end %>
<% end %>

<%# Data-driven; item hashes take label, href, method, icon, destructive, disabled, action, data, separator, type (:item, :label, :separator) %>
<%= dropdown_menu_simple "Actions", items: [
  { label: "Edit", href: edit_project_path(@project), icon: :pencil },
  { separator: true },
  { label: "Delete", href: project_path(@project), method: :delete, destructive: true }
] %>
```

---

### Menu Button (+ Dropdown panel)

**Purpose:** Sidebar-flavored trigger with avatar and title/subtitle (workspace or account switcher) that opens a panel. `components/dropdown` is that panel; it is **not** an alias of Dropdown Menu.
**Files:** `_menu_button`, `_dropdown` · `menu_button.css` · `menu_button_controller.js` · `docs/menu_button.md`

| Partial | Key locals |
|---------|------------|
| `menu_button` | `title: ""`, `subtitle: nil`, `icon: nil` (image path), `text_icon: nil`, `icon_classes: ""`, `submenu: false` (chevron), `id: nil` (→ `"menu-button-#{title.parameterize}"`). Yields its id |
| `dropdown` | `id: nil` (pass the yielded id), `side: :top` (`:top`, `:bottom`), `align: :start` (`:start`, `:end`) |

```erb
<%= render "components/menu_button", title: "Acme Inc", subtitle: "Enterprise",
      text_icon: "A", submenu: true do |menu_id| %>
  <%= render "components/dropdown", id: menu_id, side: :bottom do %>
    <%= render "components/dropdown_menu/item", href: settings_path do %>Settings<% end %>
    <%= render "components/dropdown_menu/item", href: session_path, method: :delete do %>Sign out<% end %>
  <% end %>
<% end %>
```

---

### Breadcrumbs

**Purpose:** Trail of the current location; optionally collapses middle items into an ellipsis dropdown when they do not fit.
**Files:** `_breadcrumbs`, `breadcrumbs/_list`, `breadcrumbs/_item`, `breadcrumbs/_link`, `breadcrumbs/_page`, `breadcrumbs/_separator`, `breadcrumbs/_ellipsis` · `breadcrumbs.css` · `breadcrumb_controller.js` · `breadcrumbs_helper.rb` · `docs/breadcrumbs.md`

| Partial | Key locals |
|---------|------------|
| `breadcrumbs` | `responsive: false` (attaches the `breadcrumb` controller), `collapse_after: nil` (**deprecated, ignored**). `data: { size: :sm, separator: :slash }` for compact / text separators |
| `breadcrumbs/link` | `href:` (required); text via block |
| `breadcrumbs/page` | text via block |
| `breadcrumbs/separator` | `icon: :chevron_right` (`:custom` renders the block). Renders its own `<li>`: place it in the list, not in an item |
| `list`, `item`, `ellipsis` | (only `css_classes`, `html_options`) |

```erb
<%= render "components/breadcrumbs" do %>
  <%= render "components/breadcrumbs/list" do %>
    <%= render "components/breadcrumbs/item" do %>
      <%= render "components/breadcrumbs/link", href: root_path do %>Home<% end %>
    <% end %>
    <%= render "components/breadcrumbs/separator" %>
    <%= render "components/breadcrumbs/item" do %>
      <%= render "components/breadcrumbs/page" do %><%= @project.name %><% end %>
    <% end %>
  <% end %>
<% end %>

<%# Helpers: hash of text => path, then the current page %>
<%= breadcrumbs({ "Home" => root_path, "Projects" => projects_path }, @project.name) %>
<%= responsive_breadcrumbs({ "Home" => root_path, "Docs" => docs_path, "Components" => components_path }, "Breadcrumbs") %>
```

---

### Drawer

**Purpose:** Slide-out dialog panel with backdrop, focus management, and cookie persistence.
**Files:** `_drawer`, `drawer/_provider`, `drawer/_trigger`, `drawer/_header`, `drawer/_title`, `drawer/_description`, `drawer/_content`, `drawer/_section`, `drawer/_separator`, `drawer/_footer`, `drawer/_close` · `drawer.css` · `drawer_controller.js`, `drawer_trigger_controller.js` · `drawer_helper.rb` · `docs/drawer.md`

| Partial | Key locals |
|---------|------------|
| `drawer/provider` | `id: nil` (→ `"drawer-provider"` or `"drawer-provider-#{name}"`), `name: nil`, `default_open: false`, `cookie_name: "drawer_state"`, `keyboard_shortcut: "d"` |
| `drawer` | `id: nil` (→ `"drawer-#{side}"`), `state: :closed` (`:open`, `:closed`), `side: :right` (`:left`, `:right`), `aria_label: "Drawer"` |
| `drawer/trigger` | `variant: :default`, `size: :default`, `icon_name: nil`, `for_id: nil` (provider id or selector; defaults to every drawer) |
| `drawer/header` | `show_close: true` |
| `drawer/close` | `show_icon: true`, `variant: nil` (set it to render a regular button), `size: nil` |
| `drawer/title`, `drawer/description` | `text:`, `content:`, `tag: :h2` / `tag: :p` |
| `drawer/separator` | `orientation: :horizontal` |
| `content`, `section`, `footer` | (only `css_classes`, `html_options`) |

```erb
<%= render "components/drawer/trigger", icon_name: :left_panel do %>Open Drawer<% end %>

<%= render "components/drawer/provider" do %>
  <%= render "components/drawer", state: drawer_state do %>
    <%= render "components/drawer/header" do %>
      <%= render "components/drawer/title", text: "Filters" %>
      <%= render "components/drawer/description", text: "Narrow the results." %>
    <% end %>
    <%= render "components/drawer/content" do %>
      <%# Body %>
    <% end %>
    <%= render "components/drawer/footer" do %>
      <%= render "components/drawer/close", show_icon: false, variant: :outline do %>Cancel<% end %>
      <button type="button" data-component="button">Apply</button>
    <% end %>
  <% end %>
<% end %>
```

---

### Combobox

**Purpose:** Searchable select in a popover, with an optional hidden input for forms.
**Files:** `_combobox`, `combobox/_trigger`, `combobox/_content`, `combobox/_input`, `combobox/_list`, `combobox/_option`, `combobox/_group`, `combobox/_label`, `combobox/_separator`, `combobox/_empty` · `combobox.css` · `combobox_controller.js` · `combobox_helper.rb` · `docs/combobox.md`

| Partial | Key locals |
|---------|------------|
| `combobox` | `id: nil` (→ `"combobox-#{name}"` or `"combobox-default"`; yielded to the block), `name: nil` (renders a hidden input), `value: nil`, `placeholder: "Select..."` |
| `combobox/trigger` | `for_id:` (required), `placeholder: "Select..."`, `variant: :outline`, `size: :default` |
| `combobox/content` | `id:` (required), `align: :start` (`:start`, `:center`, `:end`), `width: :default` (`:sm`, `:md`, `:lg`, `:full`) |
| `combobox/input` | `placeholder: "Search..."` |
| `combobox/option` | `value:` (required), `selected: false`, `disabled: false` |
| `combobox/empty` | `text: "No results found."`, `content:` |
| `combobox/label` | `text:`, `content:` |
| `list`, `group`, `separator` | (only `css_classes`, `html_options`) |

```erb
<%= render "components/combobox", name: "project[framework]", value: @project.framework do |combobox_id| %>
  <%= render "components/combobox/trigger", for_id: combobox_id %>
  <%= render "components/combobox/content", id: combobox_id do %>
    <%= render "components/combobox/input" %>
    <%= render "components/combobox/list" do %>
      <%= render "components/combobox/option", value: "rails" do %>Ruby on Rails<% end %>
      <%= render "components/combobox/option", value: "phoenix" do %>Phoenix<% end %>
    <% end %>
    <%= render "components/combobox/empty" %>
  <% end %>
<% end %>

<%= combobox_simple name: "project[framework]", value: @project.framework,
      placeholder: "Select framework...",
      options: [{ value: "rails", label: "Ruby on Rails" }, { value: "phoenix", label: "Phoenix" }] %>
```

---

### Calendar

**Purpose:** Month grid for single or range date selection, rebuilt client-side on navigation.
**Files:** `_calendar`, `calendar/_header`, `calendar/_week` (both rendered internally) · `calendar.css` · `calendar_controller.js` · `calendar_helper.rb` · `docs/calendar.md`

| Local | Default | Notes |
|-------|---------|-------|
| `selected`, `selected_end` | `nil` | Date or ISO string; `selected_end` for range mode |
| `month`, `year` | `nil` | Display month; defaults to selected or current |
| `mode` | `:single` | `:single`, `:range` |
| `min_date`, `max_date`, `disabled_dates` | `nil`, `nil`, `[]` | Constraints, kept across months |
| `show_outside_days` | `true` | |
| `week_starts_on` | `:sunday` | `:sunday`, `:monday` |
| `cell_size` | `nil` | CSS length for `--cell-size` |
| `input_name`, `input_name_end` | `nil` | Render hidden inputs for forms |

```erb
<%= render "components/calendar", mode: :range,
      selected: @booking.check_in, selected_end: @booking.check_out,
      min_date: Date.today,
      input_name: "booking[check_in]", input_name_end: "booking[check_out]" %>
```

---

### Date Picker

**Purpose:** Trigger button that opens a popover calendar; shows the localized date.
**Files:** `_date_picker` (renders `components/calendar`) · `date_picker.css` · `date_picker_controller.js` · date picker helpers in `calendar_helper.rb` · `docs/date_picker.md`

| Local | Default | Notes |
|-------|---------|-------|
| `selected`, `selected_end`, `mode`, `min_date`, `max_date`, `disabled_dates`, `show_outside_days`, `week_starts_on` | as Calendar | Passed to the calendar |
| `placeholder` | `nil` | Falls back to "Select date" / "Select date range" |
| `input_name`, `input_name_end` | `nil` | Hidden inputs |
| `id` | `nil` | → `"date-picker-#{input_name}"`; popover is `#{id}-popover` |
| `disabled`, `required` | `false` | `required` goes on the start hidden input |
| `size` | `:default` | `:sm`, `:default`, `:lg` |
| `full_width` | `false` | Stretch wrapper and trigger |

```erb
<%= render "components/date_picker",
      selected: @event.starts_on,
      input_name: "event[starts_on]",
      placeholder: "Pick a date",
      size: :sm, full_width: true,
      data: { action: "date-picker:change->filters#apply" } %>
```

---

### Toggle Group

**Purpose:** Set of two-state buttons with single or multiple selection.
**Files:** `_toggle_group`, `toggle_group/_item` · `toggle_group.css` · `toggle_group_controller.js` · `toggle_group_helper.rb` · `docs/toggle_group.md`

| Partial | Key locals |
|---------|------------|
| `toggle_group` | `type: :single` (`:single`, `:multiple`), `variant: :default` (`:default`, `:outline`), `size: :default` (`:sm`, `:default`, `:lg`), `value: nil` (string or array; source of truth once JS connects), `disabled: false` |
| `toggle_group/item` | `value:` (required), `pressed: false`, `disabled: false`, `aria_label: nil` |

```erb
<%= render "components/toggle_group", type: :single, value: "center" do %>
  <%= render "components/toggle_group/item", value: "left", aria_label: "Align left" do %>
    <%= icon_for :align_left, class: "size-4" %>
  <% end %>
  <%= render "components/toggle_group/item", value: "center", aria_label: "Align center", pressed: true do %>
    <%= icon_for :align_center, class: "size-4" %>
  <% end %>
<% end %>

<%= toggle_group_simple type: :multiple, variant: :outline, value: ["bold"], items: [
  { value: "bold", icon: :bold, aria_label: "Bold" },
  { value: "italic", icon: :italic, aria_label: "Italic" }
] %>
```

---

### Toast / Toaster

**Purpose:** Temporary notifications. The toaster is placed once in the layout (always `id="toaster"`, so Turbo Streams can append to it) and exposes a global `window.Toast` JS API.
**Files:** `_toaster`, `_toast`, `toast/_title`, `toast/_description`, `toast/_action` · `toast.css` · `toast_controller.js`, `toaster_controller.js` · `toast_helper.rb` · `docs/toast.md`

| Partial | Key locals |
|---------|------------|
| `toaster` | `position: :bottom_right` (`:top_left`, `:top_center`, `:top_right`, `:bottom_left`, `:bottom_center`, `:bottom_right`), `content: nil` (does not yield) |
| `toast` | `variant: :default` (`:default`, `:success`, `:info`, `:warning`, `:error`; `:destructive` aliases `:error`), `title:`, `description:`, `icon: nil` (picked by variant), `duration: 5000` (0 = persistent), `dismissible: true`, `content: nil` (does not yield) |
| `toast/action` | `label:` (required), `href: nil` (nil renders a button wired to `toast#handleAction`), `method: nil` |
| `toast/title`, `toast/description` | `text:`, `content:` |

```erb
<%# Layout %>
<%= render "components/toaster", position: :bottom_right, content: toast_flash_messages %>

<%# Turbo Stream %>
<%= turbo_stream.append "toaster" do %>
  <%= toast_success "Saved", description: "Your changes have been saved." %>
<% end %>

<%= render "components/toast", title: "Message archived", duration: 0,
      content: capture { render("components/toast/action", label: "Undo", data: { action: "click->inbox#undo" }) } %>
```

```javascript
Toast.success("Message saved!")
Toast.error("Something went wrong", { description: "Please try again" })
Toast.show("Event created", { action: { label: "Undo", onClick: (e) => undo(e.detail.toastId) } })
```

---

## Form Components

Pure CSS, keyed on data attributes, so they work on Rails form builder output. All styles live in `form.css` (including `label`). Full reference: `docs/form.md`.

| `data-component` | Element | Extra attributes |
|------------------|---------|------------------|
| `form` | `<form>` | Parts: `data-form-part="group"` (`data-layout="inline"`), `"description"`, `"error"`, `"actions"` (`data-align="end"` / `"between"`) |
| `input` | text-like `<input>`, `type="file"` | `data-size="sm"` / `"lg"` |
| `textarea` | `<textarea>` | |
| `select` | native `<select>` | `data-mark="dark"` / `"light"` (chevron ink) |
| `checkbox` | `<input type="checkbox">` | `data-mark="dark"` |
| `radio` | `<input type="radio">` | `data-mark="dark"` |
| `switch` | `<input type="checkbox">` | `data-mark="dark"` |
| `button` | `<button>`, `<input type="submit">`, `<a>` | `data-variant`: `default`, `primary`, `secondary`, `destructive`, `outline`, `ghost`, `link`; `data-size`: `sm`, `lg`, `icon`, `icon-sm`, `icon-lg`; `aria-disabled="true"` on links |
| `fieldset` / `legend` | `<fieldset>` / `<legend>` | |
| `input-group` | wrapper `<div>` | Parts: `data-input-group-part="prefix"` / `"suffix"` |
| `label` | `<label>` | `data-required` shows the asterisk |

Error state: set `aria-invalid="true"` on the control (`:user-invalid` and Rails' `.field_with_errors` also apply) and render the message with `data-form-part="error"`.

```erb
<%= form_with model: @user, data: { component: "form" } do |f| %>
  <div data-form-part="group">
    <%= f.label :email, data: { component: "label", required: true } %>
    <%= f.email_field :email, data: { component: "input" },
          aria: { invalid: @user.errors[:email].any? } %>
  </div>
  <div data-form-part="group" data-layout="inline">
    <%= f.check_box :notifications, data: { component: "switch" } %>
    <%= f.label :notifications, "Enable notifications", data: { component: "label" } %>
  </div>
  <div data-form-part="actions" data-align="end">
    <%= link_to "Cancel", users_path, data: { component: "button", variant: "outline" } %>
    <%= f.submit "Save", data: { component: "button", variant: "primary" } %>
  </div>
<% end %>
```

### Label

**Purpose:** Accessible label for a form control (the partial form of `data-component="label"`).
**Files:** `_label` · styles in `form.css` · `docs/label.md`

| Local | Default | Notes |
|-------|---------|-------|
| `text`, `content` | `nil` | Or a block |
| `for_id` | `nil` | Rendered as `for`; a `for:` option also works |
| `required` | `false` | Adds `data-required` and the asterisk |

```erb
<%= render "components/label", text: "Email", for_id: "user_email", required: true %>
```

---

## Layout Components

### Header

**Purpose:** Page header bar, typically inside `sidebar/inset`.
**Files:** `_header` · `header.css` · `docs/header.md`

Locals: only `css_classes`, `html_options`. Parts: `data-header-part="title"`, `data-header-part="actions"`; a vertical separator inside is auto-sized.

```erb
<%= render "components/header" do %>
  <%= render "components/sidebar/trigger" %>
  <%= render "components/separator", orientation: :vertical %>
  <h1 data-header-part="title">Projects</h1>
  <div data-header-part="actions">
    <%= link_to "New", new_project_path, data: { component: "button", variant: "primary", size: "sm" } %>
  </div>
<% end %>
```

---

### Table

**Purpose:** Responsive data table, composed from partials or generated with `simple_table`.
**Files:** `_table`, `_simple_table`, `table/_header`, `table/_body`, `table/_footer`, `table/_row`, `table/_head`, `table/_cell`, `table/_caption` · `table.css` · `table_helper.rb` · `docs/table.md`

| Partial | Key locals |
|---------|------------|
| `table` | `container: true` (scroll wrapper), `variant: nil` (`:bordered`, on the container), `table_variant: nil` (`:striped`, on the table) |
| `table/header` | `sticky: false` |
| `table/row` | `selected: false` |
| `table/head` | `text:`, `content:`, `scope: "col"` |
| `table/cell` | `text:`, `content:`; `colspan`/`rowspan` pass through |
| `table/caption` | `text:`, `content:` |
| `table/body`, `table/footer` | (only `css_classes`, `html_options`) |
| `simple_table` | `collection:`, `columns:` (required), `caption:`, `variant:`, `table_variant:`, `empty_message: "No data available"`, `row_id:` |

```erb
<%= render "components/table", variant: :bordered do %>
  <%= render "components/table/header" do %>
    <%= render "components/table/row" do %>
      <%= render "components/table/head", text: "Name" %>
      <%= render "components/table/head", text: "Amount", css_classes: "text-right" %>
    <% end %>
  <% end %>
  <%= render "components/table/body" do %>
    <% @items.each do |item| %>
      <%= render "components/table/row" do %>
        <%= render "components/table/cell", text: item.name %>
        <%= render "components/table/cell", text: item.amount, css_classes: "text-right" %>
      <% end %>
    <% end %>
  <% end %>
<% end %>

<%= simple_table @invoices, caption: "Recent invoices", table_variant: :striped, row_id: :id, columns: [
  { key: :number, label: "Invoice" },
  { key: ->(i) { i.amount.format }, label: "Amount", align: :right }
] %>
```

---

### Pagination

**Purpose:** Page navigation; helpers build it from a Pagy object.
**Files:** `_pagination`, `pagination/_content`, `pagination/_item`, `pagination/_link`, `pagination/_previous`, `pagination/_next`, `pagination/_ellipsis` · `pagination.css` · `pagination_helper.rb` · `docs/pagination.md`

| Partial | Key locals |
|---------|------------|
| `pagination/link` | `href:` (required), `active: false`, `disabled: false` |
| `pagination/previous`, `pagination/next` | `href: nil` (nil = disabled), `label: nil` (I18n fallback), `disabled: false`, `show_label: true` |
| `pagination`, `content`, `item`, `ellipsis` | (only `css_classes`, `html_options`) |

```erb
<%= pagination_nav(@pagy, :users_path) %>
<%= pagination_nav(@pagy, :search_users_path, params: { q: params[:q] }, turbo: { action: :advance, frame: "users" }) %>
<%= pagination_simple(@pagy, :users_path) %>

<%= render "components/pagination" do %>
  <%= render "components/pagination/content" do %>
    <%= render "components/pagination/item" do %>
      <%= render "components/pagination/previous", href: "/page/1" %>
    <% end %>
    <%= render "components/pagination/item" do %>
      <%= render "components/pagination/link", href: "/page/2", active: true do %>2<% end %>
    <% end %>
    <%= render "components/pagination/item" do %>
      <%= render "components/pagination/next", href: "/page/3" %>
    <% end %>
  <% end %>
<% end %>
```

---

## Helper Modules

All modules live in `app/helpers/maquina_components/` and are available in host app views.

| Module | Public methods |
|--------|----------------|
| `IconsHelper` | `icon_for(name, options = {})` (host override first, then built-ins), `builtin_icon_for(name, options = {})` (built-ins only), `main_icon_svg_for(name)` (override in the host app to supply SVGs). Unknown names raise in dev/test when `MaquinaComponents.strict_icons` is on |
| `ComponentsHelper` | `merge_component_data(html_options, **component_data)` (data merging used by every partial) |
| `BreadcrumbsHelper` | `breadcrumbs(links = {}, current_page = nil, css_classes: "")`, `responsive_breadcrumbs(links = {}, current_page = nil, css_classes: "", collapse_after: nil)` |
| `CalendarHelper` | `calendar_to_date(value)`, `calendar_month_data(date, week_starts_on = :sunday)`, `calendar_month_name(date, format = :long)`, `calendar_date_in_range?(date, start_date, end_date)`, `calendar_data_attrs(mode:, selected:, selected_end:, month:, year:)`, `calendar_weekday_names(week_starts_on = :sunday, format = :short)`, `date_picker_data_attrs(mode:, selected:, selected_end:)`, `date_picker_format(date, format = :long)`, `date_picker_format_range(start_date, end_date, format = :short)`, `date_picker_locale_data` |
| `ComboboxHelper` | `combobox(id: nil, name: nil, value: nil, placeholder: "Select...", css_classes: "", **html_options) { \|cb\| }` (builder: `cb.trigger`, `cb.content { \|c\| }`, `c.input`, `c.list { \|l\| }`, `c.empty`, `l.option`, `l.group`, `l.label`, `l.separator`), `combobox_simple(options:, placeholder: "Select...", search_placeholder: "Search...", empty_text: "No results found.", value: nil, name: nil, trigger_options: {}, content_options: {})` |
| `DrawerHelper` | `drawer_state(cookie_name = "drawer_state")` → `:open` / `:closed`, `drawer_open?(cookie_name)`, `drawer_closed?(cookie_name)` |
| `DropdownMenuHelper` | `dropdown_menu(css_classes: "", **html_options) { \|menu\| }` (builder: `menu.trigger`, `menu.content { \|c\| }`, `c.item { \|item\| item.shortcut }`, `c.label`, `c.separator`, `c.group`), `dropdown_menu_simple(trigger_text, items:, trigger_options: {}, content_options: {})` |
| `EmptyHelper` | `empty_state(title:, description: nil, icon: nil, variant: :default, size: :default, css_classes: "", **html_options, &block)`, `empty_search_state(query: nil, reset_path: nil, size: :default)`, `empty_list_state(resource_name:, new_path: nil, icon: :folder, size: :default)` |
| `PaginationHelper` | `pagination_nav(pagy, route_helper, params: {}, turbo: {action: :replace}, show_labels: true, css_classes: "", **html_options)`, `pagination_simple(pagy, route_helper, params: {}, turbo: {action: :replace}, css_classes: "", **html_options)`, `paginated_path(route_helper, pagy, page, extra_params = {})` |
| `SidebarHelper` | `sidebar_state(cookie_name = "sidebar_state")` → `:expanded` / `:collapsed` (`:expanded` without a cookie), `sidebar_open?(cookie_name)`, `sidebar_closed?(cookie_name)` |
| `TableHelper` | `simple_table(collection, columns:, caption: nil, variant: nil, table_variant: nil, empty_message: "No data available", row_id: nil, **html_options)`, `table_alignment_class(align)`, `table_data_attrs`, `table_container_data_attrs`, `table_header_data_attrs`, `table_row_data_attrs`, `table_head_data_attrs`, `table_cell_data_attrs`, `table_body_data_attrs`, `table_footer_data_attrs`, `table_caption_data_attrs` |
| `ToastHelper` | `toast_flash_messages(exclude: [])`, `toast(variant, title, description: nil, **options)`, `toast_success(title, **options)`, `toast_error(...)`, `toast_warning(...)`, `toast_info(...)` |
| `ToggleGroupHelper` | `toggle_group(type: :single, variant: :default, size: :default, value: nil, disabled: false, css_classes: "", **html_options, &block)` (builder: `group.item(value:, label: nil, icon: nil, disabled: false, aria_label: nil, **options)`), `toggle_group_simple(items:, type: :single, variant: :default, size: :default, value: nil, disabled: false, css_classes: "", **html_options)` |

---

## Stimulus Controllers

Thirteen controllers in `app/javascript/controllers/`. Partials attach them automatically; the identifiers matter when you wire your own actions or compose markup by hand. Events are dispatched with Stimulus `dispatch`, so they bubble and are prefixed with the identifier.

| Identifier | Attached by | Targets | Values | Events / API |
|------------|-------------|---------|--------|--------------|
| `breadcrumb` | `breadcrumbs` with `responsive: true` | `item`, `ellipsis`, `ellipsisSeparator` | none | Re-fits on resize, font load and `turbo:morph` |
| `calendar` | `calendar` | `day`, `input`, `inputEnd`, `prevButton`, `nextButton`, `grid`, `caption` | `month`, `year`, `selected`, `selectedEnd`, `minDate`, `maxDate`, `mode`, `weekStartsOn`, `disabledDates`, `showOutsideDays` | `calendar:change`, `calendar:navigate`; `getValue()`, `select(date)`, `clear()` |
| `combobox` | `combobox` | `trigger`, `content`, `input`, `option`, `empty`, `label`, `hiddenInput` | `value`, `name`, `placeholder` | `combobox:change` (`{ value, label }`) |
| `date-picker` | `date_picker` | `trigger`, `popover`, `calendar`, `input`, `inputEnd`, `display` | `mode`, `selected`, `selectedEnd`, `format`, `placeholder`, `placeholderRange`, `locale` | `date-picker:change`, `date-picker:navigate`; `openPopover()`, `closePopover()`, `toggle()`, `clear()`, `getValue()`, `setValue(selected, selectedEnd)` |
| `drawer` | `drawer/provider` | `drawer`, `backdrop`, `panel` | `open`, `defaultOpen`, `cookieName`, `cookieMaxAge`, `keyboardShortcut` | `drawer:stateChanged` (`{ open, state }`); actions `toggle`, `open`, `close`, `backdropClick`, `closeOnEscape`, `toggleWithKeyboard` |
| `drawer-trigger` | `drawer/trigger` | outlet `drawer` | none | Action `triggerClick`; syncs `aria-expanded` from `drawer:stateChanged` |
| `dropdown-menu` | `dropdown_menu` | `trigger`, `content`, `chevron` | `open`, `autoClose` | Actions `toggle`, `open`, `close` |
| `menu-button` | `menu_button` | `button`, `content` (the `dropdown` panel) | `open` | Actions `toggle`, `open`, `close` |
| `sidebar` | `sidebar/provider` | `sidebar`, `container`, `backdrop` | `open`, `defaultOpen`, `cookieName`, `cookieMaxAge`, `keyboardShortcut` | `sidebar:stateChanged` (`{ open, mobile, state, collapsible }`); actions `toggle`, `open`, `close`, `toggleMobile`, `backdropClick`, `toggleWithKeyboard` |
| `sidebar-trigger` | `sidebar/trigger` | outlet `sidebar` | none | Action `triggerClick`; syncs `aria-expanded` from `sidebar:stateChanged` |
| `toast` | `toast` | none | `duration`, `dismissible`, `actionCallback` | `toast:action` (`{ toastId }`); actions `dismiss`, `handleAction` |
| `toaster` | `toaster` | `container` | `maxVisible` | Global `window.Toast`: `show`, `success`, `info`, `warning`, `error`, `destructive`, `dismiss(id)`, `dismissAll()` |
| `toggle-group` | `toggle_group` | `item` | `type`, `selected` | `toggle-group:change` (`{ type, value }`); `select(value)`, `deselect(value)`, `clear()`, `getValue()` |

All controllers that open something (drawer, sidebar, dropdown-menu, menu-button, date-picker, breadcrumb popover) reset before `turbo:before-cache`; sidebar and drawer also preserve their state through Turbo morph refreshes.

---

## Documentation Files

Component docs in `docs/` (each has matching previews in `test/dummy/app/views/previews/{component}/`):

| Doc | Covers |
|-----|--------|
| `docs/alert.md` | Alert |
| `docs/badge.md` | Badge |
| `docs/breadcrumbs.md` | Breadcrumbs |
| `docs/calendar.md` | Calendar |
| `docs/card.md` | Card |
| `docs/combobox.md` | Combobox |
| `docs/date_picker.md` | Date Picker |
| `docs/drawer.md` | Drawer |
| `docs/dropdown_menu.md` | Dropdown Menu |
| `docs/empty.md` | Empty |
| `docs/form.md` | Form CSS components (input, textarea, select, checkbox, radio, switch, button, fieldset, input group, label attributes) |
| `docs/header.md` | Header |
| `docs/label.md` | Label partial |
| `docs/menu_button.md` | Menu Button and the `dropdown` panel |
| `docs/pagination.md` | Pagination |
| `docs/separator.md` | Separator |
| `docs/sidebar.md` | Sidebar |
| `docs/stats.md` | Stats |
| `docs/table.md` | Table and `simple_table` |
| `docs/toast.md` | Toast, Toaster, `window.Toast` |
| `docs/toggle_group.md` | Toggle Group |

Guides: `docs/getting-started.md`, `docs/theming.md` (tokens), `docs/upgrading.md` (breaking changes).

---

## Adding Documentation for New Components

Create `docs/{component}.md` following the existing pages (`docs/badge.md` is the shortest model). Conventions:

- `# Name` followed by a `>` one-line description.
- A preview tag `<!-- preview:NAME height:N -->` above the usage block and above each example. Each `NAME` needs a file at `test/dummy/app/views/previews/{component}/NAME.html.erb`; `N` is the preview height in pixels.
- ERB inside code fences is escaped as `<%%=` / `<%%` so the docs page renders the code instead of executing it. Plain `<%#` comments are left as is.
- Icons in examples use `icon_for :name` with names that exist in `icons_helper.rb` (unknown names raise in development and test).
- API Reference has one table per partial with the columns Parameter, Type, Default, Description, then Helper Methods, Stimulus Controller, Events, Accessibility, or Turbo Drive sections only when they apply.
- New theme tokens go in `docs/theming.md`; breaking changes in `docs/upgrading.md`.

Template:

````markdown
# {Component Name}

> One-line description of the component.

<!-- preview:default height:100 -->

## Usage

```erb
<%%= render "components/{component}" do %>
  Content
<%% end %>
```

## Examples

### Variants

<!-- preview:variants height:100 -->

```erb
<%%= render "components/{component}", variant: :secondary do %>Secondary<%% end %>
<%%= render "components/{component}", variant: :outline do %>Outline<%% end %>
```

### With Icons

<!-- preview:with_icons height:100 -->

```erb
<%%= render "components/{component}" do %>
  <%%= icon_for :check, class: "size-4" %>
  Done
<%% end %>
```

## API Reference

### {Component Name}

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| variant | Symbol | :default | :default, :secondary, :outline |
| size | Symbol | :default | :sm, :default, :lg |
| css_classes | String | "" | Additional CSS classes |
| html_options | Hash | {} | Additional HTML attributes |

### {Component Name} Title

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| text | String | nil | Title text |
| content | String | nil | HTML content via `capture`, or use block |
| css_classes | String | "" | Additional CSS classes |
| html_options | Hash | {} | Additional HTML attributes |

### Helper Methods

| Method | Description |
|--------|-------------|
| `{component}_simple(items:, ...)` | Renders the component from data |

## Stimulus Controller

`{component}`, attached to the root.

| Target | Element |
|--------|---------|
| item | Each item |

| Value | Type | Default | Description |
|-------|------|---------|-------------|
| open | Boolean | false | Current state |

| Event | Detail | Description |
|-------|--------|-------------|
| {component}:change | value | Fired once per change |
````

After writing the doc: add the preview files, add a row to the Documentation Files table above, and add a section for the component to this index.
