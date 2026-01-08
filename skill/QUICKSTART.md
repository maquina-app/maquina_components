# Quick Start: maquina-ui-standards

## When to Use

Implementing UI in Rails apps with maquina_components.

## Basic Workflow

```
1. Identify page type (dashboard, list, detail, form)
2. Check layout-patterns.md for structure
3. Use components from component-catalog.md
4. Follow form-patterns.md for forms
5. Add Turbo per turbo-integration.md
6. Verify with spec-checklist.md
```

## Page Types

| Type | Layout | Key Components |
|------|--------|----------------|
| Dashboard | Cards grid | Card, Badge, Button |
| List | Table or cards | Table, Pagination, EmptyState |
| Detail | Header + sections | Card, DescriptionList, Badge |
| Form | Centered card | Input, Select, Button, Alert |

## Form Essentials

```erb
<%= form_with model: @booking, class: "group space-y-4" do |f| %>
  <%# Inline errors (not alert list!) %>
  <div>
    <%= f.label :name %>
    <%= f.text_field :name, 
        required: true,
        maxlength: 100,
        data: { ... } %>
    <%= render_field_error(@booking, :name) %>
  </div>

  <%# Submit with loading state %>
  <%= f.button type: :submit, class: "..." do %>
    <span class="group-aria-busy:hidden">Save</span>
    <svg class="hidden group-aria-busy:block animate-spin">...</svg>
  <% end %>
<% end %>
```

## Key Patterns

1. **Errors:** Inline under fields, not alert lists
2. **Loading:** Use `group` + `group-aria-busy:` for spinners
3. **Inputs:** Always add `type`, `maxlength`, `autocomplete`
4. **Empty states:** Use EmptyState component with action

## Turbo Basics

| Pattern | Use Case |
|---------|----------|
| Morph (default) | Full page updates |
| Frame | Inline edit, modals |
| Stream | Multi-element updates |

## Next Steps

1. `component-catalog.md` — All available components
2. `layout-patterns.md` — Page structure templates
3. `form-patterns.md` — Validation and loading states
4. `spec-checklist.md` — Pre-flight verification
