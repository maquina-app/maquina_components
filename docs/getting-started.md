# Getting Started

Installation and integration guide for maquina_components in your Rails application.

---

## Quick Installation

The fastest way to get started is with the install generator:

### 1. Add the Gem

```ruby
# Gemfile
gem "maquina-components"
```

```bash
bundle install
```

### 2. Run the Install Generator

```bash
bin/rails generate maquina_components:install
```

This will:

- Add the engine CSS import to your Tailwind file
- Add theme variables (shadcn/ui convention) with light/dark mode
- Create a helper file for icon customization

### 3. Start Using Components

```erb
<%%= render "components/card" do %>
  <%%= render "components/card/header" do %>
    <%%= render "components/card/title", text: "Welcome" %>
  <%% end %>
  <%%= render "components/card/content" do %>
    <p>Your content here</p>
  <%% end %>
<%% end %>
```

For form elements, use data attributes:

```erb
<%%= form_with model: @user do |f| %>
  <%%= f.text_field :email, data: { component: "input" } %>
  <%%= f.submit "Save", data: { component: "button", variant: "primary" } %>
<%% end %>
```

---

## Generator Options

```bash
# Skip theme variables (if you already have them)
bin/rails generate maquina_components:install --skip-theme

# Skip helper creation
bin/rails generate maquina_components:install --skip-helper

# Skip both
bin/rails generate maquina_components:install --skip-theme --skip-helper
```

---

## Prerequisites

The generator requires **tailwindcss-rails** to be installed:

```bash
bundle add tailwindcss-rails
bin/rails tailwindcss:install
```

This creates `app/assets/tailwind/application.css` which the generator modifies.

---

## Manual Installation

If you prefer manual setup or need to understand what the generator does:

<details>
<summary>Click to expand manual installation steps</summary>

### 1. Add Engine CSS Import

```css
/* app/assets/tailwind/application.css */
@import "tailwindcss";

@import "../builds/tailwind/maquina_components_engine.css";
```

### 2. Add Theme Variables

Add these to your `app/assets/tailwind/application.css`:

