# Form Components

> CSS-only form components styled with data attributes. Works directly with Rails form helpers.

---

## Quick Reference

### Components

| Component | Element | Description |
|-----------|---------|-------------|
| `label` | `<label>` | Form field label |
| `input` | `<input>` | Text input field |
| `textarea` | `<textarea>` | Multi-line text input |
| `select` | `<select>` | Dropdown select |
| `checkbox` | `<input type="checkbox">` | Checkbox input |
| `radio` | `<input type="radio">` | Radio button input |
| `switch` | `<input type="checkbox">` | Toggle switch (styled checkbox) |
| `button` | `<button>` / `<input type="submit">` | Form button |

### Form Structure

| Attribute | Element | Description |
|-----------|---------|-------------|
| `data-component="form"` | `<form>` | Optional form wrapper styling |
| `data-form-part="group"` | `<div>` | Field group container |
| `data-form-part="description"` | `<p>` | Help text below field |
| `data-form-part="error"` | `<p>` | Error message |

### Data Attributes

**Input Components**

| Attribute | Values | Description |
|-----------|--------|-------------|
| `data-component="input"` | — | Text input styling |
| `data-component="textarea"` | — | Textarea styling |
| `data-component="select"` | — | Select dropdown styling |
| `data-component="checkbox"` | — | Checkbox styling |
| `data-component="radio"` | — | Radio button styling |
| `data-component="switch"` | — | Toggle switch styling |
| `data-component="label"` | — | Label styling |

**Button Variants**

| Attribute | Values |
|-----------|--------|
| `data-component="button"` | Required for button styling |
| `data-variant` | `default`, `primary`, `secondary`, `destructive`, `outline`, `ghost`, `link` |
| `data-size` | `sm`, `default`, `lg`, `icon`, `icon-sm`, `icon-lg` |

**States (Automatic)**

| Attribute | Description |
|-----------|-------------|
| `aria-invalid="true"` | Applied by Rails on validation errors |
| `:disabled` | Standard HTML disabled state |
| `:required` | Standard HTML required state |

---

## Basic Usage

```erb
<%%= form_with model: @user, data: { component: "form" } do |f| %>
  <div data-form-part="group">
    <%%= f.label :email, data: { component: "label" } %>
    <%%= f.email_field :email, data: { component: "input" }, placeholder: "you@example.com" %>
    <p data-form-part="description">We'll never share your email.</p>
  </div>

  <div data-form-part="group">
    <%%= f.label :password, data: { component: "label" } %>
    <%%= f.password_field :password, data: { component: "input" } %>
  </div>

  <%%= f.submit "Sign up", data: { component: "button", variant: "primary" } %>
<%% end %>
```

---

## Examples

### All Input Types

```erb
<%# Text Input %>
<%%= f.text_field :name, data: { component: "input" }, placeholder: "Full name" %>

<%# Email Input %>
<%%= f.email_field :email, data: { component: "input" }, placeholder: "Email" %>

<%# Password Input %>
<%%= f.password_field :password, data: { component: "input" } %>

<%# Number Input %>
<%%= f.number_field :quantity, data: { component: "input" }, min: 1, max: 100 %>

<%# URL Input %>
<%%= f.url_field :website, data: { component: "input" }, placeholder: "https://" %>

<%# Search Input %>
<%%= f.search_field :query, data: { component: "input" }, placeholder: "Search..." %>
```

### Textarea

```erb
<%%= f.text_area :bio, data: { component: "textarea" }, rows: 4, placeholder: "Tell us about yourself..." %>
```

### Select

```erb
<%%= f.select :role, 
  [["Admin", "admin"], ["User", "user"], ["Guest", "guest"]], 
  { include_blank: "Select a role" },
  data: { component: "select" } %>
```

### Checkbox

```erb
<label class="flex items-center gap-2">
  <%%= f.check_box :remember_me, data: { component: "checkbox" } %>
  <span class="text-sm">Remember me</span>
</label>
```

### Checkbox Group

