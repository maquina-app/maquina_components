# Toggle Group

> A group of two-state buttons that can be toggled on or off.

---

## Quick Reference

### Helper Methods

| Method | Description |
|--------|-------------|
| `toggle_group` | Builder pattern for full control |
| `toggle_group_simple` | Data-driven for basic groups |

### Parts

| Partial | Description |
|---------|-------------|
| `components/toggle_group` | Root container |
| `components/toggle_group/item` | Individual toggle button |

### Parameters

#### `toggle_group`

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `type` | Symbol | `:single` | Selection mode: `:single`, `:multiple` |
| `variant` | Symbol | `:default` | Visual style: `:default`, `:outline` |
| `size` | Symbol | `:default` | Size: `:sm`, `:default`, `:lg` |
| `disabled` | Boolean | `false` | Disable all items |
| `orientation` | Symbol | `:horizontal` | Layout: `:horizontal`, `:vertical` |
| `name` | String | `nil` | Form field name (for hidden inputs) |
| `css_classes` | String | `""` | Additional CSS classes |
| `**html_options` | Hash | `{}` | HTML attributes |

#### `toggle_group/item`

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `value` | String | — | Value when selected |
| `pressed` | Boolean | `false` | Initial pressed state |
| `disabled` | Boolean | `false` | Disable this item |
| `css_classes` | String | `""` | Additional CSS classes |
| `**html_options` | Hash | `{}` | HTML attributes |

### Data Attributes

**Component Identifiers**

| Attribute | Element | Description |
|-----------|---------|-------------|
| `data-component="toggle-group"` | Container div | Main component identifier |
| `data-toggle-group-part="item"` | Button | Individual toggle item |

**State Attributes**

| Attribute | Description |
|-----------|-------------|
| `data-state="on"` | Item is pressed/selected |
| `data-state="off"` | Item is not pressed |
| `aria-pressed="true"` | Accessibility pressed state |
| `data-disabled="true"` | Item is disabled |

**Configuration Attributes**

| Attribute | Values | Description |
|-----------|--------|-------------|
| `data-type` | `single`, `multiple` | Selection mode |
| `data-variant` | `default`, `outline` | Visual variant |
| `data-size` | `sm`, `default`, `lg` | Size variant |
| `data-orientation` | `horizontal`, `vertical` | Layout direction |

**Stimulus Attributes**

| Attribute | Description |
|-----------|-------------|
| `data-controller="toggle-group"` | Stimulus controller |
| `data-toggle-group-target="item"` | Item target |
| `data-action="click->toggle-group#toggle"` | Toggle action |

---

## Basic Usage

### Using Helper (Recommended)

```erb
<%%= toggle_group do |group| %>
  <%% group.item value: "left", pressed: true do %>
    <%%= icon_for :align_left %>
  <%% end %>
  <%% group.item value: "center" do %>
    <%%= icon_for :align_center %>
  <%% end %>
  <%% group.item value: "right" do %>
    <%%= icon_for :align_right %>
  <%% end %>
<%% end %>
```

### Simple Data-Driven

```erb
<%%= toggle_group_simple items: [
  { value: "bold", icon: :bold, label: "Bold" },
  { value: "italic", icon: :italic, label: "Italic" },
  { value: "underline", icon: :underline, label: "Underline" }
], type: :multiple %>
```

### Using Partials

```erb
<%%= render "components/toggle_group", type: :single, variant: :outline do %>
  <%%= render "components/toggle_group/item", value: "list", pressed: true do %>
    <%%= icon_for :list %>
  <%% end %>
  <%%= render "components/toggle_group/item", value: "grid" do %>
    <%%= icon_for :grid %>
  <%% end %>
<%% end %>
```

---

## Examples

### Single Selection (Radio-like)

```erb
<%%= toggle_group type: :single, name: "view_mode" do |group| %>
  <%% group.item value: "list", pressed: @view_mode == "list" do %>
    <%%= icon_for :list, class: "size-4" %>
    <span class="sr-only">List view</span>
  <%% end %>
  <%% group.item value: "grid", pressed: @view_mode == "grid" do %>
    <%%= icon_for :grid, class: "size-4" %>
    <span class="sr-only">Grid view</span>
  <%% end %>
<%% end %>
```

### Multiple Selection (Checkbox-like)

```erb
<%%= toggle_group type: :multiple, name: "formatting[]" do |group| %>
  <%% group.item value: "bold", pressed: @formatting.include?("bold") do %>
    <%%= icon_for :bold, class: "size-4" %>
  <%% end %>
  <%% group.item value: "italic", pressed: @formatting.include?("italic") do %>
    <%%= icon_for :italic, class: "size-4" %>
  <%% end %>
  <%% group.item value: "underline", pressed: @formatting.include?("underline") do %>
    <%%= icon_for :underline, class: "size-4" %>
  <%% end %>
<%% end %>
```

### With Text Labels

```erb
<%%= toggle_group type: :single, size: :lg do |group| %>
  <%% group.item value: "day", pressed: true do %>
    Day
  <%% end %>
  <%% group.item value: "week" do %>
    Week
  <%% end %>
  <%% group.item value: "month" do %>
    Month
  <%% end %>
<%% end %>
```

### Outline Variant

```erb
<%%= toggle_group variant: :outline do |group| %>
  <%% group.item value: "left" do %>
    <%%= icon_for :align_left %>
  <%% end %>
  <%% group.item value: "center" do %>
    <%%= icon_for :align_center %>
  <%% end %>
  <%% group.item value: "right" do %>
    <%%= icon_for :align_right %>
  <%% end %>
<%% end %>
```

### Vertical Orientation

