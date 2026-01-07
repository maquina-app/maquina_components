# Combobox

> Autocomplete input with searchable dropdown list for selecting from many options.

---

## Quick Reference

### Parts

| Partial | Description |
|---------|-------------|
| `components/combobox` | Root container with Stimulus controller |
| `components/combobox/trigger` | Button that opens the popover |
| `components/combobox/content` | Popover container |
| `components/combobox/input` | Search/filter input field |
| `components/combobox/list` | Scrollable options container |
| `components/combobox/option` | Selectable item with check indicator |
| `components/combobox/empty` | "No results" message |
| `components/combobox/group` | Logical grouping |
| `components/combobox/label` | Section heading |
| `components/combobox/separator` | Visual divider |

### Helper Methods

| Method | Description |
|--------|-------------|
| `combobox` | Builder pattern for full control |
| `combobox_simple` | Data-driven simple comboboxes |

### Parameters

#### `_combobox.html.erb`

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `id` | String | Auto-generated | Explicit ID for linking trigger to content |
| `name` | String | `nil` | Form field name |
| `value` | String | `nil` | Currently selected value |
| `placeholder` | String | `"Select..."` | Placeholder text for trigger |
| `css_classes` | String | `""` | Additional CSS classes |
| `**html_options` | Hash | `{}` | HTML attributes |

#### `combobox/_trigger.html.erb`

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `for_id` | String | Required | ID of content to control |
| `placeholder` | String | `"Select..."` | Placeholder text |
| `variant` | Symbol | `:outline` | Button variant |
| `size` | Symbol | `:default` | Button size |
| `css_classes` | String | `""` | Additional CSS classes |
| `**html_options` | Hash | `{}` | HTML attributes |