```erb
<fieldset>
  <legend class="text-sm font-medium mb-2">Notifications</legend>
  <div class="space-y-2">
    <label class="flex items-center gap-2">
      <%%= f.check_box :email_notifications, data: { component: "checkbox" } %>
      <span class="text-sm">Email notifications</span>
    </label>
    <label class="flex items-center gap-2">
      <%%= f.check_box :sms_notifications, data: { component: "checkbox" } %>
      <span class="text-sm">SMS notifications</span>
    </label>
  </div>
</fieldset>
```

### Radio Buttons

```erb
<fieldset>
  <legend class="text-sm font-medium mb-2">Plan</legend>
  <div class="space-y-2">
    <%% %w[free pro enterprise].each do |plan| %>
      <label class="flex items-center gap-2">
        <%%= f.radio_button :plan, plan, data: { component: "radio" } %>
        <span class="text-sm"><%%= plan.capitalize %></span>
      </label>
    <%% end %>
  </div>
</fieldset>
```

### Switch (Toggle)

```erb
<label class="flex items-center gap-3">
  <%%= f.check_box :dark_mode, data: { component: "switch" } %>
  <span class="text-sm">Enable dark mode</span>
</label>
```

### Buttons

```erb
<%# Primary button %>
<%%= f.submit "Save changes", data: { component: "button", variant: "primary" } %>

<%# Secondary button %>
<button type="button" data-component="button" data-variant="secondary">
  Cancel
</button>

<%# Destructive button %>
<%%= button_to "Delete", resource_path, 
  method: :delete, 
  data: { component: "button", variant: "destructive" } %>

<%# Icon button %>
<button type="button" data-component="button" data-variant="ghost" data-size="icon">
  <%%= icon_for :settings, class: "size-4" %>
</button>

<%# Button with icon %>
<button type="submit" data-component="button" data-variant="primary">
  <%%= icon_for :save, class: "size-4" %>
  Save
</button>
```

### With Validation Errors

Rails automatically adds `aria-invalid="true"` when there are validation errors:

```erb
<div data-form-part="group">
  <%%= f.label :email, data: { component: "label" } %>
  <%%= f.email_field :email, data: { component: "input" } %>
  <%% if @user.errors[:email].any? %>
    <p data-form-part="error"><%%= @user.errors[:email].first %></p>
  <%% end %>
</div>
```

### Field with Description

```erb
<div data-form-part="group">
  <%%= f.label :username, data: { component: "label" } %>
  <%%= f.text_field :username, data: { component: "input" }, placeholder: "johndoe" %>
  <p data-form-part="description">This will be your public display name.</p>
</div>
```

---

## Real-World Patterns

### Login Form

```erb
<%%= form_with url: sessions_path, data: { component: "form" } do |f| %>
  <div class="space-y-4">
    <div data-form-part="group">
      <%%= f.label :email, data: { component: "label" } %>
      <%%= f.email_field :email, data: { component: "input" }, placeholder: "you@example.com", required: true %>
    </div>

    <div data-form-part="group">
      <%%= f.label :password, data: { component: "label" } %>
      <%%= f.password_field :password, data: { component: "input" }, required: true %>
    </div>

    <div class="flex items-center justify-between">
      <label class="flex items-center gap-2">
        <%%= f.check_box :remember_me, data: { component: "checkbox" } %>
        <span class="text-sm">Remember me</span>
      </label>
      <%%= link_to "Forgot password?", forgot_password_path, class: "text-sm text-primary hover:underline" %>
    </div>

    <%%= f.submit "Sign in", data: { component: "button", variant: "primary" }, class: "w-full" %>
  </div>
<%% end %>
```

### Settings Form