```erb
<%%= toggle_group orientation: :vertical do |group| %>
  <%% group.item value: "top" do %>
    <%%= icon_for :arrow_up %>
  <%% end %>
  <%% group.item value: "middle" do %>
    <%%= icon_for :minus %>
  <%% end %>
  <%% group.item value: "bottom" do %>
    <%%= icon_for :arrow_down %>
  <%% end %>
<%% end %>
```

### Disabled Items

```erb
<%%= toggle_group do |group| %>
  <%% group.item value: "edit" do %>
    <%%= icon_for :pencil %>
  <%% end %>
  <%% group.item value: "delete", disabled: true do %>
    <%%= icon_for :trash %>
  <%% end %>
<%% end %>
```

### Disabled Group

```erb
<%%= toggle_group disabled: true do |group| %>
  <%# All items are disabled %>
<%% end %>
```

---

## Real-World Patterns

### View Toggle in Toolbar

```erb
<div class="flex items-center justify-between p-4 border-b">
  <h2 class="text-lg font-semibold">Projects</h2>
  
  <%%= toggle_group type: :single, name: "view", size: :sm do |group| %>
    <%% group.item value: "list", pressed: params[:view] != "grid" do %>
      <%%= icon_for :list, class: "size-4" %>
    <%% end %>
    <%% group.item value: "grid", pressed: params[:view] == "grid" do %>
      <%%= icon_for :grid, class: "size-4" %>
    <%% end %>
  <%% end %>
</div>
```

### Text Editor Toolbar

```erb
<div class="flex items-center gap-1 p-2 border rounded-lg">
  <%%= toggle_group type: :multiple, variant: :outline, size: :sm do |group| %>
    <%% group.item value: "bold" do %>
      <%%= icon_for :bold, class: "size-4" %>
    <%% end %>
    <%% group.item value: "italic" do %>
      <%%= icon_for :italic, class: "size-4" %>
    <%% end %>
    <%% group.item value: "underline" do %>
      <%%= icon_for :underline, class: "size-4" %>
    <%% end %>
  <%% end %>
  
  <%%= render "components/separator", orientation: :vertical %>
  
  <%%= toggle_group type: :single, variant: :outline, size: :sm do |group| %>
    <%% group.item value: "left" do %>
      <%%= icon_for :align_left, class: "size-4" %>
    <%% end %>
    <%% group.item value: "center" do %>
      <%%= icon_for :align_center, class: "size-4" %>
    <%% end %>
    <%% group.item value: "right" do %>
      <%%= icon_for :align_right, class: "size-4" %>
    <%% end %>
  <%% end %>
</div>
```

### Filter Options

```erb
<%%= toggle_group type: :multiple, name: "status[]" do |group| %>
  <%% group.item value: "active", pressed: params[:status]&.include?("active") do %>
    <%%= render "components/badge", variant: :success, size: :sm do %>Active<%% end %>
  <%% end %>
  <%% group.item value: "pending", pressed: params[:status]&.include?("pending") do %>
    <%%= render "components/badge", variant: :warning, size: :sm do %>Pending<%% end %>
  <%% end %>
  <%% group.item value: "inactive", pressed: params[:status]&.include?("inactive") do %>
    <%%= render "components/badge", variant: :secondary, size: :sm do %>Inactive<%% end %>
  <%% end %>
<%% end %>
```

---

## Theme Variables

```css
var(--background)
var(--foreground)
var(--border)
var(--accent)
var(--accent-foreground)
var(--muted)
var(--muted-foreground)
```

---

## Customization

### Custom Active Color

Add to your CSS:

```css
[data-component="toggle-group"][data-variant="primary"] [data-state="on"] {
  background-color: var(--primary);
  color: var(--primary-foreground);
}
```

Usage:

```erb
<%%= toggle_group variant: :primary do |group| %>
  <!-- ... -->
<%% end %>
```

### Full Width Items

```erb
<%%= toggle_group css_classes: "w-full" do |group| %>
  <%% group.item value: "a", css_classes: "flex-1" do %>Option A<%% end %>
  <%% group.item value: "b", css_classes: "flex-1" do %>Option B<%% end %>
<%% end %>
```

---

## Form Integration

### With Hidden Input

The toggle group automatically manages hidden inputs when `name` is provided:

```erb
<%%= form_with model: @settings do |f| %>
  <%%= toggle_group type: :single, name: "settings[theme]" do |group| %>
    <%% group.item value: "light", pressed: @settings.theme == "light" do %>Light<%% end %>
    <%% group.item value: "dark", pressed: @settings.theme == "dark" do %>Dark<%% end %>
    <%% group.item value: "system", pressed: @settings.theme == "system" do %>System<%% end %>
  <%% end %>
  
  <%%= f.submit "Save", data: { component: "button", variant: "primary" } %>
<%% end %>
```

### Multiple Selection Form

```erb
<%%= toggle_group type: :multiple, name: "user[roles][]" do |group| %>
  <%% group.item value: "admin", pressed: @user.roles.include?("admin") do %>Admin<%% end %>
  <%% group.item value: "editor", pressed: @user.roles.include?("editor") do %>Editor<%% end %>
  <%% group.item value: "viewer", pressed: @user.roles.include?("viewer") do %>Viewer<%% end %>
<%% end %>
```

---

## Accessibility

- Uses `role="group"` on container
- Items are `<button>` elements with `aria-pressed`
- Keyboard navigation: Tab to focus, Space/Enter to toggle
- Disabled items have `aria-disabled="true"`
- Consider adding `.sr-only` labels for icon-only items

---

## File Structure

```
app/views/components/
├── _toggle_group.html.erb
└── toggle_group/
    └── _item.html.erb

app/assets/stylesheets/toggle_group.css
app/javascript/controllers/toggle_group_controller.js
app/helpers/maquina_components/toggle_group_helper.rb
docs/toggle_group.md
```
