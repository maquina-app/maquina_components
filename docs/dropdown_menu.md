# Dropdown Menu

> Displays a menu of actions or options triggered by a button.

---

## Quick Reference

### Parts

| Partial | Description |
|---------|-------------|
| `components/dropdown_menu` | Root container with Stimulus controller |
| `components/dropdown_menu/trigger` | Button that opens the menu |
| `components/dropdown_menu/content` | Positioned menu container |
| `components/dropdown_menu/item` | Clickable menu action |
| `components/dropdown_menu/label` | Section heading |
| `components/dropdown_menu/separator` | Visual divider |
| `components/dropdown_menu/group` | Logical grouping |
| `components/dropdown_menu/shortcut` | Keyboard shortcut hint |

### Helper Methods

| Method | Description |
|--------|-------------|
| `dropdown_menu` | Builder pattern for full control |
| `dropdown_menu_simple` | Data-driven simple menus |

### Parameters

#### `dropdown_menu/content`

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `align` | Symbol | `:start` | Horizontal alignment: `:start`, `:center`, `:end` |
| `side` | Symbol | `:bottom` | Which side to open: `:top`, `:bottom`, `:left`, `:right` |
| `width` | Symbol | `:default` | Width preset: `:default`, `:sm`, `:md`, `:lg` |

#### `dropdown_menu/item`

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `href` | String | `nil` | URL (renders `<a>`), nil renders `<button>` |
| `method` | Symbol | `nil` | HTTP method: `:delete`, `:post`, etc. |
| `variant` | Symbol | `:default` | Visual variant: `:default`, `:destructive` |
| `disabled` | Boolean | `false` | Whether the item is disabled |

#### `dropdown_menu/trigger`

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `variant` | Symbol | `:outline` | Button variant (when `as_child: false`) |
| `size` | Symbol | `:default` | Button size (when `as_child: false`) |
| `as_child` | Boolean | `false` | Use custom trigger markup |

### Data Attributes

**Component Identifiers**

| Attribute | Element | Description |
|-----------|---------|-------------|
| `data-controller="dropdown-menu"` | Root container | Stimulus controller |
| `data-dropdown-menu-part="trigger"` | Button | Trigger element |
| `data-dropdown-menu-part="content"` | Menu container | Positioned dropdown content |
| `data-dropdown-menu-part="item"` | Menu item | Action item |
| `data-dropdown-menu-part="label"` | Label | Section heading |
| `data-dropdown-menu-part="separator"` | Divider | Visual separator |
| `data-dropdown-menu-part="group"` | Group wrapper | Logical grouping |
| `data-dropdown-menu-part="shortcut"` | Shortcut text | Keyboard hint |

**State Attributes**

| Attribute | Description |
|-----------|-------------|
| `data-state="open"` | Menu is visible |
| `data-state="closed"` | Menu is hidden |
| `data-variant="destructive"` | Destructive item styling |
| `aria-disabled="true"` | Disabled item |

**Stimulus Targets**

| Attribute | Description |
|-----------|-------------|
| `data-dropdown-menu-target="trigger"` | Trigger button target |
| `data-dropdown-menu-target="content"` | Content container target |

---

## Basic Usage

### Using the Helper (Recommended)

```erb
<%%= dropdown_menu do |menu| %>
  <%% menu.trigger { "Options" } %>
  <%% menu.content do %>
    <%% menu.item "Profile", href: profile_path %>
    <%% menu.item "Settings", href: settings_path %>
    <%% menu.separator %>
    <%% menu.item "Logout", href: logout_path, method: :delete %>
  <%% end %>
<%% end %>
```

### Using Partials

```erb
<%%= render "components/dropdown_menu" do %>
  <%%= render "components/dropdown_menu/trigger" do %>Options<%% end %>
  <%%= render "components/dropdown_menu/content" do %>
    <%%= render "components/dropdown_menu/item", href: profile_path do %>Profile<%% end %>
    <%%= render "components/dropdown_menu/item", href: settings_path do %>Settings<%% end %>
  <%% end %>
<%% end %>
```

---

## Examples

### Trigger Modes

The trigger partial has two modes controlled by the `as_child` parameter:

#### Default Mode (`as_child: false`)

When `as_child: false` (the default), the trigger creates its own button element with a chevron icon. Your block content becomes the button label.

```erb
<%%= render "components/dropdown_menu/trigger" do %>
  Actions
<%% end %>
```

This renders:
```html
<button type="button" data-component="button" data-variant="outline" ...>
  Actions
  <svg><!-- chevron icon --></svg>
</button>
```

#### Child Mode (`as_child: true`)

When `as_child: true`, the trigger does NOT create a button — it simply yields your content. You must provide your own complete button element with all required data attributes.

