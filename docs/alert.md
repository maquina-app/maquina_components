# Alert

> Displays a callout for important messages, warnings, or notifications.

---

## Quick Reference

### Parts

| Partial | Description |
|---------|-------------|
| `components/alert` | Main alert container |
| `components/alert/title` | Alert heading |
| `components/alert/description` | Alert body text |

### Parameters

#### `_alert.html.erb`

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `variant` | Symbol | `:default` | Visual style: `:default`, `:destructive`, `:success`, `:warning` |
| `icon` | Symbol | `nil` | Icon name for `icon_for` helper |
| `css_classes` | String | `""` | Additional CSS classes |
| `**html_options` | Hash | `{}` | HTML attributes (`id:`, `data:`, etc.) |

#### `alert/_title.html.erb`

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `text` | String | `nil` | Title text (or use block) |
| `css_classes` | String | `""` | Additional CSS classes |
| `**html_options` | Hash | `{}` | HTML attributes |

#### `alert/_description.html.erb`

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `text` | String | `nil` | Description text (or use block) |
| `css_classes` | String | `""` | Additional CSS classes |
| `**html_options` | Hash | `{}` | HTML attributes |

### Variants

| Variant | Description |
|---------|-------------|
| `:default` | General information, neutral callouts |
| `:destructive` | Errors, critical issues, destructive actions |
| `:success` | Success messages, confirmations |
| `:warning` | Warnings, caution notices |

### Data Attributes

**Component Identifiers**

| Attribute | Element | Description |
|-----------|---------|-------------|
| `data-component="alert"` | Container div | Main component identifier |
| `data-alert-part="title"` | Title div | Alert title section |
| `data-alert-part="description"` | Description div | Alert description section |

**Variants**

| Attribute | Description |
|-----------|-------------|
| `data-variant="default"` | Default (neutral) styling |
| `data-variant="destructive"` | Error/destructive styling |
| `data-variant="success"` | Success styling |
| `data-variant="warning"` | Warning styling |

**Icon State**

| Attribute | Description |
|-----------|-------------|
| `data-has-icon="true"` | Present when alert has an icon (adds grid layout) |

### Data Attributes

These data attributes are used for CSS styling:

**Component Identifiers**

| Attribute | Element | Description |
|-----------|---------|-------------|
| `data-component="alert"` | Container div | Main component identifier |
| `data-alert-part="title"` | Title div | Alert title section |
| `data-alert-part="description"` | Description div | Alert description section |

**Variants**

| Attribute | Description |
|-----------|-------------|
| `data-variant="default"` | Default (neutral) styling |
| `data-variant="destructive"` | Error/destructive styling |
| `data-variant="success"` | Success styling |
| `data-variant="warning"` | Warning styling |

**Icon State**

| Attribute | Description |
|-----------|-------------|
| `data-has-icon="true"` | Present when alert has an icon (adds grid layout) |

---

## Basic Usage

```erb
<%%= render "components/alert" do %>
  <%%= render "components/alert/title", text: "Heads up!" %>
  <%%= render "components/alert/description", text: "You can add components using the CLI." %>
<%% end %>
```

### With Icon

```erb
<%%= render "components/alert", icon: :info do %>
  <%%= render "components/alert/title", text: "Heads up!" %>
  <%%= render "components/alert/description", text: "You can add components using the CLI." %>
<%% end %>
```

### With Variant

```erb
<%%= render "components/alert", variant: :destructive, icon: :circle_alert do %>
  <%%= render "components/alert/title", text: "Error" %>
  <%%= render "components/alert/description", text: "Your session has expired. Please log in again." %>
<%% end %>
```

---

## Examples

### All Variants

```erb
<%%= render "components/alert", variant: :default, icon: :info do %>
  <%%= render "components/alert/title", text: "Information" %>
  <%%= render "components/alert/description", text: "This is a default informational alert." %>
<%% end %>

<%%= render "components/alert", variant: :success, icon: :check do %>
  <%%= render "components/alert/title", text: "Success" %>
  <%%= render "components/alert/description", text: "Your changes have been saved successfully." %>
<%% end %>

<%%= render "components/alert", variant: :warning, icon: :triangle_alert do %>
  <%%= render "components/alert/title", text: "Warning" %>
  <%%= render "components/alert/description", text: "Your subscription is expiring soon." %>
<%% end %>

<%%= render "components/alert", variant: :destructive, icon: :circle_alert do %>
  <%%= render "components/alert/title", text: "Error" %>
  <%%= render "components/alert/description", text: "Unable to process your request." %>
<%% end %>
```

### Title Only (No Description)

```erb
<%%= render "components/alert", icon: :terminal do %>
  <%%= render "components/alert/title", text: "This alert has a title and icon only." %>
<%% end %>
```

### With Rich Content

```erb
<%%= render "components/alert", variant: :destructive, icon: :circle_alert do %>
  <%%= render "components/alert/title", text: "Unable to process your payment." %>
  <%%= render "components/alert/description" do %>
    <p>Please verify your billing information and try again.</p>
    <ul>
      <li>Check your card details</li>
      <li>Ensure sufficient funds</li>
      <li>Verify billing address</li>
    </ul>
  <%% end %>
<%% end %>
```

