# maquina_components Engine Architecture

> Complete guide to the Rails Engine structure, Tailwind CSS v4 integration, and how components are organized.

## Overview

**maquina_components** is a Rails Engine that provides server-rendered UI components inspired by shadcn/ui. It's designed for Rails 7.2+ applications using Tailwind CSS v4 (tailwindcss-rails) and Stimulus.

- **Gem name:** `maquina-components`
- **Repository:** https://github.com/maquina-app/maquina_components
- **Dependencies:** Rails >= 7.2.0, tailwindcss-rails ~> 4.2, importmap-rails >= 1.2, stimulus-rails >= 1.3

## Directory Structure

```
maquina_components/
├── app/
│   ├── assets/
│   │   ├── stylesheets/              # One CSS file per component (all in @layer components)
│   │   │   ├── alert.css
│   │   │   ├── badge.css
│   │   │   ├── breadcrumbs.css
│   │   │   ├── calendar.css
│   │   │   ├── card.css
│   │   │   ├── combobox.css
│   │   │   ├── date_picker.css
│   │   │   ├── drawer.css
│   │   │   ├── dropdown_menu.css
│   │   │   ├── empty.css
│   │   │   ├── form.css              # button, input, textarea, select, checkbox,
│   │   │   │                         # radio, switch, label, fieldset, input-group
│   │   │   ├── header.css
│   │   │   ├── menu_button.css
│   │   │   ├── pagination.css
│   │   │   ├── separator.css
│   │   │   ├── sidebar.css
│   │   │   ├── stats.css
│   │   │   ├── table.css
│   │   │   ├── toast.css
│   │   │   └── toggle_group.css
│   │   └── tailwind/
│   │       └── maquina_components_engine/
│   │           ├── engine.css        # Tailwind entry point (imports, in a load-bearing order)
│   │           └── tokens.css        # Engine design tokens (@theme static) + scheme defaults
│   │
│   ├── helpers/maquina_components/   # Ruby view helpers
│   │   ├── components_helper.rb      # merge_component_data (used by every partial)
│   │   ├── icons_helper.rb           # icon_for, builtin_icon_for
│   │   ├── breadcrumbs_helper.rb     # breadcrumbs, responsive_breadcrumbs
│   │   ├── calendar_helper.rb
│   │   ├── combobox_helper.rb        # combobox, combobox_simple
│   │   ├── drawer_helper.rb          # drawer_state, drawer_open?
│   │   ├── dropdown_menu_helper.rb   # dropdown_menu, dropdown_menu_simple
│   │   ├── empty_helper.rb           # empty_state, empty_search_state, empty_list_state
│   │   ├── pagination_helper.rb      # pagination_nav, pagination_simple (pagy)
│   │   ├── sidebar_helper.rb         # sidebar_state, sidebar_open?
│   │   ├── table_helper.rb           # simple_table
│   │   ├── toast_helper.rb           # toast, toast_flash_messages
│   │   └── toggle_group_helper.rb    # toggle_group, toggle_group_simple
│   │
│   ├── javascript/controllers/       # Stimulus controllers
│   │   ├── breadcrumb_controller.js
│   │   ├── calendar_controller.js
│   │   ├── combobox_controller.js
│   │   ├── date_picker_controller.js
│   │   ├── drawer_controller.js
│   │   ├── drawer_trigger_controller.js
│   │   ├── dropdown_menu_controller.js
│   │   ├── menu_button_controller.js
│   │   ├── sidebar_controller.js
│   │   ├── sidebar_trigger_controller.js
│   │   ├── toast_controller.js
│   │   ├── toaster_controller.js
│   │   └── toggle_group_controller.js
│   │
│   └── views/components/             # ERB partials
│       ├── _alert.html.erb
│       ├── _badge.html.erb
│       ├── _breadcrumbs.html.erb
│       ├── _calendar.html.erb
│       ├── _card.html.erb
│       ├── _combobox.html.erb
│       ├── _date_picker.html.erb
│       ├── _drawer.html.erb
│       ├── _dropdown.html.erb        # menu button popover content (see note)
│       ├── _dropdown_menu.html.erb
│       ├── _empty.html.erb
│       ├── _header.html.erb
│       ├── _label.html.erb
│       ├── _menu_button.html.erb
│       ├── _pagination.html.erb
│       ├── _separator.html.erb
│       ├── _sidebar.html.erb
│       ├── _simple_table.html.erb
│       ├── _table.html.erb
│       ├── _toast.html.erb
│       ├── _toaster.html.erb
│       ├── _toggle_group.html.erb
│       ├── alert/                    # Compound component sub-partials
│       ├── breadcrumbs/
│       ├── calendar/
│       ├── card/
│       ├── combobox/
│       ├── drawer/
│       ├── dropdown_menu/
│       ├── empty/
│       ├── pagination/
│       ├── sidebar/
│       ├── stats/                    # _stats_card, _stats_grid (no top-level partial)
│       ├── table/
│       ├── toast/
│       └── toggle_group/
│
├── config/
│   └── importmap.rb                  # pin_all_from app/javascript/controllers under "controllers"
│
├── docs/                             # Component documentation (one .md per component,
│                                     # plus getting-started.md, theming.md, upgrading.md)
│
├── lib/
│   ├── maquina-components.rb         # Main require file; MaquinaComponents.strict_icons
│   ├── maquina_components/
│   │   ├── engine.rb                 # Engine configuration
│   │   ├── doctor.rb                 # Upgrade scanner behind `rake maquina:doctor`
│   │   └── version.rb
│   ├── generators/maquina_components/
│   │   ├── install/                  # rails g maquina_components:install
│   │   │   └── templates/            # theme.css.tt, shape_state_tokens.css.tt,
│   │   │                             # maquina_components_helper.rb.tt
│   │   └── scaffold_templates/       # rails g maquina_components:scaffold_templates
│   └── tasks/
│       └── maquina_components_tasks.rake   # maquina:doctor
│
└── test/
    ├── components/                   # Partial render tests
    ├── generators/                   # Install + scaffold generator tests
    ├── helpers/
    ├── integration/                  # Docs ↔ preview contract, preview smoke tests
    ├── lib/                          # doctor tests
    ├── stylesheets/                  # CSS convention guards (run against compiled CSS)
    └── dummy/                        # Demo/preview Rails application
```