```erb
<%%= render "components/dropdown_menu/trigger", as_child: true do %>
  <button type="button"
          data-component="button"
          data-variant="ghost"
          data-size="icon-sm"
          data-dropdown-menu-target="trigger"
          data-action="dropdown-menu#toggle"
          aria-haspopup="menu"
          aria-expanded="false">
    <%%= icon_for :more_horizontal, class: "size-4" %>
  </button>
<%% end %>
```

**Required data attributes when using `as_child: true`:**

| Attribute | Value | Purpose |
|-----------|-------|---------|
| `data-dropdown-menu-target` | `"trigger"` | Stimulus target binding |
| `data-action` | `"dropdown-menu#toggle"` | Click handler |
| `aria-haspopup` | `"menu"` | Accessibility |
| `aria-expanded` | `"false"` | Accessibility (updated by JS) |

### Simple Data-Driven Menu

```erb
<%%= dropdown_menu_simple "Actions", items: [
  { label: "Edit", href: edit_path, icon: :pencil },
  { separator: true },
  { label: "Delete", href: delete_path, method: :delete, destructive: true }
] %>
```

### With Icons and Shortcuts

```erb
<%%= dropdown_menu do |menu| %>
  <%% menu.trigger { "My Account" } %>
  <%% menu.content width: :md do %>
    <%% menu.label "Settings" %>
    <%% menu.item "Profile", href: profile_path, icon: :user do |item| %>
      <%% item.shortcut "⇧⌘P" %>
    <%% end %>
    <%% menu.item "Billing", href: billing_path, icon: :credit_card do |item| %>
      <%% item.shortcut "⌘B" %>
    <%% end %>
    <%% menu.separator %>
    <%% menu.item "Logout", href: logout_path, method: :delete, icon: :log_out, variant: :destructive %>
  <%% end %>
<%% end %>
```

### Icon-Only Button Trigger

Use `as_child: true` for icon-only triggers without the chevron:

```erb
<%%= render "components/dropdown_menu" do %>
  <%%= render "components/dropdown_menu/trigger", as_child: true do %>
    <button type="button"
            data-component="button"
            data-variant="ghost"
            data-size="icon"
            data-dropdown-menu-target="trigger"
            data-action="dropdown-menu#toggle"
            aria-haspopup="menu"
            aria-expanded="false">
      <%%= icon_for :more_horizontal, class: "size-4" %>
    </button>
  <%% end %>
  <%%= render "components/dropdown_menu/content", align: :end do %>
    <%%= render "components/dropdown_menu/item", href: "#" do %>Edit<%% end %>
    <%%= render "components/dropdown_menu/item", href: "#", variant: :destructive do %>Delete<%% end %>
  <%% end %>
<%% end %>
```

### Grouped Items

```erb
<%%= dropdown_menu do |menu| %>
  <%% menu.trigger { "File" } %>
  <%% menu.content do %>
    <%% menu.group do %>
      <%% menu.label "Documents" %>
      <%% menu.item "New", href: new_document_path %>
      <%% menu.item "Open", href: documents_path %>
    <%% end %>
    <%% menu.separator %>
    <%% menu.group do %>
      <%% menu.label "Export" %>
      <%% menu.item "PDF", href: export_pdf_path %>
      <%% menu.item "CSV", href: export_csv_path %>
    <%% end %>
  <%% end %>
<%% end %>
```

### Alignment Options

```erb
<%# Start aligned (default) %>
<%%= dropdown_menu do |menu| %>
  <%% menu.trigger { "Start" } %>
  <%% menu.content align: :start do %>
    <%% menu.item "Item 1", href: "#" %>
  <%% end %>
<%% end %>

<%# End aligned %>
<%%= dropdown_menu do |menu| %>
  <%% menu.trigger { "End" } %>
  <%% menu.content align: :end do %>
    <%% menu.item "Item 1", href: "#" %>
  <%% end %>
<%% end %>
```

---

## Real-World Patterns

### User Account Menu

```erb
<%%= dropdown_menu do |menu| %>
  <%% menu.trigger variant: :ghost do %>
    <div class="flex items-center gap-2">
      <%%= image_tag current_user.avatar, class: "size-6 rounded-full" %>
      <span class="hidden sm:inline"><%%= current_user.name %></span>
    </div>
  <%% end %>
  <%% menu.content align: :end, width: :md do %>
    <%% menu.label do %>
      <div class="flex flex-col">
        <span class="font-medium"><%%= current_user.name %></span>
        <span class="text-xs text-muted-foreground"><%%= current_user.email %></span>
      </div>
    <%% end %>
    <%% menu.separator %>
    <%% menu.item "Profile", href: profile_path, icon: :user %>
    <%% menu.item "Settings", href: settings_path, icon: :settings %>
    <%% menu.item "Billing", href: billing_path, icon: :credit_card %>
    <%% menu.separator %>
    <%% menu.item "Logout", href: logout_path, method: :delete, icon: :log_out %>
  <%% end %>
<%% end %>
```