```css
@custom-variant dark (&:is(.dark *));

:root {
  /* Layout */
  --header-height: calc(var(--spacing) * 12 + 1px);
  --sidebar-width: calc(var(--spacing) * 72);
  --sidebar-width-icon: 3rem;

  /* Core Colors */
  --background: oklch(1 0 0);
  --foreground: oklch(0.145 0 0);

  /* Card */
  --card: oklch(1 0 0);
  --card-foreground: oklch(0.145 0 0);

  /* Popover */
  --popover: oklch(1 0 0);
  --popover-foreground: oklch(0.145 0 0);

  /* Primary */
  --primary: oklch(0.205 0 0);
  --primary-foreground: oklch(0.985 0 0);

  /* Secondary */
  --secondary: oklch(0.97 0 0);
  --secondary-foreground: oklch(0.205 0 0);

  /* Muted */
  --muted: oklch(0.97 0 0);
  --muted-foreground: oklch(0.556 0 0);

  /* Accent */
  --accent: oklch(0.97 0 0);
  --accent-foreground: oklch(0.205 0 0);

  /* Destructive */
  --destructive: oklch(0.577 0.245 27.325);
  --destructive-foreground: oklch(0.985 0 0);

  /* Borders & Inputs */
  --border: oklch(0.922 0 0);
  --input: oklch(0.922 0 0);
  --ring: oklch(0.708 0 0);

  /* Sidebar */
  --sidebar: oklch(0.96 0 0);
  --sidebar-foreground: oklch(0.2 0 0);
  --sidebar-primary: oklch(0.205 0 0);
  --sidebar-primary-foreground: oklch(0.985 0 0);
  --sidebar-accent: oklch(0.9 0 0);
  --sidebar-accent-foreground: oklch(0.145 0 0);
  --sidebar-border: oklch(0.88 0 0);
  --sidebar-ring: oklch(0.708 0 0);

  /* Dark Mode */
  .dark {
    --background: oklch(0.145 0 0);
    --foreground: oklch(0.985 0 0);
    --card: oklch(0.205 0 0);
    --card-foreground: oklch(0.985 0 0);
    --popover: oklch(0.269 0 0);
    --popover-foreground: oklch(0.985 0 0);
    --primary: oklch(0.922 0 0);
    --primary-foreground: oklch(0.205 0 0);
    --secondary: oklch(0.269 0 0);
    --secondary-foreground: oklch(0.985 0 0);
    --muted: oklch(0.269 0 0);
    --muted-foreground: oklch(0.708 0 0);
    --accent: oklch(0.371 0 0);
    --accent-foreground: oklch(0.985 0 0);
    --destructive: oklch(0.704 0.191 22.216);
    --destructive-foreground: oklch(0.985 0 0);
    --border: oklch(1 0 0 / 10%);
    --input: oklch(1 0 0 / 15%);
    --ring: oklch(0.556 0 0);
    --sidebar: oklch(0.14 0 0);
    --sidebar-foreground: oklch(0.9 0 0);
    --sidebar-primary: oklch(0.488 0.243 264.376);
    --sidebar-primary-foreground: oklch(0.985 0 0);
    --sidebar-accent: oklch(0.22 0 0);
    --sidebar-accent-foreground: oklch(0.95 0 0);
    --sidebar-border: oklch(1 0 0 / 12%);
    --sidebar-ring: oklch(0.439 0 0);
  }
}

/* Tailwind Theme Bindings */
@theme {
  --color-background: var(--background);
  --color-foreground: var(--foreground);
  --color-primary: var(--primary);
  --color-primary-foreground: var(--primary-foreground);
  --color-muted: var(--muted);
  --color-muted-foreground: var(--muted-foreground);
  --color-secondary: var(--secondary);
  --color-secondary-foreground: var(--secondary-foreground);
  --color-accent: var(--accent);
  --color-accent-foreground: var(--accent-foreground);
  --color-destructive: var(--destructive);
  --color-destructive-foreground: var(--destructive-foreground);
  --color-input: var(--input);
  --color-border: var(--border);
  --color-ring: var(--ring);
  --color-card: var(--card);
  --color-card-foreground: var(--card-foreground);
  --color-popover: var(--popover);
  --color-popover-foreground: var(--popover-foreground);
  --color-sidebar: var(--sidebar);
  --color-sidebar-foreground: var(--sidebar-foreground);
  --color-sidebar-primary: var(--sidebar-primary);
  --color-sidebar-primary-foreground: var(--sidebar-primary-foreground);
  --color-sidebar-accent: var(--sidebar-accent);
  --color-sidebar-accent-foreground: var(--sidebar-accent-foreground);
  --color-sidebar-border: var(--sidebar-border);
  --color-sidebar-ring: var(--sidebar-ring);
}

/* Global border color */
* {
  border-color: var(--color-border);
}
```

### 3. Create Helper File

Create `app/helpers/maquina_components_helper.rb`:

```ruby
# frozen_string_literal: true

module MaquinaComponentsHelper
  # Override to use your own icon system
  def main_icon_svg_for(name)
    # Return nil to use engine's built-in icons
    # Or return SVG string for custom icons
    nil
  end

  # Sidebar state helpers (re-exported for convenience)
  def app_sidebar_state(cookie_name = "sidebar_state")
    sidebar_state(cookie_name)
  end

  def app_sidebar_open?(cookie_name = "sidebar_state")
    sidebar_open?(cookie_name)
  end

  def app_sidebar_closed?(cookie_name = "sidebar_state")
    sidebar_closed?(cookie_name)
  end
end
```

</details>

---

## Stimulus Setup (Interactive Components)

Interactive components (Sidebar, Dropdown Menu, Toggle Group, Breadcrumbs) require Stimulus. If you're using importmaps, ensure Stimulus is initialized:

```ruby
# config/importmap.rb
pin "@hotwired/turbo-rails", to: "turbo.min.js"
pin "@hotwired/stimulus", to: "stimulus.min.js"
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js"
pin_all_from "app/javascript/controllers", under: "controllers"
```