> `_dropdown.html.erb` is not a standalone dropdown: it renders the **menu button's** popover content (`data-menu-button-part="content"`). New menus should use `dropdown_menu`.

## Engine Configuration

### lib/maquina-components.rb

Requires `importmap-rails` and `stimulus-rails` (gemspec dependencies are not auto-required by Bundler in host apps), then the engine. It also defines:

- `MaquinaComponents::UnknownIconError`
- `MaquinaComponents.strict_icons` — when true, `icon_for` raises for an unknown icon name instead of rendering nothing. Defaults to `Rails.env.local?` (development and test).

### lib/maquina_components/engine.rb

```ruby
module MaquinaComponents
  class Engine < ::Rails::Engine
    initializer "maquina-components.importmap", before: "importmap" do |app|
      # Hosts bundling JS without importmap-rails (esbuild, vite, bun)
      # have no config.importmap; skip so the engine doesn't break boot.
      if app.config.respond_to?(:importmap)
        app.config.importmap.paths << root.join("config/importmap.rb")
        app.config.importmap.cache_sweepers << root.join("app/javascript")
      end
    end

    initializer "maquina-components.assets" do |app|
      if app.config.respond_to?(:assets)
        app.config.assets.paths << Engine.root.join("app/javascript")
      end
    end
  end
end
```

**Key behaviors:**
- Adds the engine's `config/importmap.rb` to the host's importmap (only when importmap-rails is configured)
- Sets up cache sweeping for JavaScript controllers
- Adds the JavaScript path to the asset pipeline

The engine's importmap pins every controller under `controllers/`, so a host using `eagerLoadControllersFrom("controllers", application)` registers them automatically with identifiers derived from the file name (`dropdown_menu_controller.js` → `dropdown-menu`).

## Tailwind CSS v4 Integration

### How It Works

tailwindcss-rails compiles each engine's `app/assets/tailwind/<engine_name>/engine.css` into `app/assets/builds/tailwind/<engine_name>.css` in the host app. The host's `application.css` imports that build. The engine's `@source` directive makes Tailwind scan the engine's views for utility classes.

### engine.css (Entry Point)

Location: `app/assets/tailwind/maquina_components_engine/engine.css`

