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

  <%%= f.submit "Sign in", data: { component: "button", variant: "primary" } %>
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
<label class="flex items-center gap-2">
  <%%= f.check_box :terms, data: { component: "checkbox" } %>
  <span class="text-sm">Accept terms</span>
</label>
```

### Radio

<!-- preview:radio height:180 -->

```erb
<label class="flex items-center gap-2">
  <%%= f.radio_button :plan, "pro", data: { component: "radio" } %>
  <span class="text-sm">Pro</span>
</label>
```

### Switch

<!-- preview:switch height:160 -->

```erb
<label class="flex items-center gap-3">
  <%%= f.check_box :notifications, data: { component: "switch" } %>
  <span class="text-sm">Enable notifications</span>
</label>
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
```

## API Reference

### Form Container

| Attribute | Description |
|-----------|-------------|
| data-component="form" | Grid layout with gap |
| data-form-part="group" | Field group container |
| data-form-part="description" | Help text styling |
| data-form-part="error" | Error message styling |
| data-form-part="actions" | Submit area container |

### Input

| Attribute | Values | Description |
|-----------|--------|-------------|
| data-component | input | Text input styling |
| data-size | sm, lg | Size variant |

### Textarea

| Attribute | Values | Description |
|-----------|--------|-------------|
| data-component | textarea | Textarea styling |

### Select

| Attribute | Values | Description |
|-----------|--------|-------------|
| data-component | select | Native select styling |

### Checkbox

| Attribute | Values | Description |
|-----------|--------|-------------|
| data-component | checkbox | Checkbox styling |

### Radio

| Attribute | Values | Description |
|-----------|--------|-------------|
| data-component | radio | Radio button styling |

### Switch

| Attribute | Values | Description |
|-----------|--------|-------------|
| data-component | switch | Toggle switch styling |

### Label

| Attribute | Values | Description |
|-----------|--------|-------------|
| data-component | label | Label styling |
| data-required | (presence) | Shows required indicator |

### Button

| Attribute | Values | Description |
|-----------|--------|-------------|
| data-component | button | Button styling |
| data-variant | primary, secondary, destructive, outline, ghost, link | Visual style |
| data-size | sm, lg, icon, icon-sm, icon-lg | Size variant |
