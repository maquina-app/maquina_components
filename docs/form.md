# Form

> CSS-only form components styled with data attributes for Rails form helpers.

<!-- preview:default height:280 -->

## Usage

```erb
<%%= form_with model: @user, data: { component: "form" } do |f| %>
  <div data-form-part="group">
    <%%= f.label :email, data: { component: "label" } %>
    <%%= f.email_field :email, data: { component: "input" }, placeholder: "you@example.com" %>
  </div>

  <div data-form-part="actions">
    <%%= f.submit "Sign in", data: { component: "button", variant: "primary" } %>
  </div>
<%% end %>
```

## Examples

### Input

<!-- preview:input height:280 -->

```erb
<%%= f.text_field :name, data: { component: "input" }, placeholder: "Full name" %>
<%%= f.text_field :name, data: { component: "input", size: "sm" } %>
<%%= f.text_field :name, data: { component: "input", size: "lg" } %>
```

### Textarea

<!-- preview:textarea height:200 -->

```erb
<%%= f.text_area :bio, data: { component: "textarea" }, rows: 4 %>
```

### Select

<!-- preview:select height:160 -->

```erb
<%%= f.select :country, options, {}, data: { component: "select" } %>
```

### Checkbox

<!-- preview:checkbox height:160 -->

```erb
<div data-form-part="group" data-layout="inline">
  <%%= f.check_box :terms, data: { component: "checkbox" } %>
  <%%= f.label :terms, "Accept terms", data: { component: "label" } %>
</div>
```

### Radio

<!-- preview:radio height:180 -->

```erb
<div data-form-part="group" data-layout="inline">
  <%%= f.radio_button :plan, "pro", data: { component: "radio" } %>
  <%%= f.label :plan_pro, "Pro", data: { component: "label" } %>
</div>
```

### Switch

<!-- preview:switch height:160 -->

```erb
<div data-form-part="group" data-layout="inline">
  <%%= f.check_box :notifications, data: { component: "switch" } %>
  <%%= f.label :notifications, "Enable notifications", data: { component: "label" } %>
</div>
```

### Button

<!-- preview:button height:280 -->

```erb
<button data-component="button" data-variant="primary">Primary</button>
<button data-component="button" data-variant="secondary">Secondary</button>
<button data-component="button" data-variant="destructive">Destructive</button>
<button data-component="button" data-variant="outline">Outline</button>
<button data-component="button" data-variant="ghost">Ghost</button>
<button data-component="button" data-variant="link">Link</button>

<button data-component="button" data-size="sm">Small</button>
<button data-component="button" data-size="lg">Large</button>
<button data-component="button" data-variant="outline" data-size="icon">
  <%%= icon_for :settings, class: "size-4" %>
  <span class="sr-only">Settings</span>
</button>
```

### Fieldset

```erb
<fieldset data-component="fieldset">
  <legend>Notifications</legend>
  <div data-form-part="group">
    <%%= f.label :email, data: { component: "label" } %>
    <%%= f.email_field :email, data: { component: "input" } %>
  </div>
</fieldset>
```

### Input Group

```erb
<div data-component="input-group">
  <span data-input-group-part="prefix">$</span>
  <%%= f.number_field :price, data: { component: "input" } %>
  <span data-input-group-part="suffix">USD</span>
</div>
```

### Actions

```erb
<div data-form-part="actions" data-align="end">
  <%%= link_to "Cancel", users_path, data: { component: "button", variant: "outline" } %>
  <%%= f.submit "Save", data: { component: "button" } %>
</div>
```

## Error States

<!-- preview:error height:560 -->

The error state is driven by `aria-invalid` on the field. Set it from your model
and the border, the focus ring and the message all follow:

```erb
<div data-form-part="group">
  <%%= f.label :email, data: { component: "label" } %>
  <%%= f.email_field :email, data: { component: "input" },
      aria: { invalid: @user.errors[:email].any?,
              describedby: ("email-error" if @user.errors[:email].any?) } %>
  <%% if @user.errors[:email].any? %>
    <p data-form-part="error" id="email-error"><%%= @user.errors[:email].first %></p>
  <%% end %>
</div>
```

Every control — input, textarea, select, checkbox, radio and switch — shows the
same error state: a `--destructive` border at rest, and a destructive focus ring
only while it has keyboard focus. Each reacts to `aria-invalid="true"` and to
`:user-invalid` (a `required` checkbox left unchecked after submit, for example).
A switch's track has no visible border at rest, so the invalid state outlines it.