```css
/* Token defaults must come first: every component stylesheet reads them. */
@import "./tokens.css";

@source "../../../views/";

/* IMPORT ORDER IS LOAD-BEARING — DO NOT ALPHABETIZE (see the file's header) */

/* ----- 1. Primitives ----- */
@import "../../stylesheets/form.css";
@import "../../stylesheets/badge.css";
@import "../../stylesheets/separator.css";
@import "../../stylesheets/card.css";
@import "../../stylesheets/table.css";

/* ----- 2. Composites ----- */
@import "../../stylesheets/alert.css";
@import "../../stylesheets/empty.css";
@import "../../stylesheets/stats.css";
@import "../../stylesheets/toggle_group.css";
@import "../../stylesheets/pagination.css";
@import "../../stylesheets/toast.css";
@import "../../stylesheets/calendar.css";
@import "../../stylesheets/date_picker.css";
@import "../../stylesheets/sidebar.css";
@import "../../stylesheets/header.css";
@import "../../stylesheets/menu_button.css";
@import "../../stylesheets/drawer.css";
@import "../../stylesheets/dropdown_menu.css";
@import "../../stylesheets/combobox.css";
@import "../../stylesheets/breadcrumbs.css";
```

**Critical elements:**
- `@import "./tokens.css"` first — declares the role tokens (`--control-radius`, `--focus-ring-width`, `--elevation-*`, …) in `@theme static`, plus scheme-dependent internal defaults on `:root` / `.dark`
- `@source "../../../views/"` — tells Tailwind to scan engine views for classes
- **Grouped, ordered imports.** Every component rule lives in `@layer components` and is flattened to specificity 0,1,0 with `:where()`, so *source order* is the only tie-breaker, across files as well as inside them. Primitives first (form/badge/separator/card/table), then composites, each after anything it overrides (calendar → date_picker, sidebar → header/menu_button, form → drawer/dropdown_menu/combobox, dropdown_menu → breadcrumbs).

### Cascade Layers

| Layer | Contents | Who wins |
|-------|----------|----------|
| `@layer theme` | Engine tokens (`tokens.css`), host `@theme` bindings | Loses to the host's unlayered `:root` |
| `@layer base` | Preflight, the installer's `* { border-color }` shim | — |
| `@layer components` | Every engine component rule | Loses to utilities |
| `@layer utilities` | Tailwind utilities, including `css_classes:` | Beats components |
| unlayered | Host theme `:root` / `.dark` blocks, host overrides | Beats every layer |

Consequences:
- A Tailwind utility passed via `css_classes:` overrides the engine.
- A host's unlayered override CSS wins whatever its specificity.
- An unlayered `*` rule in the host (e.g. the pre-0.6 `* { border-color: … }` shim) overrides every component border — keep it in `@layer base`.
- The only unlayered engine rule is `body[data-maquina-scroll-locked]` in `drawer.css` (a functional scroll lock).

### Host App Setup

#### 1. Add to Gemfile

```ruby
gem "maquina-components"
```

#### 2. Run the install generator

```bash
bin/rails generate maquina_components:install
# --skip-theme   skip the palette and token block
# --skip-helper  skip app/helpers/maquina_components_helper.rb
```

The generator (requires `app/assets/tailwind/application.css` from `rails tailwindcss:install`):

1. Inserts `@import "../builds/tailwind/maquina_components_engine.css";` after `@import "tailwindcss";`
2. Appends the theme palette (`theme.css.tt`): `@custom-variant dark`, `:root` and top-level `.dark` palettes, `@theme` color bindings, and the `@layer base { * { border-color } }` shim — skipped if `--color-primary:` is already present
3. Appends the shape/state token block (`shape_state_tokens.css.tt`), guarded by the `maquina_components:shape-state-tokens` marker so re-running is idempotent
4. Creates `app/helpers/maquina_components_helper.rb` (icon override hook `main_icon_svg_for`, sidebar state helpers, includes the engine helper modules)

Resulting `app/assets/tailwind/application.css` (abridged):

```css
@import "tailwindcss";

@import "../builds/tailwind/maquina_components_engine.css";

@custom-variant dark (&:is(.dark *));

:root {
  --background: oklch(1 0 0);
  --foreground: oklch(0.145 0 0);
  --primary: oklch(0.645 0.246 16);
  --primary-foreground: oklch(0.969 0.015 12);
  /* ... full palette, see theme_variables.md */
}

.dark {
  --background: oklch(0.145 0 0);
  /* ... */
}

@theme {
  --color-background: var(--background);
  --color-primary: var(--primary);
  /* ... */
}

@layer base {
  * {
    border-color: var(--color-border);
  }
}
```