```erb
<%%= form_with model: @settings, data: { component: "form" } do |f| %>
  <div class="space-y-6">
    <div data-form-part="group">
      <%%= f.label :display_name, data: { component: "label" } %>
      <%%= f.text_field :display_name, data: { component: "input" } %>
    </div>

    <div data-form-part="group">
      <%%= f.label :bio, data: { component: "label" } %>
      <%%= f.text_area :bio, data: { component: "textarea" }, rows: 3 %>
      <p data-form-part="description">Brief description for your profile.</p>
    </div>

    <div data-form-part="group">
      <%%= f.label :timezone, data: { component: "label" } %>
      <%%= f.time_zone_select :timezone, nil, {}, data: { component: "select" } %>
    </div>

    <div class="border-t pt-6">
      <h3 class="text-sm font-medium mb-4">Notifications</h3>
      <div class="space-y-4">
        <label class="flex items-center justify-between">
          <div>
            <span class="text-sm font-medium">Email notifications</span>
            <p class="text-sm text-muted-foreground">Receive emails about activity.</p>
          </div>
          <%%= f.check_box :email_notifications, data: { component: "switch" } %>
        </label>
        <label class="flex items-center justify-between">
          <div>
            <span class="text-sm font-medium">Marketing emails</span>
            <p class="text-sm text-muted-foreground">Receive tips and updates.</p>
          </div>
          <%%= f.check_box :marketing_emails, data: { component: "switch" } %>
        </label>
      </div>
    </div>

    <div class="flex gap-3">
      <%%= f.submit "Save changes", data: { component: "button", variant: "primary" } %>
      <%%= link_to "Cancel", settings_path, data: { component: "button", variant: "outline" } %>
    </div>
  </div>
<%% end %>
```

### Inline Form

```erb
<%%= form_with url: search_path, method: :get, class: "flex gap-2" do |f| %>
  <%%= f.search_field :q, data: { component: "input" }, placeholder: "Search...", class: "flex-1" %>
  <button type="submit" data-component="button" data-variant="primary">
    <%%= icon_for :search, class: "size-4" %>
  </button>
<%% end %>
```

---

## Theme Variables

```css
/* Inputs */
var(--background)
var(--foreground)
var(--border)
var(--input)
var(--muted-foreground)
var(--destructive)

/* Focus ring */
var(--ring)

/* Buttons */
var(--primary)
var(--primary-foreground)
var(--secondary)
var(--secondary-foreground)
var(--destructive)
var(--destructive-foreground)
var(--accent)
var(--accent-foreground)
```

---

## Customization

### Custom Input Sizes

Add to your CSS:

```css
[data-component="input"][data-size="sm"] {
  @apply h-8 text-sm px-2;
}

[data-component="input"][data-size="lg"] {
  @apply h-12 text-base px-4;
}
```

### Input with Icon

```erb
<div class="relative">
  <%%= icon_for :search, class: "absolute left-3 top-1/2 -translate-y-1/2 size-4 text-muted-foreground" %>
  <%%= f.search_field :q, data: { component: "input" }, class: "pl-10", placeholder: "Search..." %>
</div>
```

### Input with Button

```erb
<div class="flex">
  <%%= f.text_field :code, data: { component: "input" }, class: "rounded-r-none", placeholder: "Enter code" %>
  <button type="submit" data-component="button" data-variant="primary" class="rounded-l-none">
    Apply
  </button>
</div>
```

---

## Handling Rails Validation

### field_with_errors Wrapper

Rails wraps invalid fields in a `<div class="field_with_errors">`. The CSS handles this:

```css
.field_with_errors {
  display: contents;
}
```

This prevents layout disruption while preserving the error styling via `aria-invalid`.

### Error Display Pattern

```erb
<div data-form-part="group">
  <%%= f.label :email, data: { component: "label" } %>
  <%%= f.email_field :email, data: { component: "input" } %>
  <%% if @user.errors[:email].any? %>
    <p data-form-part="error">
      <%%= icon_for :alert_circle, class: "size-3 inline-block mr-1" %>
      <%%= @user.errors[:email].first %>
    </p>
  <%% end %>
</div>
```

---

## Accessibility

- All inputs should have associated labels
- Error messages are styled distinctively (color + icon)
- Focus states are clearly visible
- Disabled states reduce opacity
- Required fields can use HTML `required` attribute
- `aria-invalid` is automatically set by Rails

---

## File Structure

```
app/assets/stylesheets/form.css
docs/form.md
```

Note: Form components are CSS-only — no partials or helpers needed. Just use Rails form helpers with the appropriate `data-component` attributes.
