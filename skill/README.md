# Maquina UI Standards Skill

A Claude skill for building consistent, accessible UIs in Ruby on Rails applications using [maquina_components](https://github.com/maquina-app/maquina_components).

## What This Skill Does

This skill teaches Claude how to implement UI components correctly in Rails applications using the maquina_components library. It provides:

- **Component catalog** — Complete reference for all 15+ components with ERB examples
- **Form patterns** — Validation, error handling, inline layouts, and complex form structures
- **Layout patterns** — Sidebar navigation, page structure, responsive design
- **Turbo integration** — Turbo Frames, Streams, and component updates
- **Spec checklist** — Review criteria for UI implementation quality

When you ask Claude to build views, forms, or interactive features, it will use the correct component patterns, data attributes, and accessibility practices from this skill.

## Components Covered

| Category    | Components                                               |
| ----------- | -------------------------------------------------------- |
| Layout      | Sidebar, Header                                          |
| Content     | Card, Alert, Badge, Table, Empty State, Separator        |
| Feedback    | Toast                                                    |
| Navigation  | Breadcrumbs, Dropdown Menu, Pagination                   |
| Interactive | Combobox, Toggle Group                                   |
| Form        | Button, Input, Textarea, Select, Checkbox, Radio, Switch |

## Installation

### 1. Create the skills directory in your Rails project

```bash
cd your-rails-app
mkdir -p .claude/skills
```

### 2. Add the skill

**Option A: Unzip the release**

```bash
unzip maquina-ui-standards.zip -d .claude/skills/
```

**Option B: Clone/copy the directory**

```bash
cp -r /path/to/maquina-ui-standards .claude/skills/
```

### 3. Add to your CLAUDE.md

Create or update `CLAUDE.md` in your project root:

```markdown
# CLAUDE.md

## UI Components

This project uses maquina_components for UI. Before implementing any views, 
forms, or interactive components, read the UI standards skill:

\`\`\`
.claude/skills/maquina-ui-standards/SKILL.md
\`\`\`

### When to Reference the Skill

**Always consult the skill when:**
- Creating or modifying views (`app/views/**/*.erb`)
- Implementing forms
- Adding interactive components (dropdowns, comboboxes, toasts)
- Building layouts with sidebar/header patterns
- Working with Turbo Streams that update UI

**Key references:**
| File | Use For |
|------|---------|
| `references/component-catalog.md` | All components with examples |
| `references/form-patterns.md` | Forms, validation, errors |
| `references/layout-patterns.md` | Page structure, sidebar |
| `references/turbo-integration.md` | Turbo Frames/Streams |
| `references/spec-checklist.md` | UI spec review checklist |

### Quick Patterns

**Form elements** — Use data attributes:
\`\`\`erb
<%= f.text_field :name, data: { component: "input" } %>
<%= f.submit "Save", data: { component: "button", variant: "primary" } %>
\`\`\`

**Complex components** — Use partials:
\`\`\`erb
<%= render "components/card" do %>
  <%= render "components/card/header" do %>
    <%= render "components/card/title", text: "Title" %>
  <% end %>
<% end %>
\`\`\`

**Combobox** — Searchable select:
\`\`\`erb
<%= combobox_simple placeholder: "Select...",
                     name: "model[field]",
                     options: @items.map { |i| { value: i.id, label: i.name } } %>
\`\`\`

**Toast** — Flash messages render automatically as toasts:
\`\`\`ruby
flash[:success] = "Saved!"
flash[:error] = "Failed."
\`\`\`
```

### 4. Verify installation

In Claude Code, run:

```
Read the maquina UI standards skill and list the available components.
```

Claude should enumerate all components from the catalog.

## Usage

Once installed, Claude will automatically reference the skill when working on UI. You can also prompt explicitly:

### Building Views

```
Create the users index view with a table showing name, email, and status.
Use the maquina UI standards.
Add a card with stats (total users, active, pending) to the dashboard.
```

### Forms

```
Implement the project form with name, description, and a framework combobox.
Add inline validation errors to this form following the UI patterns.
```

### Interactive Components

```
Add a user assignment combobox to the task form. Users should be searchable.
Implement toast notifications for the controller's create and update actions.
```

### Review & Refactoring

```
Review this view against the maquina UI standards and suggest improvements.
Refactor this form to use proper component patterns and error handling.
```

## File Structure

```
maquina-ui-standards/
├── SKILL.md                           # Main skill instructions
├── QUICKSTART.md                      # Quick reference
└── references/
    ├── component-catalog.md           # All components with examples
    ├── form-patterns.md               # Form layouts and validation
    ├── layout-patterns.md             # Page structure patterns
    ├── spec-checklist.md              # UI review checklist
    └── turbo-integration.md           # Turbo Frames/Streams
```

## Requirements

- Ruby on Rails 7.1+
- [maquina_components](https://github.com/maquina-app/maquina_components) gem
- Tailwind CSS v4
- Stimulus (for interactive components)
- Turbo (for real-time updates)

## Keeping Updated

When maquina_components releases new versions:

1. Check the [changelog](https://maquina.app/blog/)
2. Update `references/component-catalog.md` with new components
3. Update any changed patterns in other reference files

## License

MIT

## Links

- [maquina_components gem](https://github.com/maquina-app/maquina_components)
- [Documentation](https://maquina.app/documentation/components/)
- [Blog](https://maquina.app/blog/)