#### `combobox/_content.html.erb`

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `id` | String | Required | Popover ID (matches trigger's `for_id`) |
| `align` | Symbol | `:start` | Alignment: `:start`, `:center`, `:end` |
| `width` | Symbol | `:default` | Width: `:sm`, `:default`, `:md`, `:lg`, `:full` |
| `css_classes` | String | `""` | Additional CSS classes |
| `**html_options` | Hash | `{}` | HTML attributes |

#### `combobox/_input.html.erb`

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `placeholder` | String | `"Search..."` | Input placeholder |
| `css_classes` | String | `""` | Additional CSS classes |
| `**html_options` | Hash | `{}` | HTML attributes |

#### `combobox/_option.html.erb`

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `value` | String | Required | Option value |
| `selected` | Boolean | `false` | Whether initially selected |
| `disabled` | Boolean | `false` | Whether disabled |
| `css_classes` | String | `""` | Additional CSS classes |
| `**html_options` | Hash | `{}` | HTML attributes |

#### `combobox/_empty.html.erb`

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `text` | String | `"No results found."` | Empty state message |
| `css_classes` | String | `""` | Additional CSS classes |
| `**html_options` | Hash | `{}` | HTML attributes |

### Data Attributes

**Component Identifiers**

| Attribute | Element | Description |
|-----------|---------|-------------|
| `data-component="combobox"` | Root container | Main component identifier |
| `data-controller="combobox"` | Root container | Stimulus controller |
| `data-combobox-part="trigger"` | Button | Trigger element |
| `data-combobox-part="content"` | Popover | Content container |
| `data-combobox-part="input"` | Input | Search field |
| `data-combobox-part="list"` | Div | Options container |
| `data-combobox-part="option"` | Div | Selectable option |
| `data-combobox-part="check"` | Span | Check indicator |
| `data-combobox-part="empty"` | Div | Empty state |

**Stimulus Targets**

| Attribute | Description |
|-----------|-------------|
| `data-combobox-target="trigger"` | Trigger button |
| `data-combobox-target="content"` | Popover content |
| `data-combobox-target="input"` | Search input |
| `data-combobox-target="option"` | Option items |
| `data-combobox-target="empty"` | Empty state |
| `data-combobox-target="label"` | Selected value label |

**State Attributes**

| Attribute | Description |
|-----------|-------------|
| `data-selected="true"` | Option is selected |
| `data-has-value="true"` | Trigger has a value selected |
| `aria-selected="true"` | ARIA selected state |
| `aria-expanded="true"` | Popover is open |

---

## Basic Usage

### Using the Helper (Recommended)

```erb
<%%= combobox placeholder: "Select framework..." do |cb| %>
  <%% cb.trigger %>
  <%% cb.content do %>
    <%% cb.input placeholder: "Search frameworks..." %>
    <%% cb.list do %>
      <%% cb.option value: "nextjs" do %>Next.js<%% end %>
      <%% cb.option value: "sveltekit" do %>SvelteKit<%% end %>
      <%% cb.option value: "nuxt" do %>Nuxt.js<%% end %>
      <%% cb.option value: "remix" do %>Remix<%% end %>
      <%% cb.option value: "astro" do %>Astro<%% end %>
    <%% end %>
    <%% cb.empty %>
  <%% end %>
<%% end %>
```

### Using Partials

```erb
<%%= render "components/combobox", placeholder: "Select framework..." do |combobox_id| %>
  <%%= render "components/combobox/trigger", for_id: combobox_id, placeholder: "Select framework..." %>

  <%%= render "components/combobox/content", id: combobox_id do %>
    <%%= render "components/combobox/input", placeholder: "Search..." %>

    <%%= render "components/combobox/list" do %>
      <%%= render "components/combobox/option", value: "nextjs" do %>Next.js<%% end %>
      <%%= render "components/combobox/option", value: "sveltekit" do %>SvelteKit<%% end %>
      <%%= render "components/combobox/option", value: "nuxt" do %>Nuxt.js<%% end %>
    <%% end %>

    <%%= render "components/combobox/empty" %>
  <%% end %>
<%% end %>
```

### Simple Data-Driven

```erb
<%%= combobox_simple placeholder: "Select framework...",
                     options: [
                       { value: "nextjs", label: "Next.js" },
                       { value: "sveltekit", label: "SvelteKit" },
                       { value: "nuxt", label: "Nuxt.js" },
                       { value: "remix", label: "Remix" },
                       { value: "astro", label: "Astro" }
                     ] %>
```

---

## Examples

### With Pre-selected Value

```erb
<%%= combobox_simple placeholder: "Select framework...",
                     value: "remix",
                     options: [
                       { value: "nextjs", label: "Next.js" },
                       { value: "sveltekit", label: "SvelteKit" },
                       { value: "remix", label: "Remix" }
                     ] %>
```

### With Disabled Options

```erb
<%%= combobox_simple placeholder: "Select framework...",
                     options: [
                       { value: "nextjs", label: "Next.js" },
                       { value: "angular", label: "Angular (deprecated)", disabled: true },
                       { value: "remix", label: "Remix" }
                     ] %>
```

### With Groups

```erb
<%%= combobox placeholder: "Select technology..." do |cb| %>
  <%% cb.trigger %>
  <%% cb.content width: :md do %>
    <%% cb.input %>
    <%% cb.list do %>
      <%% cb.group do %>
        <%% cb.label "Frontend Frameworks" %>
        <%% cb.option value: "react" do %>React<%% end %>
        <%% cb.option value: "vue" do %>Vue<%% end %>
        <%% cb.option value: "svelte" do %>Svelte<%% end %>
      <%% end %>
      <%% cb.separator %>
      <%% cb.group do %>
        <%% cb.label "Backend Frameworks" %>
        <%% cb.option value: "rails" do %>Ruby on Rails<%% end %>
        <%% cb.option value: "django" do %>Django<%% end %>
        <%% cb.option value: "phoenix" do %>Phoenix<%% end %>
      <%% end %>
    <%% end %>
    <%% cb.empty %>
  <%% end %>
<%% end %>
```

### Width Variants

```erb
<%# Small width %>
<%%= combobox placeholder: "Size" do |cb| %>
  <%% cb.trigger %>
  <%% cb.content width: :sm do %>
    <%# ... %>
  <%% end %>
<%% end %>

<%# Large width %>
<%%= combobox placeholder: "Select a very long option name..." do |cb| %>
  <%% cb.trigger %>
  <%% cb.content width: :lg do %>
    <%# ... %>
  <%% end %>
<%% end %>
```

### Custom Alignment

```erb
<%# End-aligned (right) %>
<%%= combobox placeholder: "Select..." do |cb| %>
  <%% cb.trigger %>
  <%% cb.content align: :end do %>
    <%# ... %>
  <%% end %>
<%% end %>
```

---

## Real-World Patterns

### Country Selector

```erb
<%%= combobox placeholder: "Select country...", name: "user[country]" do |cb| %>
  <%% cb.trigger %>
  <%% cb.content width: :md do %>
    <%% cb.input placeholder: "Search countries..." %>
    <%% cb.list do %>
      <%% Country.all.each do |country| %>
        <%% cb.option value: country.code, selected: @user.country == country.code do %>
          <%%= country.flag %> <%%= country.name %>
        <%% end %>
      <%% end %>
    <%% end %>
    <%% cb.empty text: "No countries found." %>
  <%% end %>
<%% end %>
```

### User Selector

```erb
<%%= combobox placeholder: "Assign to...", id: "assignee-select" do |cb| %>
  <%% cb.trigger variant: :ghost %>
  <%% cb.content width: :lg do %>
    <%% cb.input placeholder: "Search team members..." %>
    <%% cb.list do %>
      <%% @team_members.each do |member| %>
        <%% cb.option value: member.id do %>
          <div class="flex items-center gap-2">
            <%%= image_tag member.avatar_url, class: "size-6 rounded-full" %>
            <span><%%= member.name %></span>
            <span class="text-muted-foreground text-xs"><%%= member.role %></span>
          </div>
        <%% end %>
      <%% end %>
    <%% end %>
    <%% cb.empty %>
  <%% end %>
<%% end %>
```

### Status Selector

```erb
<%%= combobox placeholder: "Set status...", value: @task.status do |cb| %>
  <%% cb.trigger %>
  <%% cb.content do %>
    <%% cb.input placeholder: "Search statuses..." %>
    <%% cb.list do %>
      <%% cb.option value: "backlog" do %>
        <%%= render "components/badge", variant: :secondary do %>Backlog<%% end %>
      <%% end %>
      <%% cb.option value: "todo" do %>
        <%%= render "components/badge", variant: :default do %>Todo<%% end %>
      <%% end %>
      <%% cb.option value: "in_progress" do %>
        <%%= render "components/badge", variant: :warning do %>In Progress<%% end %>
      <%% end %>
      <%% cb.option value: "done" do %>
        <%%= render "components/badge", variant: :success do %>Done<%% end %>
      <%% end %>
      <%% cb.option value: "cancelled" do %>
        <%%= render "components/badge", variant: :destructive do %>Cancelled<%% end %>
      <%% end %>
    <%% end %>
    <%% cb.empty %>
  <%% end %>
<%% end %>
```

### With Form Builder

```erb
<%%= form_with model: @project do |f| %>
  <div class="space-y-4">
    <%%= render "components/label", for: "project_framework" do %>Framework<%% end %>

    <%%= combobox_simple id: "project_framework",
                         name: "project[framework]",
                         value: @project.framework,
                         placeholder: "Select framework...",
                         options: Framework.all.map { |fw|
                           { value: fw.slug, label: fw.name }
                         } %>

    <%%= f.submit "Save", data: { component: "button", variant: "primary" } %>
  </div>
<%% end %>
```

### Listening for Changes (Stimulus)

```erb
<div data-controller="project-form">
  <%%= combobox placeholder: "Select framework...",
               data: { action: "combobox:change->project-form#frameworkChanged" } do |cb| %>
    <%# ... %>
  <%% end %>
</div>
```

```javascript
// project_form_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  frameworkChanged(event) {
    const { value, label } = event.detail
    console.log(`Selected: ${label} (${value})`)
  }
}
```

---

## Browser Support & Polyfill

The combobox uses the HTML5 Popover API for light-dismiss behavior. For browsers without native support, use a polyfill.

### Browser Support

| Browser | Version | Native Support |
|---------|---------|----------------|
| Chrome | 114+ | Yes |
| Edge | 114+ | Yes |
| Safari | 17+ | Yes |
| Firefox | 125+ | Yes |
| Safari iOS | 17+ | Yes |

### Installing the Polyfill

**Option 1: NPM Package**

```bash
npm install @oddbird/popover-polyfill
# or
yarn add @oddbird/popover-polyfill
```

```javascript
// app/javascript/application.js
import "@oddbird/popover-polyfill"
```

**Option 2: CDN**

```erb
<%# In your layout head %>
<script src="https://cdn.jsdelivr.net/npm/@oddbird/popover-polyfill@latest/dist/popover.min.js" crossorigin="anonymous" defer></script>
```

**Option 3: Import Map (Rails 7+)**

```ruby
# config/importmap.rb
pin "@oddbird/popover-polyfill", to: "https://cdn.jsdelivr.net/npm/@oddbird/popover-polyfill@latest/dist/popover.min.js"
```

```javascript
// app/javascript/application.js
import "@oddbird/popover-polyfill"
```

---

## Keyboard Navigation

| Key | Action |
|-----|--------|
| `Enter` / `Space` | Open combobox (on trigger), select option |
| `Escape` | Close combobox |
| `↓` | Focus next option |
| `↑` | Focus previous option |
| `Home` | Focus first option |
| `End` | Focus last option |
| Type characters | Filter options |

---

## Theme Variables

The combobox component uses these CSS variables from your theme:

```css
/* Popover/Content */
var(--popover)
var(--popover-foreground)
var(--border)

/* Options */
var(--accent)
var(--accent-foreground)
var(--muted-foreground)

/* Focus ring (inherited from button) */
var(--ring)
var(--background)
```

---

## Accessibility

- Trigger has `role="combobox"` with `aria-expanded` and `aria-haspopup="listbox"`
- Content has `role="listbox"`
- Options have `role="option"` with `aria-selected`
- Disabled options have `aria-disabled="true"`
- Keyboard navigation fully supported
- Focus returns to trigger when closed
- Light-dismiss (click outside) closes the popover

---

## File Structure

```
app/views/components/
├── _combobox.html.erb
└── combobox/
    ├── _trigger.html.erb
    ├── _content.html.erb
    ├── _input.html.erb
    ├── _list.html.erb
    ├── _option.html.erb
    ├── _empty.html.erb
    ├── _group.html.erb
    ├── _label.html.erb
    └── _separator.html.erb

app/assets/stylesheets/combobox.css
app/javascript/controllers/combobox_controller.js
app/helpers/maquina_components/combobox_helper.rb
docs/combobox.md
```

---

## Differences from Dropdown Menu

| Feature | Combobox | Dropdown Menu |
|---------|----------|---------------|
| **Purpose** | Selection from many options | Actions/navigation |
| **Search** | Yes (filterable) | No |
| **Selection** | Single value with indicator | No selection state |
| **ARIA Role** | `combobox` + `listbox` | `menu` + `menuitem` |
| **Popover API** | Yes (HTML5 native) | No (Stimulus-managed) |
| **Items** | Options with values | Action links/buttons |