### In a Table Row

```erb
<table data-component="table">
  <tbody>
    <%% @users.each do |user| %>
      <tr>
        <td><%%= user.name %></td>
        <td><%%= user.email %></td>
        <td class="text-right">
          <%%= render "components/dropdown_menu" do %>
            <%%= render "components/dropdown_menu/trigger", as_child: true do %>
              <button type="button"
                      data-component="button"
                      data-variant="ghost"
                      data-size="icon-sm"
                      data-dropdown-menu-target="trigger"
                      data-action="dropdown-menu#toggle"
                      aria-haspopup="menu"
                      aria-expanded="false">
                <%%= icon_for :more_horizontal, class: "size-4" %>
              </button>
            <%% end %>
            <%%= render "components/dropdown_menu/content", align: :end do %>
              <%%= render "components/dropdown_menu/item", href: edit_user_path(user) do %>
                <%%= icon_for :pencil, class: "size-4" %>
                Edit
              <%% end %>
              <%%= render "components/dropdown_menu/separator" %>
              <%%= render "components/dropdown_menu/item", href: user_path(user), method: :delete, variant: :destructive do %>
                <%%= icon_for :trash, class: "size-4" %>
                Delete
              <%% end %>
            <%% end %>
          <%% end %>
        </td>
      </tr>
    <%% end %>
  </tbody>
</table>
```

### Bulk Actions Menu

```erb
<%%= dropdown_menu do |menu| %>
  <%% menu.trigger { "Bulk Actions" } %>
  <%% menu.content do %>
    <%% menu.item "Export Selected", href: export_path, icon: :download %>
    <%% menu.item "Archive Selected", href: archive_path, method: :post, icon: :archive %>
    <%% menu.separator %>
    <%% menu.item "Delete Selected", href: bulk_delete_path, method: :delete, icon: :trash, variant: :destructive %>
  <%% end %>
<%% end %>
```

---

## Theme Variables

This component uses these CSS variables:

```css
/* Content container */
var(--popover)
var(--popover-foreground)
var(--border)

/* Items */
var(--accent)
var(--accent-foreground)
var(--destructive)
var(--destructive-foreground)
var(--muted-foreground)

/* Separator */
var(--muted)
```

---

## Customization

### Adding a New Width

Add to `app/assets/stylesheets/dropdown_menu.css`:

```css
[data-dropdown-menu-part="content"][data-width="xl"] {
  @apply w-96;
}
```

### Custom Animation

Override the animation keyframes:

```css
@keyframes dropdown-menu-in {
  from {
    opacity: 0;
    transform: translateY(-8px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}
```

---

## Keyboard Navigation

| Key | Action |
|-----|--------|
| `Enter` / `Space` | Open menu (on trigger) |
| `Escape` | Close menu |
| `↓` | Focus next item |
| `↑` | Focus previous item |
| `Home` | Focus first item |
| `End` | Focus last item |
| `Tab` | Close menu and move focus |

---

## Accessibility

- Trigger has `aria-haspopup="menu"` and `aria-expanded`
- Content has `role="menu"` and `aria-orientation="vertical"`
- Items have `role="menuitem"` and `tabindex="-1"`
- Disabled items have `aria-disabled="true"`
- Focus is trapped within menu when open
- Focus returns to trigger when closed

---

## File Structure

```
app/views/components/
├── _dropdown_menu.html.erb
└── dropdown_menu/
    ├── _trigger.html.erb
    ├── _content.html.erb
    ├── _item.html.erb
    ├── _label.html.erb
    ├── _separator.html.erb
    ├── _group.html.erb
    └── _shortcut.html.erb

app/assets/stylesheets/dropdown_menu.css
app/javascript/controllers/dropdown_menu_controller.js
app/helpers/maquina_components/dropdown_menu_helper.rb
docs/dropdown_menu.md
```

---

## Migration Notes

### From Legacy Dropdown

The old `_dropdown.html.erb` partial is deprecated. Here's how to migrate:

**Before (Legacy)**

```erb
<div data-controller="menu-button">
  <button data-menu-button-target="button" data-action="menu-button#toggle">
    Options
  </button>
  <%%= render "components/dropdown" do %>
    <div class="dropdown-menu-item">Profile</div>
    <div class="dropdown-menu-item">Settings</div>
  <%% end %>
</div>
```

**After (New)**

```erb
<%%= dropdown_menu do |menu| %>
  <%% menu.trigger { "Options" } %>
  <%% menu.content do %>
    <%% menu.item "Profile", href: profile_path %>
    <%% menu.item "Settings", href: settings_path %>
  <%% end %>
<%% end %>
```
