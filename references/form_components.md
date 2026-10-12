# Form Components Guide

> Pure CSS form components that work seamlessly with Rails form helpers.

## Philosophy

Form components in maquina_components are **CSS-only**. No Ruby helpers needed. Just add data attributes to standard Rails form elements. All styles live in `app/assets/stylesheets/form.css`.

(The one partial is `components/label`, an optional convenience; `f.label ..., data: { component: "label" }` produces the same markup.)

## Available Form Components

| Component | Element | Data Attribute |
|-----------|---------|----------------|
| Form | `<form>` | `data-component="form"` (grid with gap) |
| Label | `<label>` | `data-component="label"` (+ `data-required`) |
| Button | `<button>`, `<input type="submit">`, `<a>` | `data-component="button"` |
| Input | `<input type="text/email/password/file/etc">` | `data-component="input"` |
| Textarea | `<textarea>` | `data-component="textarea"` |
| Select | `<select>` (native) | `data-component="select"` |
| Checkbox | `<input type="checkbox">` | `data-component="checkbox"` |
| Radio | `<input type="radio">` | `data-component="radio"` |
| Switch | `<input type="checkbox">` | `data-component="switch"` |
| Fieldset / Legend | `<fieldset>`, `<legend>` | `data-component="fieldset"` / `"legend"` |
| Input group | wrapper `<div>` | `data-component="input-group"` |

### Form Parts

| Attribute | Purpose |
|-----------|---------|
| `data-form-part="group"` | Label + field + help/error wrapper (`data-layout="inline"` for a horizontal row) |
| `data-form-part="description"` | Help text |
| `data-form-part="error"` | Error message (color from `--destructive-text`) |
| `data-form-part="actions"` | Submit area (`data-align="end"` or `"between"`) |
| `data-input-group-part="prefix"` / `"suffix"` | Adornments inside an input group |

## Button

### Variants

| Variant | Description |
|---------|-------------|
| (none) / `default` / `primary` | Brand color (`--primary`) — all three are the same treatment |
| `secondary` | Subtle (`--secondary`) |
| `destructive` | Danger fill; keeps a destructive focus ring |
| `outline` | Transparent + `--input` border |
| `ghost` | Transparent, no elevation |
| `link` | Looks like a link (no box) |

### Sizes

| Size | Description |
|------|-------------|
| `sm` | Small (`h-8`) |
| (default) | Medium (`h-9`, no data-size needed) |
| `lg` | Large (`h-10`) |
| `icon` | Square, icon only (`size-9`) |
| `icon-sm` | Small icon button (`size-8`) |
| `icon-lg` | Large icon button (`size-10`) |

SVGs inside a button are sized automatically (`size-4`).

### Usage

```erb
<%# With button_to %>
<%= button_to "Save", save_path,
  data: { component: "button", variant: "primary" } %>

<%# With link_to %>
<%= link_to "Cancel", cancel_path,
  data: { component: "button", variant: "outline" } %>

<%# Form submit %>
<%= form.submit "Create",
  data: { component: "button", variant: "primary" } %>

<%# Icon button — give it an accessible name %>
<%= link_to settings_path, aria: { label: "Settings" },
  data: { component: "button", variant: "ghost", size: "icon" } do %>
  <%= icon_for :settings %>
<% end %>

<%# With icon and text %>
<%= button_to export_path,
  data: { component: "button", variant: "primary" } do %>
  <%= icon_for :download %>
  Export
<% end %>

<%# Disabled %>
<%= button_tag "Disabled", type: :button, disabled: true,
  data: { component: "button", variant: "primary" } %>

<%# Disabled link %>
<%= link_to "Unavailable", "#", aria: { disabled: "true" }, tabindex: "-1",
  data: { component: "button", variant: "outline" } %>
```

