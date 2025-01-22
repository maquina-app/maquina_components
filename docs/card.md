# Card

> Displays grouped content with optional header, body, and footer sections.

---

## Quick Reference

### Parts

| Partial | Description |
|---------|-------------|
| `components/card` | Main card container |
| `components/card/header` | Header section (contains title, description, action) |
| `components/card/title` | Card title text |
| `components/card/description` | Subtitle/description text |
| `components/card/action` | Action buttons in header |
| `components/card/content` | Main body content |
| `components/card/footer` | Footer with actions |

### Parameters

#### Common Parameters (All Partials)

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `css_classes` | String | `""` | Additional CSS classes |
| `**html_options` | Hash | `{}` | HTML attributes (`id:`, `data:`, etc.) |

#### `card/header`

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `layout` | Symbol | `:column` | Layout: `:column`, `:row` |

#### `card/title`

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `text` | String | `nil` | Title text (or use block) |
| `size` | Symbol | `:default` | Size: `:default`, `:sm` |

#### `card/description`

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `text` | String | `nil` | Description text (or use block) |

#### `card/content`

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `spacing` | Symbol | `:default` | Spacing: `:default`, `:full` |

#### `card/footer`

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `align` | Symbol | `:start` | Alignment: `:start`, `:center`, `:end`, `:between` |
| `spacing` | Symbol | `:default` | Spacing: `:default`, `:full` |

### Data Attributes

**Component Identifiers**

| Attribute | Element | Description |
|-----------|---------|-------------|
| `data-component="card"` | Container div | Main component identifier |
| `data-card-part="header"` | Header div | Card header section |
| `data-card-part="title"` | Title div | Card title element |
| `data-card-part="description"` | Description div | Card description element |
| `data-card-part="action"` | Action div | Header action slot |
| `data-card-part="content"` | Content div | Main body content |
| `data-card-part="footer"` | Footer div | Card footer section |

**Header Layout**

| Attribute | Description |
|-----------|-------------|
| `data-layout="row"` | Row layout (title + action side by side) |

**Title Size**

| Attribute | Description |
|-----------|-------------|
| `data-size="sm"` | Small title text |

**Content/Footer Spacing**

| Attribute | Description |
|-----------|-------------|
| `data-spacing="full"` | Full padding (when no header precedes content) |

**Footer Alignment**

| Attribute | Description |
|-----------|-------------|
| `data-align="between"` | Space-between alignment |
| `data-align="end"` | End/right alignment |
| `data-align="center"` | Center alignment |

---

## Basic Usage

```erb
<%%= render "components/card" do %>
  <%%= render "components/card/header" do %>
    <%%= render "components/card/title", text: "Card Title" %>
    <%%= render "components/card/description", text: "Card description goes here." %>
  <%% end %>
  
  <%%= render "components/card/content" do %>
    <p>Card content goes here.</p>
  <%% end %>
  
  <%%= render "components/card/footer" do %>
    <%%= render "components/button", variant: :primary do %>Save<%% end %>
  <%% end %>
<%% end %>
```

---

## Examples

### Simple Card

```erb
<%%= render "components/card" do %>
  <%%= render "components/card/content", spacing: :full do %>
    <p>A simple card with just content.</p>
  <%% end %>
<%% end %>
```

### Card with Header and Content

```erb
<%%= render "components/card" do %>
  <%%= render "components/card/header" do %>
    <%%= render "components/card/title", text: "Notifications" %>
    <%%= render "components/card/description", text: "You have 3 unread messages." %>
  <%% end %>
  
  <%%= render "components/card/content" do %>
    <ul class="space-y-2">
      <li>Your call has been confirmed.</li>
      <li>You have a new message!</li>
      <li>Your subscription is expiring soon.</li>
    </ul>
  <%% end %>
<%% end %>
```

### Card with Header Action

Use `layout: :row` on the header and add an action slot:

```erb
<%%= render "components/card" do %>
  <%%= render "components/card/header", layout: :row do %>
    <div>
      <%%= render "components/card/title", text: "Total Revenue", size: :sm %>
      <%%= render "components/card/description", text: "$45,231.89" %>
    </div>
    <%%= render "components/card/action" do %>
      <%%= icon_for :dollar_sign %>
    <%% end %>
  <%% end %>
  
  <%%= render "components/card/content" do %>
    <p class="text-xs text-muted-foreground">+20.1% from last month</p>
  <%% end %>
<%% end %>
```

### Card with Footer Alignment

```erb
<%%= render "components/card" do %>
  <%%= render "components/card/header" do %>
    <%%= render "components/card/title", text: "Create Project" %>
    <%%= render "components/card/description", text: "Deploy your new project in one click." %>
  <%% end %>
  
  <%%= render "components/card/content" do %>
    <%%= render "components/input", name: "project_name", placeholder: "Project name" %>
  <%% end %>
  
  <%%= render "components/card/footer", align: :between do %>
    <%%= render "components/button", variant: :outline do %>Cancel<%% end %>
    <%%= render "components/button", variant: :primary do %>Deploy<%% end %>
  <%% end %>
<%% end %>
```

### Card with Custom HTML Attributes