```javascript
// app/javascript/application.js
import "@hotwired/turbo-rails"
import { Application } from "@hotwired/stimulus"
import { eagerLoadControllersFrom } from "@hotwired/stimulus-loading"

const application = Application.start()
application.debug = false
window.Stimulus = application

eagerLoadControllersFrom("controllers", application)
```

**Note:** Static components (Badge, Card, Alert, Button, form elements) work without JavaScript.

---

## Theme Variables

maquina_components uses CSS variables following the [shadcn/ui theming convention](https://ui.shadcn.com/docs/theming).

### Dual-Definition Pattern

Variables must be defined twice for Tailwind CSS v4:

1. **`:root`** — Defines the actual color values
2. **`@theme`** — Makes them available as Tailwind utilities (`bg-primary`, `text-muted-foreground`)

```css
:root {
  --primary: oklch(0.205 0 0);           /* Actual value */
}

@theme {
  --color-primary: var(--primary);        /* Enables: bg-primary, text-primary */
}
```

### Customizing Colors

Edit the values in `:root` to match your brand. The generator provides neutral grays by default. Common customizations:

```css
:root {
  /* Blue primary */
  --primary: oklch(0.488 0.243 264.376);
  --primary-foreground: oklch(0.985 0 0);
  
  /* Green success (add new semantic color) */
  --success: oklch(0.6 0.2 145);
  --success-foreground: oklch(0.985 0 0);
}

@theme {
  --color-success: var(--success);
  --color-success-foreground: var(--success-foreground);
}
```

---

## Icon System

Components use `icon_for(:name)` to render icons. The gem includes essential icons, but you'll want to add your own.

### Override Icon Lookup

Edit `app/helpers/maquina_components_helper.rb`:

```ruby
module MaquinaComponentsHelper
  def main_icon_svg_for(name)
    case name
    when :home
      <<~SVG
        <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
          <path d="M15 21v-8a1 1 0 0 0-1-1h-4a1 1 0 0 0-1 1v8"/>
          <path d="M3 10a2 2 0 0 1 .709-1.528l7-5.999a2 2 0 0 1 2.582 0l7 5.999A2 2 0 0 1 21 10v9a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z"/>
        </svg>
      SVG
    when :settings
      # ... more icons
    end
  end
end
```

Icons are sourced from [Lucide](https://lucide.dev). Copy SVG code directly from their website.

### Using Heroicons or Other Libraries

```ruby
def main_icon_svg_for(name)
  # If using heroicon gem
  heroicon(name, variant: :outline)
  
  # Or inline_svg gem
  # inline_svg_tag("icons/#{name}.svg")
end
```

---

## Sidebar Setup

The Sidebar is the most complex component. Key requirements:

### Provider Must Wrap Everything

```erb
<!-- CORRECT -->
<%%= render "components/sidebar/provider", default_open: app_sidebar_open? do %>
  <%%= render "components/sidebar" do %>
    <!-- sidebar content -->
  <%% end %>
  
  <%%= render "components/sidebar/inset" do %>
    <!-- main content -->
  <%% end %>
<%% end %>
```

### Custom Cookie Name

```ruby
# app/helpers/maquina_components_helper.rb
SIDEBAR_COOKIE = "myapp_sidebar"

def app_sidebar_state
  sidebar_state(SIDEBAR_COOKIE)
end

def app_sidebar_open?
  sidebar_open?(SIDEBAR_COOKIE)
end
```

```erb
<%%= render "components/sidebar/provider",
  default_open: app_sidebar_open?,
  cookie_name: MaquinaComponentsHelper::SIDEBAR_COOKIE do %>
  ...
<%% end %>
```

See [Sidebar Documentation](https://maquina.app/documentation/components/sidebar/) for complete usage.

---

## Complete Layout Example

```erb
<!DOCTYPE html>
<html lang="en" class="h-full">
  <head>
    <title><%%= content_for(:title) || "My App" %></title>
    <%%= csrf_meta_tags %>
    <%%= csp_meta_tag %>
    <%%= stylesheet_link_tag "application", data_turbo_track: "reload" %>
    <%%= javascript_importmap_tags %>
  </head>

  <body class="h-full overflow-hidden bg-background font-sans antialiased">
    <%%= render "components/sidebar/provider",
      default_open: app_sidebar_open?,
      variant: :inset do %>
      
      <%%= render "components/sidebar", variant: :inset do %>
        <%%= render "components/sidebar/header" do %>
          <span class="font-semibold">My App</span>
        <%% end %>

        <%%= render "components/sidebar/content" do %>
          <%%= render "components/sidebar/group", title: "Menu" do %>
            <%%= render "components/sidebar/menu" do %>
              <%%= render "components/sidebar/menu_item" do %>
                <%%= render "components/sidebar/menu_button",
                  title: "Dashboard",
                  url: root_path,
                  icon_name: :home,
                  active: current_page?(root_path) %>
              <%% end %>
            <%% end %>
          <%% end %>
        <%% end %>

        <%%= render "components/sidebar/footer" do %>
          <!-- User menu -->
        <%% end %>
      <%% end %>

      <%%= render "components/sidebar/inset" do %>
        <%%= render "components/header" do %>
          <%%= render "components/sidebar/trigger", icon_name: :panel_left %>
        <%% end %>

        <main class="flex-1 overflow-y-auto p-6">
          <%%= yield %>
        </main>
      <%% end %>
    <%% end %>
  </body>
</html>
```

---

## Troubleshooting

### Generator Issues

**"tailwindcss-rails doesn't appear to be installed"**

Install it first:

```bash
bundle add tailwindcss-rails
bin/rails tailwindcss:install
```

**Theme variables not added**

If you already have `--color-primary:` in your CSS, the generator skips adding theme variables. Use `--skip-theme` and add manually, or remove existing variables first.

### Runtime Issues

**Sidebar trigger not working**

- Ensure Stimulus is initialized
- Verify provider wraps both sidebar and content
- Check browser console for errors

**Styles not applying**

- Verify engine CSS is imported after `@import "tailwindcss";`
- Check that `@theme` block exists with color bindings
- Restart dev server after CSS changes

**Dark mode not working**

- Add `.dark` class to `<html>` element
- Ensure `.dark { }` block has variable overrides

**Icons not rendering**

- Check icon name matches your `main_icon_svg_for` cases
- Verify helper is included in ApplicationHelper

---

## Next Steps

### Layout

- [Sidebar](https://maquina.app/documentation/components/sidebar/) — Navigation sidebar with collapse state
- [Header](https://maquina.app/documentation/components/header/) — Top navigation bar

### Content

- [Card](https://maquina.app/documentation/components/card/) — Content containers
- [Alert](https://maquina.app/documentation/components/alert/) — Callouts and notifications
- [Badge](https://maquina.app/documentation/components/badge/) — Status indicators
- [Table](https://maquina.app/documentation/components/table/) — Data tables
- [Empty State](https://maquina.app/documentation/components/empty/) — Empty state placeholders

### Navigation

- [Breadcrumbs](https://maquina.app/documentation/components/breadcrumbs/) — Navigation breadcrumbs
- [Dropdown Menu](https://maquina.app/documentation/components/dropdown-menu/) — Dropdown menus
- [Pagination](https://maquina.app/documentation/components/pagination/) — Page navigation with Pagy

### Interactive

- [Toggle Group](https://maquina.app/documentation/components/toggle-group/) — Toggle button groups

### Forms

- [Form Components](https://maquina.app/documentation/components/form/) — Buttons, inputs, selects, checkboxes

---

## File Structure After Setup

```
app/
├── assets/tailwind/
│   └── application.css          # Theme + engine import
├── helpers/
│   └── maquina_components_helper.rb  # Icon override
├── javascript/
│   └── application.js           # Stimulus init
└── views/layouts/
    └── application.html.erb     # Layout with components
```
