# Dropdown Menu

> Displays a menu of actions triggered by a button.

<!-- preview:default height:200 -->

## Usage

```erb
<%%= render "components/dropdown_menu" do %>
  <%%= render "components/dropdown_menu/trigger" do %>Open Menu<%% end %>

  <%%= render "components/dropdown_menu/content" do %>
    <%%= render "components/dropdown_menu/item", href: "#" do %>Profile<%% end %>
    <%%= render "components/dropdown_menu/item", href: "#" do %>Settings<%% end %>
    <%%= render "components/dropdown_menu/separator" %>
    <%%= render "components/dropdown_menu/item", href: "#" do %>Logout<%% end %>
  <%% end %>
<%% end %>
```

## Examples

### With Icons

<!-- preview:with_icons height:240 -->

```erb
<%%= render "components/dropdown_menu/item", href: "#" do %>
  <%%= icon_for :user, class: "size-4" %>
  Profile
<%% end %>
<%%= render "components/dropdown_menu/item", href: "#", variant: :destructive do %>
  <%%= icon_for :log_out, class: "size-4" %>
  Logout
<%% end %>
```

### With Shortcuts

<!-- preview:with_shortcuts height:240 -->

```erb
<%%= render "components/dropdown_menu/item", href: "#" do %>
  Undo
  <%%= render "components/dropdown_menu/shortcut" do %>⌘Z<%% end %>
<%% end %>
```

### Icon Trigger

<!-- preview:icon_trigger height:180 -->

```erb
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
```

## API Reference

### Dropdown Menu

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| css_classes | String | "" | Additional CSS classes |
| html_options | Hash | {} | Additional HTML attributes |

### Dropdown Menu Trigger

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| variant | Symbol | :outline | Button variant when as_child is false |
| size | Symbol | :default | Button size when as_child is false |
| as_child | Boolean | false | Use custom trigger markup |
| css_classes | String | "" | Additional CSS classes |
| html_options | Hash | {} | Additional HTML attributes |

### Dropdown Menu Content

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| align | Symbol | :start | :start, :center, :end |
| side | Symbol | :bottom | :top, :bottom, :left, :right |
| width | Symbol | :default | :default, :sm, :md, :lg |
| css_classes | String | "" | Additional CSS classes |
| html_options | Hash | {} | Additional HTML attributes |

### Dropdown Menu Item

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| href | String | nil | URL, renders link if provided |
| method | Symbol | nil | HTTP method (:delete, :post, etc.) |
| variant | Symbol | :default | :default or :destructive |
| disabled | Boolean | false | Whether disabled |
| css_classes | String | "" | Additional CSS classes |
| html_options | Hash | {} | Additional HTML attributes |

### Dropdown Menu Label

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| text | String | nil | Label text, or use block |
| inset | Boolean | false | Align with icon items |
| css_classes | String | "" | Additional CSS classes |
| html_options | Hash | {} | Additional HTML attributes |

### Dropdown Menu Separator

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| css_classes | String | "" | Additional CSS classes |
| html_options | Hash | {} | Additional HTML attributes |

### Dropdown Menu Group

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| css_classes | String | "" | Additional CSS classes |
| html_options | Hash | {} | Additional HTML attributes |

### Dropdown Menu Shortcut

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| text | String | nil | Shortcut text, or use block |
| css_classes | String | "" | Additional CSS classes |
| html_options | Hash | {} | Additional HTML attributes |