### Without Icon

```erb
<%%= render "components/alert" do %>
  <%%= render "components/alert/title", text: "Note" %>
  <%%= render "components/alert/description", text: "This alert has no icon." %>
<%% end %>
```

### With Custom HTML Attributes

```erb
<%%= render "components/alert", variant: :success, icon: :check, id: "save-confirmation", data: { controller: "alert", alert_dismissible: true } do %>
  <%%= render "components/alert/title", text: "Saved!" %>
  <%%= render "components/alert/description", text: "Your document has been saved." %>
<%% end %>
```

---

## Real-World Patterns

### Flash Messages

Use alerts to display Rails flash messages:

```erb
<%% if flash[:notice] %>
  <%%= render "components/alert", variant: :success, icon: :check do %>
    <%%= render "components/alert/title", text: "Success" %>
    <%%= render "components/alert/description", text: flash[:notice] %>
  <%% end %>
<%% end %>

<%% if flash[:alert] %>
  <%%= render "components/alert", variant: :destructive, icon: :circle_alert do %>
    <%%= render "components/alert/title", text: "Error" %>
    <%%= render "components/alert/description", text: flash[:alert] %>
  <%% end %>
<%% end %>
```

### Form Validation Errors

```erb
<%% if @user.errors.any? %>
  <%%= render "components/alert", variant: :destructive, icon: :circle_alert do %>
    <%%= render "components/alert/title", text: "Please fix the following errors:" %>
    <%%= render "components/alert/description" do %>
      <ul>
        <%% @user.errors.full_messages.each do |message| %>
          <li><%%= message %></li>
        <%% end %>
      </ul>
    <%% end %>
  <%% end %>
<%% end %>
```

### Feature Announcement

```erb
<%%= render "components/alert", icon: :sparkles do %>
  <%%= render "components/alert/title", text: "New Feature Available!" %>
  <%%= render "components/alert/description" do %>
    We've added dark mode support. 
    <%%= link_to "Learn more", settings_path, class: "underline font-medium" %>.
  <%% end %>
<%% end %>
```

### Dismissible Alert (with Stimulus)

```erb
<div data-controller="dismissible">
  <%%= render "components/alert", variant: :success, icon: :check, data: { dismissible_target: "alert" } do %>
    <%%= render "components/alert/title", text: "Success" %>
    <%%= render "components/alert/description" do %>
      Your changes have been saved.
      <button type="button" data-action="click->dismissible#dismiss" class="absolute top-4 right-4">
        <%%= icon_for :x, class: "size-4" %>
      </button>
    <%% end %>
  <%% end %>
</div>
```

---

## Theme Variables

The alert component uses these CSS variables from your theme:

```css
/* Default variant */
var(--background)
var(--foreground)
var(--border)
var(--muted-foreground)

/* Destructive variant */
var(--destructive)
var(--destructive-foreground)

/* Success variant */
var(--success)
var(--success-foreground)

/* Warning variant */
var(--warning)
var(--warning-foreground)
```

### Adding Success & Warning Colors

If your theme doesn't have success/warning colors, add to your CSS:

```css
:root {
  --success: oklch(0.95 0.05 145);
  --success-foreground: oklch(0.35 0.12 145);
  --warning: oklch(0.95 0.08 85);
  --warning-foreground: oklch(0.35 0.10 65);
}

.dark {
  --success: oklch(0.25 0.08 145);
  --success-foreground: oklch(0.85 0.08 145);
  --warning: oklch(0.30 0.08 85);
  --warning-foreground: oklch(0.90 0.08 85);
}
```

---

## Customization

### Adding a Custom Variant

1. Add CSS variables to your theme:

```css
:root {
  --info: oklch(0.95 0.05 240);
  --info-foreground: oklch(0.35 0.12 240);
}
```

2. Add the variant styles to `alert.css`:

```css
[data-component="alert"][data-variant="info"] {
  background-color: var(--info);
  color: var(--info-foreground);
  border-color: var(--info);
}

[data-component="alert"][data-variant="info"] [data-alert-part="title"],
[data-component="alert"][data-variant="info"] [data-alert-part="description"] {
  color: var(--info-foreground);
}

[data-component="alert"][data-variant="info"] > svg:first-child {
  color: var(--info-foreground);
}
```

3. Use it:

```erb
<%%= render "components/alert", variant: :info, icon: :info do %>
  <%%= render "components/alert/title", text: "Did you know?" %>
  <%%= render "components/alert/description", text: "You can customize alert variants." %>
<%% end %>
```

---

## Accessibility

- Uses `role="alert"` for screen reader announcements
- Icon is decorative (not announced separately)
- Color is not the only indicator — title and description provide context
- Sufficient color contrast in both light and dark modes

For dynamically inserted alerts (like flash messages), consider using `aria-live="polite"`:

```erb
<div aria-live="polite">
  <%%= render "components/alert", variant: :success, icon: :check do %>
    <%%= render "components/alert/title", text: "Saved!" %>
  <%% end %>
</div>
```

---

## File Structure

```
app/views/components/
├── _alert.html.erb
└── alert/
    ├── _title.html.erb
    └── _description.html.erb

app/assets/stylesheets/alert.css
docs/alert.md
```