Rails' own `.field_with_errors` wrapper is styled too, so an app that leans on
the default wrapper gets the same treatment without setting anything.

### Do not rely on `:invalid` alone

Before 0.7.1 the engine also matched `:invalid:not(:placeholder-shown)`, which
meant a `required` field with no `placeholder` painted the error state on first
paint — before focus, before blur, before submit — while telling screen readers
nothing, because no `aria-invalid` accompanied it.

That is now `:user-invalid`, which only matches once the reader has actually
interacted with the field. Two consequences:

- A pristine `required` field renders normally. You no longer need a placeholder
  to suppress a false error.
- If you render server-side errors and never set `aria-invalid`, you were relying
  on the old `:invalid` match and the border will stop appearing. Set
  `aria-invalid` as above.

`bin/rails maquina:doctor` reports the second case as
`invalid-styling-without-aria`.

### Error text colour

The message reads `--destructive-text` and the invalid border reads
`--destructive-border`. Both default to what they painted before, so the
installer's palette needs no change. If your palette is the saturated
shadcn kind — `--destructive` a strong red, `--destructive-foreground`
near-white — add:

```css
:root {
  --destructive-text: var(--destructive);
  --destructive-border: var(--destructive);
}
```

See [theming](theming.md) for why the two palettes differ.

## API Reference

### Form Container

| Attribute | Description |
|-----------|-------------|
| data-component="form" | Grid layout with gap |
| data-form-part="group" | Field group container (label, control, help text) |
| data-form-part="group" data-layout="inline" | Horizontal group for checkbox, radio and switch rows |
| data-form-part="description" | Help text styling |
| data-form-part="error" | Error message styling; colour from --destructive-text |
| data-form-part="actions" | Submit area container |
| data-form-part="actions" data-align="end" | Right-aligned actions |
| data-form-part="actions" data-align="between" | Actions spread to both ends |
| .field_with_errors | Rails error wrapper; renders as display: contents and marks every wrapped control invalid |

### Input

| Attribute | Values | Description |
|-----------|--------|-------------|
| data-component | input | Text input styling; type="file" gets a styled file button |
| data-size | sm, lg | Size variant |
| aria-invalid | true | Error state; :user-invalid also applies |

### Textarea

| Attribute | Values | Description |
|-----------|--------|-------------|
| data-component | textarea | Textarea styling |
| aria-invalid | true | Error state; :user-invalid also applies |

### Select

| Attribute | Values | Description |
|-----------|--------|-------------|
| data-component | select | Native select styling with chevron |
| data-mark | dark, light | Chevron ink override |
| aria-invalid | true | Error state; :user-invalid also applies |

### Checkbox

| Attribute | Values | Description |
|-----------|--------|-------------|
| data-component | checkbox | Checkbox styling; checked and indeterminate states |
| data-mark | dark | Dark check ink for a light --primary |
| aria-invalid | true | Error state; :user-invalid also applies |

### Radio

| Attribute | Values | Description |
|-----------|--------|-------------|
| data-component | radio | Radio button styling |
| data-mark | dark | Dark dot ink for a light --primary |
| aria-invalid | true | Error state; :user-invalid also applies |

### Switch

| Attribute | Values | Description |
|-----------|--------|-------------|
| data-component | switch | Toggle switch styling for a checkbox |
| data-mark | dark | Dark thumb ink for a light --primary |
| aria-invalid | true | Error state; :user-invalid also applies |

### Label

| Attribute | Values | Description |
|-----------|--------|-------------|
| data-component | label | Label styling |
| data-required | (presence) | Shows required indicator |

A label directly before or after a disabled control is dimmed.

### Button

| Attribute | Values | Description |
|-----------|--------|-------------|
| data-component | button | Button styling; works on button, input and a |
| data-variant | default, primary, secondary, destructive, outline, ghost, link | Visual style; omitted or default is the same as primary |
| data-size | sm, lg, icon, icon-sm, icon-lg | Size variant; omitted is the default size |
| aria-disabled | true | Disabled styling for links; disabled works on buttons |

### Fieldset

| Attribute | Values | Description |
|-----------|--------|-------------|
| data-component | fieldset | Bordered, padded group |
| data-component | legend | Legend styling; a bare legend inside a fieldset gets it too |

### Input Group

| Attribute | Values | Description |
|-----------|--------|-------------|
| data-component | input-group | Wrapper for an input with prefix or suffix |
| data-input-group-part | prefix, suffix | Muted text or icon inside the input; padding adjusts automatically |