#### 3. JavaScript

Handled by the engine initializer when the host uses importmap-rails. Hosts on jsbundling (esbuild, vite, bun) have no `config.importmap`; they must import and register the controllers from the gem path themselves.

#### 4. Upgrading

```bash
bundle update maquina-components
bin/rails maquina:doctor   # advisory scan of app CSS/views/JS; never edits, always exits 0
```

See `docs/upgrading.md` for per-release notes.

## Adding New Components

### Checklist

1. **Create ERB partial** — `app/views/components/_{component}.html.erb`
2. **Create CSS file** — `app/assets/stylesheets/{component}.css` (rules inside `@layer components`)
3. **Import CSS in engine.css** — in the right group (primitive vs composite), *after* anything it overrides
4. **Create documentation** — `docs/{component}.md`, plus a preview in `test/dummy/app/views/previews/{component}/` for every `<!-- preview:NAME height:N -->` tag
5. **(Optional) Add helper** — `app/helpers/maquina_components/{component}_helper.rb`
6. **(Optional) Add Stimulus controller** — `app/javascript/controllers/{component}_controller.js`
7. **Run the guards** — `test/stylesheets/*` and `test/integration/docs_previews_contract_test.rb` (see Testing below)

### Step 1: Create ERB Partial

```erb
<%# locals: (variant: :default, size: :md, css_classes: "", **html_options) %>
<% merged_data = merge_component_data(html_options,
    component: "my-component",
    variant: variant,
    size: size
  ) %>

<%= content_tag :div, class: css_classes.presence, data: merged_data, **html_options do %>
  <%= yield %>
<% end %>
```

**Conventions:**
- Use strict locals with symbol defaults
- Merge the caller's `data:` with `merge_component_data` (the component keeps `component`/`variant`/`size`/`*_part`; `controller`/`action` concatenate; `nil` values are dropped)
- Use `css_classes` parameter (not `class:`)
- Always include `**html_options` for passthrough
- Multi-word component names are kebab-case strings: `component: "dropdown-menu"`

### Step 2: Create CSS File

```css
/* ===== MyComponent Styles ===== */
/*
 * Cascade order in this file (full contract documented in form.css):
 *   1. base  2. sizes  3. variants  4. states  5. dark — none (tokens)
 */

@layer components {
  /* Base */
  [data-component="my-component"] {
    display: flex;
    @apply gap-4;
    border-radius: var(--my-component-radius, var(--control-radius, 0.375rem));
    background-color: var(--card);
    color: var(--card-foreground);
    @apply transition-[color,background-color,border-color] duration-150;
  }

  /* Sizes */
  [data-component="my-component"]:where([data-size="sm"]) {
    @apply text-sm p-2;
  }

  [data-component="my-component"]:where([data-size="md"]) {
    @apply text-base p-4;
  }

  /* Variants */
  [data-component="my-component"]:where([data-variant="primary"]) {
    background-color: var(--primary);
    color: var(--primary-foreground);
  }

  /* States — always after variants */
  [data-component="my-component"]:where([data-variant="primary"]:hover) {
    background-color: var(--primary-hover, color-mix(in oklch, var(--primary) 90%, black));
  }

  [data-component="my-component"]:where(:focus-visible) {
    outline-width: var(--focus-ring-width, 3px);
    outline-style: var(--focus-ring-style, solid);
    outline-color: var(--focus-ring-color, var(--ring));
    outline-offset: var(--focus-ring-offset, 0px);
  }
}
```

### Step 3: Import in engine.css

```css
/* ----- 2. Composites ----- */
@import "../../stylesheets/alert.css";
/* ... */
@import "../../stylesheets/my_component.css";  /* after everything it overrides */
```

### Step 4: Create Documentation

See the documentation template in `component_template.md`. Docs escape ERB as `<%%= ... %>`.

## Compound Components

For complex components with multiple parts (like Card, Alert, Sidebar):

### Directory Structure

```
app/views/components/
├── _card.html.erb           # Main wrapper
└── card/
    ├── _header.html.erb     # CardHeader
    ├── _title.html.erb      # CardTitle
    ├── _description.html.erb # CardDescription
    ├── _action.html.erb     # CardAction
    ├── _content.html.erb    # CardContent
    └── _footer.html.erb     # CardFooter
```

