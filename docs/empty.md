# Empty State

> Displays a placeholder when there's no data to show.

---

## Quick Reference

### Helper Methods

| Method | Description |
|--------|-------------|
| `empty_state` | Simple API for common empty states |
| `empty_search_state` | Pre-configured for search results |
| `empty_list_state` | Pre-configured for empty lists/tables |

### Parts

| Part | Description |
|------|-------------|
| `components/empty` | Root container |
| `components/empty/header` | Groups media, title, and description |
| `components/empty/media` | Icon or illustration container |
| `components/empty/title` | Heading text |
| `components/empty/description` | Supporting text |
| `components/empty/actions` | CTA buttons container |

### Parameters

#### `empty`

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `css_classes` | String | `""` | Additional CSS classes |
| `**html_options` | Hash | `{}` | HTML attributes |

#### `empty/media`

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `icon` | Symbol | `nil` | Icon name (uses `icon_for` helper) |
| `icon_class` | String | `"size-10"` | Icon size classes |
| `css_classes` | String | `""` | Additional CSS classes |

#### `empty/title`

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `text` | String | `nil` | Title text (or use block) |
| `css_classes` | String | `""` | Additional CSS classes |

#### `empty/description`

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `text` | String | `nil` | Description text (or use block) |
| `css_classes` | String | `""` | Additional CSS classes |

### Data Attributes

**Component Identifiers**

| Attribute | Element | Description |
|-----------|---------|-------------|
| `data-component="empty"` | Container div | Main component identifier |
| `data-empty-part="header"` | Header div | Header section |
| `data-empty-part="media"` | Media div | Icon/illustration container |
| `data-empty-part="title"` | Title element | Heading |
| `data-empty-part="description"` | Description element | Supporting text |
| `data-empty-part="actions"` | Actions div | Buttons container |

---

## Basic Usage

### Using Helper Methods (Recommended)

```erb
<%%= empty_state(
  icon: :inbox,
  title: "No messages",
  description: "Get started by sending your first message."
) do %>
  <%%= link_to "Compose", new_message_path, data: { component: "button", variant: "primary" } %>
<%% end %>
```

### Using Partials

```erb
<%%= render "components/empty" do %>
  <%%= render "components/empty/header" do %>
    <%%= render "components/empty/media", icon: :inbox %>
    <%%= render "components/empty/title", text: "No messages" %>
    <%%= render "components/empty/description", text: "Get started by sending your first message." %>
  <%% end %>
  <%%= render "components/empty/actions" do %>
    <%%= link_to "Compose", new_message_path, data: { component: "button", variant: "primary" } %>
  <%% end %>
<%% end %>
```

---

## Examples

### Search Results Empty

```erb
<%%= empty_search_state(query: @query) %>
```

Renders:
```
🔍 No results found
We couldn't find anything matching "your query".
```

### List/Table Empty

```erb
<%%= empty_list_state(
  resource: "projects",
  new_path: new_project_path
) %>
```

Renders:
```
📁 No projects yet
Get started by creating your first project.
[Create Project]
```

### With Custom Icon

```erb
<%%= render "components/empty" do %>
  <%%= render "components/empty/header" do %>
    <%%= render "components/empty/media", icon: :users, icon_class: "size-12 text-primary" %>
    <%%= render "components/empty/title", text: "No team members" %>
    <%%= render "components/empty/description", text: "Invite people to collaborate." %>
  <%% end %>
  <%%= render "components/empty/actions" do %>
    <%%= link_to "Invite", invite_path, data: { component: "button", variant: "primary" } %>
    <%%= link_to "Learn more", help_path, data: { component: "button", variant: "outline" } %>
  <%% end %>
<%% end %>
```

### With Illustration (Custom Media)

```erb
<%%= render "components/empty" do %>
  <%%= render "components/empty/header" do %>
    <%%= render "components/empty/media" do %>
      <%%= image_tag "illustrations/empty-inbox.svg", class: "w-48 h-48" %>
    <%% end %>
    <%%= render "components/empty/title", text: "Your inbox is empty" %>
    <%%= render "components/empty/description", text: "Messages you receive will appear here." %>
  <%% end %>
<%% end %>
```

### Minimal (No Actions)

```erb
<%%= render "components/empty" do %>
  <%%= render "components/empty/header" do %>
    <%%= render "components/empty/media", icon: :check_circle, icon_class: "size-8 text-success" %>
    <%%= render "components/empty/title", text: "All caught up!" %>
    <%%= render "components/empty/description", text: "You have no pending tasks." %>
  <%% end %>
<%% end %>
```

---

## Real-World Patterns

### In a Table

```erb
<table data-component="table">
  <thead>
    <tr>
      <th>Name</th>
      <th>Email</th>
      <th>Role</th>
    </tr>
  </thead>
  <tbody>
    <%% if @users.empty? %>
      <tr>
        <td colspan="3">
          <%%= empty_list_state(resource: "users", new_path: new_user_path) %>
        </td>
      </tr>
    <%% else %>
      <%% @users.each do |user| %>
        <tr>...</tr>
      <%% end %>
    <%% end %>
  </tbody>
</table>
```

### After Search

```erb
<%% if @results.empty? %>
  <%%= empty_search_state(query: params[:q]) do %>
    <%%= link_to "Clear search", products_path, data: { component: "button", variant: "outline" } %>
  <%% end %>
<%% else %>
  <%# render results %>
<%% end %>
```

### Conditional by State

```erb
<%% if @projects.empty? && @filter == "archived" %>
  <%%= empty_state(
    icon: :archive,
    title: "No archived projects",
    description: "Projects you archive will appear here."
  ) %>
<%% elsif @projects.empty? %>
  <%%= empty_list_state(resource: "projects", new_path: new_project_path) %>
<%% end %>
```

---

## Theme Variables

```css
var(--muted-foreground)  /* Icon and description color */
var(--foreground)        /* Title color */
```

---

## Customization

### Compact Empty State

```erb
<%%= render "components/empty", css_classes: "py-8" do %>
  <%%= render "components/empty/header" do %>
    <%%= render "components/empty/media", icon: :inbox, icon_class: "size-6" %>
    <%%= render "components/empty/title", text: "No items", css_classes: "text-sm" %>
  <%% end %>
<%% end %>
```

### Full-Page Empty State

```erb
<%%= render "components/empty", css_classes: "min-h-[60vh]" do %>
  <%# ... %>
<%% end %>
```

---

## Accessibility

- Uses semantic structure (heading for title)
- Icon has `aria-hidden="true"` (decorative)
- Description provides context
- Action buttons are keyboard accessible

---

## File Structure

```
app/views/components/
├── _empty.html.erb
└── empty/
    ├── _header.html.erb
    ├── _media.html.erb
    ├── _title.html.erb
    ├── _description.html.erb
    └── _actions.html.erb

app/assets/stylesheets/empty.css
app/helpers/maquina_components/empty_helper.rb
docs/empty.md
```