There is no built-in loading state; disable the button and change its label (for example with Turbo's `data-turbo-submits-with`).

## Label

```erb
<%= form.label :email, data: { component: "label" } %>

<%# Required indicator (renders a trailing *) %>
<%= form.label :email, data: { component: "label", required: true } %>

<%# Partial form — for_id: because `for` is a Ruby keyword %>
<%= render "components/label", text: "Email", for_id: "user_email", required: true %>
```

A label directly followed by a `:disabled` control is dimmed automatically.

## Input

### Usage

```erb
<%# Basic %>
<%= form.text_field :name,
  data: { component: "input" },
  placeholder: "Enter name" %>

<%# Sizes %>
<%= form.text_field :name, data: { component: "input", size: "sm" } %>
<%= form.text_field :name, data: { component: "input", size: "lg" } %>

<%# Email / password / file %>
<%= form.email_field :email, data: { component: "input" }, placeholder: "email@example.com" %>
<%= form.password_field :password, data: { component: "input" } %>
<%= form.file_field :avatar, data: { component: "input" } %>

<%# With label and help text %>
<div data-form-part="group">
  <%= form.label :email, data: { component: "label" } %>
  <%= form.email_field :email, data: { component: "input" } %>
  <p data-form-part="description">We'll never share your email.</p>
</div>

<%# Disabled %>
<%= form.text_field :locked_field,
  data: { component: "input" },
  disabled: true %>

<%# With icon prefix (input group) %>
<div data-component="input-group">
  <span data-input-group-part="prefix"><%= icon_for :search, class: "size-4" %></span>
  <%= form.search_field :q, data: { component: "input" }, placeholder: "Search..." %>
</div>
```

### Validation Errors

Rails does **not** add `aria-invalid` on its own — it wraps the field in `<div class="field_with_errors">`. The engine styles both, so pick one:

1. **Set `aria-invalid` yourself** (recommended — screen readers get the state too):

```erb
<%= form.email_field :email,
  data: { component: "input" },
  aria: { invalid: @user.errors[:email].any?,
          describedby: ("email-error" if @user.errors[:email].any?) } %>
```

2. **Rely on Rails' `.field_with_errors` wrapper** — `form.css` already sets the wrapper to `display: contents` and paints the destructive border and ring on `input`, `textarea` and `select` inside it.

Input and textarea also match `:user-invalid` (native constraint validation, only after the user has interacted). A pristine `required` field renders normally.

## Textarea

```erb
<%# Basic %>
<%= form.text_area :description,
  data: { component: "textarea" },
  rows: 4,
  placeholder: "Enter description..." %>

<%# With character hint %>
<div data-form-part="group">
  <%= form.text_area :bio, data: { component: "textarea" }, rows: 3, maxlength: 280 %>
  <p data-form-part="description">Up to 280 characters.</p>
</div>
```

## Select

Native `<select>` with an SVG chevron (`--select-chevron-image`).

```erb
<%# Basic %>
<%= form.select :role,
  [["Admin", "admin"], ["User", "user"], ["Guest", "guest"]],
  {},
  data: { component: "select" } %>

<%# With blank option %>
<%= form.select :category_id,
  Category.pluck(:name, :id),
  { include_blank: "Select category..." },
  data: { component: "select" } %>

<%# Grouped options %>
<%= form.select :country,
  grouped_options_for_select(@grouped_countries),
  {},
  data: { component: "select" } %>

<%# Collection select %>
<%= form.collection_select :author_id,
  Author.all, :id, :name,
  { prompt: "Select author" },
  data: { component: "select" } %>

<%# Chevron ink override %>
<%= form.select :role, roles, {}, data: { component: "select", mark: "dark" } %>
```

For a searchable select use the Combobox component (`components/combobox` or the `combobox` helper).

## Checkbox

```erb
<%# Basic %>
<label class="flex items-center gap-2">
  <%= form.check_box :terms, data: { component: "checkbox" } %>
  <span class="text-sm">I agree to the terms</span>
</label>

<%# With description %>
<label class="flex items-start gap-2">
  <%= form.check_box :newsletter, data: { component: "checkbox" }, class: "mt-0.5" %>
  <div>
    <span data-component="label">Newsletter</span>
    <p data-form-part="description">Receive weekly updates</p>
  </div>
</label>

<%# Checkbox group %>
<fieldset data-component="fieldset">
  <legend>Notifications</legend>
  <% %w[email sms push].each do |type| %>
    <label class="flex items-center gap-2">
      <%= check_box_tag "notifications[]", type,
        @user.notifications.include?(type),
        data: { component: "checkbox" } %>
      <span class="text-sm"><%= type.titleize %></span>
    </label>
  <% end %>
</fieldset>

<%# Dark tick for a light --primary %>
<%= form.check_box :terms, data: { component: "checkbox", mark: "dark" } %>
```

`:indeterminate` is styled (set it from JavaScript: `checkbox.indeterminate = true`).

## Radio

```erb
<%# Radio group %>
<fieldset data-component="fieldset">
  <legend>Plan</legend>
  <% [["Free", "free"], ["Pro", "pro"], ["Enterprise", "enterprise"]].each do |label, value| %>
    <label class="flex items-center gap-2">
      <%= form.radio_button :plan, value, data: { component: "radio" } %>
      <span class="text-sm"><%= label %></span>
    </label>
  <% end %>
</fieldset>

<%# With descriptions %>
<fieldset class="space-y-3">
  <legend data-component="legend">Shipping</legend>
  <% @shipping_options.each do |option| %>
    <label class="flex items-start gap-2 p-3 border rounded-md cursor-pointer hover:bg-accent">
      <%= form.radio_button :shipping, option.id, data: { component: "radio" }, class: "mt-0.5" %>
      <div>
        <span class="text-sm font-medium"><%= option.name %></span>
        <p data-form-part="description"><%= option.description %></p>
      </div>
      <span class="ml-auto text-sm font-medium"><%= number_to_currency(option.price) %></span>
    </label>
  <% end %>
</fieldset>
```

## Switch

A styled checkbox that looks like a toggle switch.

```erb
<%# Basic %>
<label class="flex items-center gap-3">
  <%= form.check_box :active, data: { component: "switch" } %>
  <span class="text-sm">Active</span>
</label>

<%# With description %>
<div class="flex items-center justify-between">
  <div>
    <%= form.label :dark_mode, "Dark Mode", data: { component: "label" } %>
    <p data-form-part="description">Use dark theme</p>
  </div>
  <%= form.check_box :dark_mode, data: { component: "switch" } %>
</div>
```

For a single on/off button group, see Toggle Group instead.

## Form Layout Patterns

### Simple Form

```erb
<%= form_with model: @user, data: { component: "form" } do |form| %>
  <div data-form-part="group">
    <%= form.label :name, data: { component: "label" } %>
    <%= form.text_field :name, data: { component: "input" } %>
  </div>

  <div data-form-part="group">
    <%= form.label :email, data: { component: "label", required: true } %>
    <%= form.email_field :email, data: { component: "input" }, required: true %>
  </div>

  <div data-form-part="actions" data-align="end">
    <%= link_to "Cancel", users_path, data: { component: "button", variant: "outline" } %>
    <%= form.submit "Save", data: { component: "button", variant: "primary" } %>
  </div>
<% end %>
```

### Two-Column Form

```erb
<%= form_with model: @user, data: { component: "form" } do |form| %>
  <div class="grid grid-cols-2 gap-4">
    <div data-form-part="group">
      <%= form.label :first_name, data: { component: "label" } %>
      <%= form.text_field :first_name, data: { component: "input" } %>
    </div>
    <div data-form-part="group">
      <%= form.label :last_name, data: { component: "label" } %>
      <%= form.text_field :last_name, data: { component: "input" } %>
    </div>
  </div>

  <div data-form-part="group">
    <%= form.label :email, data: { component: "label" } %>
    <%= form.email_field :email, data: { component: "input" } %>
  </div>

  <div data-form-part="actions">
    <%= form.submit "Save", data: { component: "button", variant: "primary" } %>
  </div>
<% end %>
```

Utilities passed on the form (`class:` / `css_classes:`) override the engine's grid — e.g. `class: "flex"` really makes it flex.

### Form in Card

The submit button lives inside the `form_with` block (or uses the `form:` attribute pointing at the form's `id`):

```erb
<%= render "components/card" do %>
  <%= render "components/card/header" do %>
    <%= render "components/card/title", text: "Account Settings" %>
    <%= render "components/card/description", text: "Update your account information" %>
  <% end %>

  <%= render "components/card/content" do %>
    <%= form_with model: @user, id: "account_form", data: { component: "form" } do |form| %>
      <div data-form-part="group">
        <%= form.label :email, data: { component: "label" } %>
        <%= form.email_field :email, data: { component: "input" } %>
      </div>

      <div data-form-part="group">
        <%= form.label :password, "New Password", data: { component: "label" } %>
        <%= form.password_field :password, data: { component: "input" } %>
      </div>
    <% end %>
  <% end %>

  <%= render "components/card/footer", align: :end do %>
    <%= link_to "Cancel", settings_path, data: { component: "button", variant: "outline" } %>
    <%= submit_tag "Update", form: "account_form", data: { component: "button", variant: "primary" } %>
  <% end %>
<% end %>
```

## Error Display Pattern

```erb
<div data-form-part="group">
  <%= form.label :email, data: { component: "label" } %>
  <%= form.email_field :email, data: { component: "input" },
      aria: { invalid: @user.errors[:email].any?,
              describedby: ("email-error" if @user.errors[:email].any?) } %>
  <% if @user.errors[:email].any? %>
    <p data-form-part="error" id="email-error"><%= @user.errors[:email].to_sentence %></p>
  <% end %>
</div>
```

Or use a helper:

```ruby
# In application_helper.rb
def field_error(object, field)
  return unless object.errors[field].any?

  content_tag :p, object.errors[field].to_sentence,
    id: "#{field}-error", data: { form_part: "error" }
end
```

```erb
<div data-form-part="group">
  <%= form.label :email, data: { component: "label" } %>
  <%= form.email_field :email, data: { component: "input" },
      aria: { invalid: @user.errors[:email].any? } %>
  <%= field_error(@user, :email) %>
</div>
```

Error text reads `--destructive-text` (default `--destructive-foreground`). Under a saturated shadcn-style palette set `--destructive-text: var(--destructive)` and `--destructive-border: var(--destructive)` — see `theme_variables.md`.

## Scaffold Templates

`bin/rails generate maquina_components:scaffold_templates` copies ERB scaffold templates using these patterns into `lib/templates/erb/scaffold/`, so `rails generate scaffold` produces maquina-styled views.

## CSS Reference

### form.css Location

All form component styles are in `app/assets/stylesheets/form.css`, inside `@layer components`. Its header documents the cascade contract all engine stylesheets follow.

### Key Selectors

```css
/* Button */
[data-component="button"] { }
[data-component="button"]:where(:not([data-variant]), [data-variant="default"], [data-variant="primary"]) { }
[data-component="button"]:where([data-size="sm"]) { }
[data-component="button"]:where(:focus-visible) { }
[data-component="button"]:where(:disabled, [aria-disabled="true"]) { }

/* Input */
[data-component="input"] { }
[data-component="input"]:where([data-size="sm"]) { }
[data-component="input"]:where(:focus-visible) { }
[data-component="input"]:where([aria-invalid="true"], :user-invalid) { }
[data-component="input"]:where(:disabled) { }

/* Textarea */
[data-component="textarea"] { }

/* Select */
[data-component="select"] { }
[data-component="select"]:where([data-mark="dark"]) { }

/* Checkbox */
[data-component="checkbox"] { }
[data-component="checkbox"]:where(:checked) { }
[data-component="checkbox"]:where(:indeterminate) { }

/* Radio */
[data-component="radio"] { }
[data-component="radio"]:where(:checked) { }

/* Switch */
[data-component="switch"] { }
[data-component="switch"]:where(:checked) { }

/* Rails error wrapper */
.field_with_errors { }
:where(.field_with_errors) [data-component="input"] { }
```

### Tokens Read by Form Controls

| Token | Purpose |
|-------|---------|
| `--control-radius` (`--button-radius`, `--input-radius`, `--textarea-radius`, `--select-radius`) | Corner radius |
| `--mark-radius` (`--checkbox-radius`), `--pill-radius` (`--radio-radius`, `--switch-radius`) | Checkbox / radio / switch shape |
| `--control-fill` | Field background |
| `--elevation-control`, `--elevation-raised`, `--elevation-none` | Field / filled button / ghost-link shadows |
| `--focus-ring-*` | Focus ring |
| `--label-weight` | Label and button weight |
| `--primary-hover`, `--secondary-hover`, `--destructive-hover`, `--accent-hover` | Button hover fills |
| `--destructive-text`, `--destructive-border` | Error message and invalid border |
| `--checkbox-mark-image`, `--checkbox-indeterminate-image`, `--radio-mark-image`, `--switch-thumb-image`, `--select-chevron-image` | Control marks |