### Main Partial

```erb
<%# app/views/components/_card.html.erb %>
<%# locals: (css_classes: "", **html_options) %>
<% merged_data = merge_component_data(html_options, component: :card) %>

<%= content_tag :div, class: css_classes.presence, data: merged_data, **html_options do %>
  <%= yield %>
<% end %>
```

### Sub-Partial

```erb
<%# app/views/components/card/_header.html.erb %>
<%# locals: (layout: :column, css_classes: "", **html_options) %>
<% merged_data = merge_component_data(html_options,
    card_part: :header,
    layout: (layout.to_sym == :row ? :row : nil)
  ).compact %>

<%= content_tag :div, class: css_classes.presence, data: merged_data, **html_options do %>
  <%= yield %>
<% end %>
```

### CSS for Parts

```css
@layer components {
  [data-component="card"] {
    @apply border;
    border-radius: var(--card-radius, var(--surface-radius, 0.5rem));
    box-shadow: var(--card-shadow, var(--elevation-raised, var(--shadow-sm)));
    background-color: var(--card);
    color: var(--card-foreground);
  }

  :where([data-component="card"]) [data-card-part="header"] {
    display: flex;
    flex-direction: column;
    @apply gap-1.5 p-6;
  }

  :where([data-component="card"]) [data-card-part="header"]:where([data-layout="row"]) {
    flex-direction: row;
    align-items: center;
    justify-content: space-between;
  }
}
```

### Usage

```erb
<%= render "components/card" do %>
  <%= render "components/card/header" do %>
    <%= render "components/card/title", text: "Account Settings" %>
    <%= render "components/card/description", text: "Manage your account preferences" %>
  <% end %>
  <%= render "components/card/content" do %>
    <!-- Form fields -->
  <% end %>
  <%= render "components/card/footer" do %>
    <%= button_to "Save", settings_path, data: { component: "button", variant: "primary" } %>
  <% end %>
<% end %>
```

## Test/Dummy Application

The `test/dummy` directory contains a Rails application for:
- Previewing every component (`/previews/<component>/<example>`, embedded by the docs site)
- Theme switching: color themes (`data-theme` on `<html>`), dark mode (`.dark`), and shape themes (`data-shape-theme="brutal|soft"`, or `?shape_theme=` on preview URLs)
- Running the engine's test suite

### Running Locally

```bash
cd test/dummy
bin/rails server
```

### Running Tests

Build the dummy app's CSS first — the stylesheet guards assert on the compiled output:

```bash
cd test/dummy && bin/rails tailwindcss:build && cd -
bin/test
```

To test against the pushed release branch instead of the source tree: `BUNDLE_GEMFILE=Gemfile.branch bin/test`.

## Theme Variables Reference

The host's theme (written by the installer) declares the shadcn palette. The engine's stylesheets may use these without a fallback (`BASE_PALETTE` in `test/stylesheets/css_conventions_test.rb`):

```css
:root {
  --background  --foreground
  --card  --card-foreground
  --popover  --popover-foreground
  --primary  --primary-foreground
  --secondary  --secondary-foreground
  --muted  --muted-foreground
  --accent  --accent-foreground
  --destructive  --destructive-foreground
  --border  --input  --ring
  --sidebar  --sidebar-foreground
  --sidebar-primary  --sidebar-primary-foreground
  --sidebar-accent  --sidebar-accent-foreground
  --sidebar-border  --sidebar-ring
  --sidebar-width  --sidebar-width-icon  --header-height
}
```

Everything else (`--success`, `--warning`, `--info`, hover tokens, shape/focus/elevation tokens) must be read with a fallback. See `theme_variables.md` for values, `@theme` bindings and the token layer.

## Dark Mode

Dark mode is the `dark` class on `<html>`. The host defines a **top-level** `.dark` block (never nested inside `:root` — nested, it compiles to `:root .dark` and never matches `<html>`):

```css
.dark {
  --background: oklch(0.145 0 0);
  --foreground: oklch(0.985 0 0);
  /* ... other dark values */
}
```

Components adapt because they reference CSS variables. Component stylesheets never contain `.dark` property overrides or `prefers-color-scheme` media queries; scheme-dependent defaults are tokens (`tokens.css`).
