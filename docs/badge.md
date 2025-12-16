# Badge

> Displays a small label for status indicators, tags, counts, and categories.

---

## Quick Reference

### Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `variant` | Symbol | `:default` | Visual style: `:default`, `:primary`, `:secondary`, `:destructive`, `:success`, `:warning`, `:outline` |
| `size` | Symbol | `:md` | Size: `:sm`, `:md`, `:lg` |
| `css_classes` | String | `""` | Additional CSS classes |
| `**html_options` | Hash | `{}` | HTML attributes passed to the `<span>` (e.g., `id:`, `data:`, `title:`) |

### Variants

| Variant | Description |
|---------|-------------|
| `:default` | Neutral/muted status |
| `:primary` | Brand emphasis |
| `:secondary` | Subtle emphasis |
| `:destructive` | Errors, deletions, critical |
| `:success` | Positive status, completed |
| `:warning` | Caution, pending |
| `:outline` | Minimal, bordered style |

### Sizes

| Size | Description |
|------|-------------|
| `:sm` | Compact (h-5, text-xs) — inline with text, compact lists |
| `:md` | Default (h-6, text-sm) — balanced |
| `:lg` | Prominent (h-7, text-sm) — standalone |

### Data Attributes

**Component Identifier**

| Attribute | Element | Description |
|-----------|---------|-------------|
| `data-component="badge"` | `<span>` | Main component identifier |

**Variants**

| Attribute | Description |
|-----------|-------------|
| `data-variant="default"` | Muted/neutral styling |
| `data-variant="primary"` | Brand color styling |
| `data-variant="secondary"` | Subtle emphasis styling |
| `data-variant="destructive"` | Error/critical styling |
| `data-variant="success"` | Positive/success styling |
| `data-variant="warning"` | Caution/warning styling |
| `data-variant="outline"` | Transparent with border |

**Sizes**

| Attribute | Description |
|-----------|-------------|
| `data-size="sm"` | Small badge |
| `data-size="md"` | Medium badge |
| `data-size="lg"` | Large badge |

---

## Basic Usage

```erb
<%%= render "components/badge" do %>
  Badge
<%% end %>
```

### With Variant

```erb
<%%= render "components/badge", variant: :success do %>
  Active
<%% end %>

<%%= render "components/badge", variant: :destructive do %>
  Expired
<%% end %>

<%%= render "components/badge", variant: :warning do %>
  Pending
<%% end %>
```

### With Size

```erb
<%%= render "components/badge", size: :sm do %>
  Small
<%% end %>

<%%= render "components/badge", size: :lg do %>
  Large
<%% end %>
```

---

## Examples

### All Variants

```erb
<div class="flex flex-wrap gap-2">
  <%%= render "components/badge", variant: :default do %>Default<%% end %>
  <%%= render "components/badge", variant: :primary do %>Primary<%% end %>
  <%%= render "components/badge", variant: :secondary do %>Secondary<%% end %>
  <%%= render "components/badge", variant: :destructive do %>Destructive<%% end %>
  <%%= render "components/badge", variant: :success do %>Success<%% end %>
  <%%= render "components/badge", variant: :warning do %>Warning<%% end %>
  <%%= render "components/badge", variant: :outline do %>Outline<%% end %>
</div>
```

### With Icons

Icons scale automatically with the badge text. Use the `icon_for` helper:

```erb
<%%= render "components/badge", variant: :success do %>
  <%%= icon_for :check %>
  Verified
<%% end %>

<%%= render "components/badge", variant: :warning do %>
  <%%= icon_for :alert_triangle %>
  Attention
<%% end %>

<%%= render "components/badge", variant: :destructive do %>
  <%%= icon_for :x %>
  Rejected
<%% end %>
```

### Notification Count

```erb
<%%= render "components/badge", variant: :destructive, size: :sm, css_classes: "rounded-full min-w-5 justify-center font-mono tabular-nums" do %>
  99+
<%% end %>
```

### With Custom HTML Attributes

```erb
<%%= render "components/badge", variant: :outline, id: "status-badge", title: "Current status", data: { controller: "tooltip" } do %>
  Draft
<%% end %>
```

---

## Real-World Patterns

### Status in a Table Row

```erb
<td class="px-4 py-2">
  <%%= render "components/badge", variant: status_variant(@order.status), size: :sm do %>
    <%%= @order.status.humanize %>
  <%% end %>
</td>
```

With a helper method:

```ruby
def status_variant(status)
  case status.to_sym
  when :completed then :success
  when :pending then :warning
  when :cancelled then :destructive
  else :default
  end
end
```

### Tags List

```erb
<div class="flex flex-wrap gap-1">
  <%% @article.tags.each do |tag| %>
    <%%= render "components/badge", variant: :secondary, size: :sm do %>
      <%%= tag.name %>
    <%% end %>
  <%% end %>
</div>
```

### Badge as Link

Wrap the badge in a link or use `link_to` with badge styling:

```erb
<%%= link_to tagged_articles_path(tag), class: "no-underline" do %>
  <%%= render "components/badge", variant: :outline do %>
    <%%= tag.name %>
  <%% end %>
<%% end %>
```

### User Role Badge

```erb
<div class="flex items-center gap-2">
  <%%= image_tag @user.avatar_url, class: "w-8 h-8 rounded-full" %>
  <span class="font-medium"><%%= @user.name %></span>
  <%%= render "components/badge", variant: :primary, size: :sm do %>
    <%%= @user.role.humanize %>
  <%% end %>
</div>
```

---

## Theme Variables

The badge component uses these CSS variables from your theme:

```css
/* default variant */
var(--muted)
var(--muted-foreground)

/* primary variant */
var(--primary)
var(--primary-foreground)

/* secondary variant */
var(--secondary)
var(--secondary-foreground)

/* destructive variant */
var(--destructive)
var(--destructive-foreground)

/* success variant */
var(--success)
var(--success-foreground)

/* warning variant */
var(--warning)
var(--warning-foreground)

/* outline variant */
var(--foreground)
var(--border)
var(--accent)
var(--accent-foreground)
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

@theme inline {
  --color-success: var(--success);
  --color-success-foreground: var(--success-foreground);
  --color-warning: var(--warning);
  --color-warning-foreground: var(--warning-foreground);
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

2. Add the variant styles to `badge.css`:

```css
[data-component="badge"][data-variant="info"] {
  background-color: var(--info);
  color: var(--info-foreground);
  border-color: transparent;
}

[data-component="badge"][data-variant="info"]:hover {
  opacity: 0.9;
}
```

3. Use it:

```erb
<%%= render "components/badge", variant: :info do %>
  Information
<%% end %>
```

---

## Accessibility

- Uses semantic `<span>` element (non-interactive by default)
- When used inside links/buttons, focus states are styled
- Color is not the only indicator — text provides context
- Sufficient color contrast in both light and dark modes

For screen readers, ensure context is provided:

```erb
<span class="sr-only">Status:</span>
<%%= render "components/badge", variant: :success do %>
  Active
<%% end %>
```

---

## File Structure

```
app/views/components/
└── _badge.html.erb

app/assets/stylesheets/badge.css
docs/badge.md
```