```erb
<%%= render "components/card", id: "user-card", data: { controller: "card" } do %>
  <%%= render "components/card/content", spacing: :full do %>
    <p>Card with custom attributes.</p>
  <%% end %>
<%% end %>
```

---

## Real-World Patterns

### Stats Card Grid

```erb
<div class="grid gap-4 md:grid-cols-2 lg:grid-cols-4">
  <%% @stats.each do |stat| %>
    <%%= render "components/card" do %>
      <%%= render "components/card/header", layout: :row do %>
        <div>
          <%%= render "components/card/title", text: stat.label, size: :sm %>
        </div>
        <%%= render "components/card/action" do %>
          <%%= icon_for stat.icon %>
        <%% end %>
      <%% end %>
      
      <%%= render "components/card/content" do %>
        <div class="text-2xl font-bold"><%%= stat.value %></div>
        <p class="text-xs text-muted-foreground"><%%= stat.change %></p>
      <%% end %>
    <%% end %>
  <%% end %>
</div>
```

### Login Form Card

```erb
<%%= render "components/card", css_classes: "w-full max-w-sm mx-auto" do %>
  <%%= render "components/card/header" do %>
    <%%= render "components/card/title", text: "Login to your account" %>
    <%%= render "components/card/description", text: "Enter your email below to login." %>
  <%% end %>
  
  <%%= form_with url: sessions_path, class: "contents" do |f| %>
    <%%= render "components/card/content" do %>
      <div class="grid gap-4">
        <div class="grid gap-2">
          <%%= render "components/label", for: "email" do %>Email<%% end %>
          <%%= render "components/input", type: :email, name: "email", id: "email", placeholder: "m@example.com" %>
        </div>
        <div class="grid gap-2">
          <%%= render "components/label", for: "password" do %>Password<%% end %>
          <%%= render "components/input", type: :password, name: "password", id: "password" %>
        </div>
      </div>
    <%% end %>
    
    <%%= render "components/card/footer" do %>
      <%%= render "components/button", variant: :primary, css_classes: "w-full" do %>Login<%% end %>
    <%% end %>
  <%% end %>
<%% end %>
```

### Product Card

```erb
<%%= render "components/card" do %>
  <img src="<%%= @product.image_url %>" alt="<%%= @product.name %>" class="rounded-t-xl object-cover h-48 w-full" />
  
  <%%= render "components/card/header" do %>
    <%%= render "components/card/title", text: @product.name %>
    <%%= render "components/card/description", text: @product.category %>
  <%% end %>
  
  <%%= render "components/card/content" do %>
    <p class="text-2xl font-bold"><%%= number_to_currency(@product.price) %></p>
  <%% end %>
  
  <%%= render "components/card/footer" do %>
    <%%= render "components/button", variant: :primary, css_classes: "w-full" do %>
      <%%= icon_for :shopping_cart %>
      Add to Cart
    <%% end %>
  <%% end %>
<%% end %>
```

---

## Theme Variables

The card component uses these CSS variables from your theme:

```css
var(--border)           /* Card border color */
var(--card)             /* Card background color */
var(--card-foreground)  /* Card text color */
var(--muted-foreground) /* Description text color */
var(--background)       /* Focus ring offset */
var(--accent)           /* Hover border color (interactive cards) */
```

---

## Customization

### Card Without Shadow

```erb
<%%= render "components/card", css_classes: "shadow-none" do %>
  <%%= render "components/card/content", spacing: :full do %>
    <p>Flat card without shadow.</p>
  <%% end %>
<%% end %>
```

### Interactive Card (Link)

Wrap the card in a link:

```erb
<%%= link_to product_path(@product), class: "block no-underline" do %>
  <%%= render "components/card" do %>
    <%%= render "components/card/content", spacing: :full do %>
      <p>Click me!</p>
    <%% end %>
  <%% end %>
<%% end %>
```

Or use the card as the link element (requires CSS for `a[data-component="card"]`):

```erb
<%%= link_to product_path(@product), data: { component: :card }, class: "block" do %>
  <div data-card-part="content" data-spacing="full">
    <p>Clickable card</p>
  </div>
<%% end %>
```

---

## Accessibility

- Card uses semantic `<div>` elements
- Title uses appropriate heading semantics via CSS (visually styled, use proper headings in content if needed)
- When card is interactive (link/button), focus states are provided
- Color contrast meets WCAG AA in both light and dark modes

For better semantics, consider wrapping card content in `<article>` when appropriate:

```erb
<article>
  <%%= render "components/card" do %>
    <%%= render "components/card/header" do %>
      <%%= render "components/card/title" do %><h2>Article Title</h2><%% end %>
    <%% end %>
    <%%= render "components/card/content" do %>
      <p>Article content...</p>
    <%% end %>
  <%% end %>
</article>
```

---

## File Structure

```
app/views/components/
├── _card.html.erb
└── card/
    ├── _header.html.erb
    ├── _title.html.erb
    ├── _description.html.erb
    ├── _action.html.erb
    ├── _content.html.erb
    └── _footer.html.erb

app/assets/stylesheets/card.css
docs/card.md
```
