# Maquina Components

UI components for Ruby on Rails, built with ERB, TailwindCSS 4.0, and Stimulus.

> [!IMPORTANT]
> **0.6.0 has breaking changes.** Engine CSS moved into `@layer components`,
> which changes what wins in your app. Most notably, the `* { border-color }`
> shim in the `theme.css` you already installed must be wrapped in
> `@layer base` — unlayered, it now outranks every engine rule and flattens
> the tinted alert, toast and badge borders. That one affects every existing
> app and fails silently.
>
> Before upgrading, read [docs/upgrading.md](docs/upgrading.md). After
> upgrading, run `bin/rails maquina:doctor` — it prints file:line for every
> pattern the release changes and never edits anything. An appendix in the
> upgrading guide restores the 0.5.1 look with one token block.

---

## Why This Exists

I started building components inspired by [shadcn/ui](https://ui.shadcn.com/) for production Rails applications—mainly dashboards and admin interfaces. Over time, I iterated on these components across multiple projects, and they became inconsistent: different APIs, different styling approaches, different levels of completeness.

It was time to extract the elements I use most and give them a **cohesive API and consistent styling**.

### The Technical Choices

I chose **ERB partials** with **TailwindCSS** and **Stimulus controllers** for interactive elements. For static components like form inputs, pure CSS with data attributes is enough.

I'm aware of alternatives like [ViewComponent](https://viewcomponent.org/) and [Phlex](https://www.phlex.fun/). The projects I extracted these components from didn't use them. I see the benefits of using a Ruby class to render the UI, but bringing in any of these libraries into a project is a big commitment, and not all projects and teams are open to doing it. The reason is not technical; it is the feeling of moving away from "the Rails way." So I kept it simple: ERB partials that any Rails developer can understand immediately.

### Composability Over Convenience

These components are built to be **composable**. They are built of many small ERB partials to render. But that's intentional—you can take these partials and compose them into larger, application-specific components. There are no limits, and you have a standard API to guide you.

I didn't copy shadcn/ui one-to-one. I extracted only the components I actually use in my applications. This is a practical toolkit, not a complete port.

### One Approach Among Many

There's no single UI kit that rules Rails development. If this approach doesn't resonate with you, here are excellent alternatives:

- [RailsUI](https://railsui.com) — Premium UI templates and components
- [RailsBlocks](https://railsblocks.com) — Copy-paste components for Rails
- [shadcn-rails](https://shadcn.rails-components.com) — Another shadcn/ui port for Rails
- [Inertia Rails + shadcn Starter](https://evilmartians.com/opensource/inertia-rails-shadcn-starter) — React/Vue components with Inertia

If you're open to trying maquina_components and providing feedback, you're welcome to do so. If this isn't for you, that's okay too.

---

## Features

- **ERB partials** with strict locals (`locals:` magic comments)
- **TailwindCSS 4.0** with CSS custom properties for theming
- **Data attributes** (`data-component`, `data-*-part`) for CSS styling
- **Stimulus controllers** only used where interactivity is needed
- **Dark mode** support via CSS variables
- **shadcn/ui theming** convention (works with their color system)
- **Design tokens** for shape, focus rings, elevation and weight — [theming guide](docs/theming.md)
- **Composable** — small partials you can combine freely

![Test dummy app with light mode](/imgs/light.png)

![Test dummy app with dark mode](/imgs/dark.png)

---

## Quick Start

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
- Add theme variables (light + dark mode)
- Create a helper file for icon customization

All engine helpers (`icon_for`, `sidebar_open?`, `toast_flash_messages`, etc.) are automatically available in your views without any additional configuration.

### 3. Use Components

```erb
<%= render "components/card" do %>
  <%= render "components/card/header" do %>
    <%= render "components/card/title", text: "Account Settings" %>
    <%= render "components/card/description", text: "Manage your preferences" %>
  <% end %>
  <%= render "components/card/content" do %>
    <!-- Your content -->
  <% end %>
<% end %>
```

For form elements, use data attributes with Rails helpers:

```erb
<%= form_with model: @user do |f| %>
  <%= f.text_field :name, data: { component: "input" } %>
  <%= f.email_field :email, data: { component: "input" } %>
  <%= f.submit "Save", data: { component: "button", variant: "primary" } %>
<% end %>
```

**[Full Getting Started Guide](https://maquina.app/documentation/components/)**

---

## Generator Options

```bash
# Default: adds everything
bin/rails generate maquina_components:install

# Skip theme variables (if you have your own)
bin/rails generate maquina_components:install --skip-theme

# Skip helper file
bin/rails generate maquina_components:install --skip-helper
```

### Scaffold Templates

Copy ERB scaffold templates into your application so Rails' built-in `scaffold`
generator produces maquina_components-styled views:

```bash
bin/rails generate maquina_components:scaffold_templates
```

This installs `index`, `show`, `new`, `edit`, `_form`, and partial templates to
`lib/templates/erb/scaffold/`. After running it, `rails generate scaffold ModelName field:type`
generates views built with maquina_components. Customize the templates as needed.

**Prerequisite:** [tailwindcss-rails](https://github.com/rails/tailwindcss-rails) must be installed first.

---

## Upgrading

**0.5.1 → 0.6.0 is a breaking upgrade** — see the note at the top of this
README and [docs/upgrading.md](docs/upgrading.md) for the seven changes, each
with measurements, plus an appendix that reverts every visual change with one
token block.

Re-running the install generator is safe — it is idempotent and never rewrites
your palette. After upgrading, run the doctor:

```bash
bin/rails maquina:doctor
```

It scans your CSS, views and JavaScript and prints file:line for every pattern
the new release changes, grouped `BREAKING` / `REVIEW` / `CLEANUP`. It is
advisory: it never edits anything and never fails a build. See
[docs/upgrading.md](docs/upgrading.md) for what changed and how to keep the
previous look.

---

## Available Components

### Layout Components

| Component | Description | Documentation |
|-----------|-------------|---------------|
| **Sidebar** | Collapsible navigation with cookie persistence | [Sidebar](https://maquina.app/documentation/components/sidebar/) |
| **Header** | Top navigation bar | [Header](https://maquina.app/documentation/components/header/) |

### Content Components

| Component | Description | Documentation |
|-----------|-------------|---------------|
| **Card** | Content container with header, content, footer | [Card](https://maquina.app/documentation/components/card/) |
| **Alert** | Callout messages (info, warning, error) | [Alert](https://maquina.app/documentation/components/alert/) |
| **Badge** | Status indicators and labels | [Badge](https://maquina.app/documentation/components/badge/) |
| **Table** | Data tables with striped and bordered variants | [Table](https://maquina.app/documentation/components/table/) |
| **Separator** | Horizontal or vertical divider | [Separator](https://maquina.app/documentation/components/separator/) |
| **Empty State** | Placeholder for empty lists | [Empty State](https://maquina.app/documentation/components/empty/) |
| **Stats** | Metric cards in a responsive grid | [Stats](https://maquina.app/documentation/components/stats/) |

### Navigation Components

| Component | Description | Documentation |
|-----------|-------------|---------------|
| **Breadcrumbs** | Navigation trail with overflow handling | [Breadcrumbs](https://maquina.app/documentation/components/breadcrumbs/) |
| **Dropdown Menu** | Accessible dropdown with keyboard navigation | [Dropdown Menu](https://maquina.app/documentation/components/dropdown-menu/) |
| **Pagination** | Page navigation with Pagy integration | [Pagination](https://maquina.app/documentation/components/pagination/) |

### Interactive Components

| Component | Description | Documentation |
|-----------|-------------|---------------|
| **Calendar** | Inline date picker with single/range selection | [Calendar](https://maquina.app/documentation/components/calendar/) |
| **Combobox** | Searchable dropdown with keyboard navigation | [Combobox](https://maquina.app/documentation/components/combobox/) |
| **Date Picker** | Popover-based date selection | [Date Picker](https://maquina.app/documentation/components/date-picker/) |
| **Drawer** | Slide-out panel with overlay and keyboard shortcut | [Drawer](https://maquina.app/documentation/components/drawer/) |
| **Toggle Group** | Single/multiple selection button group | [Toggle Group](https://maquina.app/documentation/components/toggle-group/) |

### Feedback Components

| Component | Description | Documentation |
|-----------|-------------|---------------|
| **Toast** | Non-intrusive notifications with auto-dismiss | [Toast](https://maquina.app/documentation/components/toast/) |

### Form Components

| Component | Data Attribute | Variants |
|-----------|----------------|----------|
| **Button** | `data-component="button"` | default, primary, secondary, destructive, outline, ghost, link |
| **Input** | `data-component="input"` | — |
| **Textarea** | `data-component="textarea"` | — |
| **Select** | `data-component="select"` | — |
| **Checkbox** | `data-component="checkbox"` | — |
| **Radio** | `data-component="radio"` | — |
| **Switch** | `data-component="switch"` | — |

**[Form Components Guide](https://maquina.app/documentation/components/form/)**

---

## Examples

### Cards with Actions

```erb
<%= render "components/card" do %>
  <%= render "components/card/header", layout: :row do %>
    <div>
      <%= render "components/card/title", text: "Team Members" %>
      <%= render "components/card/description", text: "Manage your team" %>
    </div>
    <%= render "components/card/action" do %>
      <%= link_to "Add Member", new_member_path,
        data: { component: "button", variant: "primary", size: "sm" } %>
    <% end %>
  <% end %>
  <%= render "components/card/content" do %>
    <!-- Table or list -->
  <% end %>
<% end %>
```

### Alerts

```erb
<%= render "components/alert", variant: :destructive do %>
  <%= render "components/alert/title", text: "Error" %>
  <%= render "components/alert/description" do %>
    Your session has expired. Please log in again.
  <% end %>
<% end %>
```

### Badges

```erb
<%= render "components/badge", variant: :success do %>Active<% end %>
<%= render "components/badge", variant: :warning do %>Pending<% end %>
<%= render "components/badge", variant: :destructive do %>Failed<% end %>
```

### Toggle Group

```erb
<%= render "components/toggle_group", type: :single, variant: :outline do %>
  <%= render "components/toggle_group/item", value: "left", aria_label: "Align left" do %>
    <%= icon_for :align_left %>
  <% end %>
  <%= render "components/toggle_group/item", value: "center", aria_label: "Align center" do %>
    <%= icon_for :align_center %>
  <% end %>
  <%= render "components/toggle_group/item", value: "right", aria_label: "Align right" do %>
    <%= icon_for :align_right %>
  <% end %>
<% end %>
```

### Dropdown Menu

```erb
<%= render "components/dropdown_menu" do %>
  <%= render "components/dropdown_menu/trigger" do %>Options<% end %>
  <%= render "components/dropdown_menu/content" do %>
    <%= render "components/dropdown_menu/item", href: profile_path do %>
      <%= icon_for :user %>
      Profile
    <% end %>
    <%= render "components/dropdown_menu/separator" %>
    <%= render "components/dropdown_menu/item", href: logout_path, method: :delete, variant: :destructive do %>
      <%= icon_for :log_out %>
      Logout
    <% end %>
  <% end %>
<% end %>
```

### Pagination

```erb
<%= pagination_nav(@pagy, :users_path) %>
```

### Combobox

```erb
<%= render "components/combobox", placeholder: "Select framework..." do |combobox_id| %>
  <%= render "components/combobox/trigger", for_id: combobox_id, placeholder: "Select framework..." %>
  <%= render "components/combobox/content", id: combobox_id do %>
    <%= render "components/combobox/input", placeholder: "Search..." %>
    <%= render "components/combobox/list" do %>
      <%= render "components/combobox/option", value: "rails" do %>Ruby on Rails<% end %>
      <%= render "components/combobox/option", value: "hanami" do %>Hanami<% end %>
      <%= render "components/combobox/option", value: "sinatra" do %>Sinatra<% end %>
    <% end %>
    <%= render "components/combobox/empty" %>
  <% end %>
<% end %>
```

### Toast Notifications

```erb
<%# Add toaster to your layout %>
<%= render "components/toaster", position: :bottom_right do %>
  <%= toast_flash_messages %>
<% end %>

<%# In your controller %>
flash[:success] = "Changes saved successfully!"

<%# Or use the JavaScript API %>
<script>
  Toast.success("Profile updated!")
  Toast.error("Something went wrong", { description: "Please try again." })
</script>
```

### Tables

```erb
<%= render "components/table" do %>
  <%= render "components/table/header" do %>
    <%= render "components/table/row" do %>
      <%= render "components/table/head" do %>Name<% end %>
      <%= render "components/table/head" do %>Email<% end %>
      <%= render "components/table/head" do %>Role<% end %>
    <% end %>
  <% end %>
  <%= render "components/table/body" do %>
    <% @users.each do |user| %>
      <%= render "components/table/row" do %>
        <%= render "components/table/cell" do %><%= user.name %><% end %>
        <%= render "components/table/cell" do %><%= user.email %><% end %>
        <%= render "components/table/cell" do %>
          <%= render "components/badge", variant: :outline do %><%= user.role %><% end %>
        <% end %>
      <% end %>
    <% end %>
  <% end %>
<% end %>
```

### Sidebar Layout

```erb
<%= render "components/sidebar/provider", default_open: app_sidebar_open? do %>
  <%= render "components/sidebar" do %>
    <%= render "components/sidebar/header" do %>
      <span class="font-semibold">My App</span>
    <% end %>
    
    <%= render "components/sidebar/content" do %>
      <%= render "components/sidebar/group", title: "Navigation" do %>
        <%= render "components/sidebar/menu" do %>
          <%= render "components/sidebar/menu_item" do %>
            <%= render "components/sidebar/menu_button",
              title: "Dashboard",
              url: dashboard_path,
              icon_name: :home,
              active: current_page?(dashboard_path) %>
          <% end %>
        <% end %>
      <% end %>
    <% end %>
  <% end %>

  <%= render "components/sidebar/inset" do %>
    <%= render "components/header" do %>
      <%= render "components/sidebar/trigger", icon_name: :panel_left %>
    <% end %>
    
    <main class="flex-1 p-6">
      <%= yield %>
    </main>
  <% end %>
<% end %>
```

---

## Theming

Components use CSS variables following the [shadcn/ui theming convention](https://ui.shadcn.com/docs/theming).

Colors are not the only variables: shape, focus rings, elevation and weight are
design tokens too, so reshaping the whole library is a short list of
declarations rather than override CSS fighting the cascade.

```css
:root {
  --control-radius: 0;   /* buttons, inputs, badges, menu items */
  --surface-radius: 0;   /* cards, popovers, toasts, alerts */
  --elevation-raised: none;
}
```

**[Theming guide](docs/theming.md)** — the full token list, flat and brutalist
themes in a dozen lines each, recoloring the control marks, dark mode, and how
to pin a single component without redefining a role.

The install generator adds default theme variables. Customize them in `app/assets/tailwind/application.css`:

```css
:root {
  /* Change primary to blue */
  --primary: oklch(0.488 0.243 264.376);
  --primary-foreground: oklch(0.985 0 0);
  
  /* Add custom colors */
  --success: oklch(0.6 0.2 145);
  --success-foreground: oklch(0.985 0 0);
}

@theme {
  --color-success: var(--success);
  --color-success-foreground: var(--success-foreground);
}
```

---

## Helper Methods

| Helper | Purpose |
|--------|---------|
| `icon_for(name, options)` | Render an SVG icon |
| `sidebar_state(cookie_name)` | Get sidebar state (`:expanded` or `:collapsed`) |
| `sidebar_open?(cookie_name)` | Check if the sidebar is expanded |
| `pagination_nav(pagy, route)` | Render pagination from Pagy object |
| `pagination_simple(pagy, route)` | Render simple Previous/Next pagination |
| `toast_flash_messages` | Render all flash messages as toasts |
| `toast(variant, title, **options)` | Render a single toast notification |
| `combobox(placeholder:, **options, &block)` | Builder pattern for combobox |
| `combobox_simple(options:, **options)` | Data-driven simple combobox |

---

## Documentation

### Getting Started

- **[Getting Started](https://maquina.app/documentation/components/)** — Installation and setup

### Layout

- **[Sidebar](https://maquina.app/documentation/components/sidebar/)** — Navigation sidebar
- **[Header](https://maquina.app/documentation/components/header/)** — Top navigation bar

### Content

- **[Card](https://maquina.app/documentation/components/card/)** — Content containers
- **[Alert](https://maquina.app/documentation/components/alert/)** — Callout messages
- **[Badge](https://maquina.app/documentation/components/badge/)** — Status indicators
- **[Table](https://maquina.app/documentation/components/table/)** — Data tables
- **[Empty State](https://maquina.app/documentation/components/empty/)** — Empty state placeholders

### Navigation

- **[Breadcrumbs](https://maquina.app/documentation/components/breadcrumbs/)** — Navigation trails
- **[Dropdown Menu](https://maquina.app/documentation/components/dropdown-menu/)** — Dropdown menus
- **[Pagination](https://maquina.app/documentation/components/pagination/)** — Page navigation

### Interactive

- **[Calendar](https://maquina.app/documentation/components/calendar/)** — Inline date picker
- **[Combobox](https://maquina.app/documentation/components/combobox/)** — Searchable dropdown selection
- **[Date Picker](https://maquina.app/documentation/components/date-picker/)** — Popover date selection
- **[Toggle Group](https://maquina.app/documentation/components/toggle-group/)** — Toggle button groups

### Feedback

- **[Toast](https://maquina.app/documentation/components/toast/)** — Toast notifications

### Forms

- **[Form Components](https://maquina.app/documentation/components/form/)** — Buttons, inputs, and form styling

---

## Development

Run the dummy app:

```bash
cd test/dummy
bin/rails server
```

Run tests (build the dummy app's CSS first — the stylesheet guards assert on the
compiled output):

```bash
cd test/dummy && bin/rails tailwindcss:build && cd -
bin/test
```

### Running against the published branch

Both commands above run against the source tree. To exercise the gem the way a
consuming app resolves it — from GitHub rather than from `lib/` and `app/` —
use `Gemfile.branch`:

```bash
BUNDLE_GEMFILE=Gemfile.branch bundle install
BUNDLE_GEMFILE=Gemfile.branch bin/test

# or drive the app by hand
cd test/dummy
BUNDLE_GEMFILE=../../Gemfile.branch bin/rails tailwindcss:build
BUNDLE_GEMFILE=../../Gemfile.branch bin/rails server
```

It defaults to the current release branch; override with `MAQUINA_BRANCH`.

`test/dummy/config/boot.rb` skips its `$LOAD_PATH` unshift under
`Gemfile.branch`, so the source tree cannot shadow the resolved gem — without
that the check would pass no matter what was on the branch. `Gemfile.common`
holds the app gems both Gemfiles share, so the two cannot drift.

Two limits worth knowing. It resolves the **pushed** commit, so local work you
have not pushed is not what you are testing — `bundle list | grep maquina`
prints the SHA. And Bundler resolves a git source from a checkout, so every
file is present whether or not `spec.files` lists it: this catches a bad
dependency or a broken require path, but a file missing from the packaged gem
stays invisible. For that, build the gem and install what comes out:

```bash
gem build maquina-components.gemspec
gem contents --show-install-dir maquina-components   # after installing it
```

Worth confirming either way: `bin/rails -T | grep maquina` (the rake task
ships), `bin/rails generate --help` (the generators are found), and that the
previews render — those exercise `lib/tasks`, `lib/generators/**/templates` and
`app/**`, which are the parts a packaging mistake tends to drop.

---

## Claude Code Skill

This repository includes a Claude Code skill that teaches Claude how to build consistent, accessible UIs using maquina_components. The skill provides:

- **Component catalog** — Complete reference for all components with ERB examples
- **Form patterns** — Validation, error handling, and complex form structures
- **Layout patterns** — Sidebar navigation, page structure, responsive design
- **Turbo integration** — Turbo Frames, Streams, and component updates
- **Spec checklist** — Review criteria for UI implementation quality

### Installation

Copy the `skill/` directory to your Rails project:

```bash
cp -r /path/to/maquina_components/skill .claude/skills/maquina-ui-standards
```

See the [Skill README](skill/README.md) for detailed installation and usage instructions.

---

## Contributing

Bug reports and pull requests are welcome on GitHub at [github.com/maquina-app/maquina_components](https://github.com/maquina-app/maquina_components).

---

## License

Copyright (c) [Mario Alberto Chávez Cárdenas](https://mariochavez.io)

The gem is available as open source under the terms of the [MIT License](MIT-LICENSE).

---

## Credits

- Design patterns from [shadcn/ui](https://ui.shadcn.com/)
- Built with [TailwindCSS](https://tailwindcss.com/)
- Powered by [Ruby on Rails](https://rubyonrails.org/)
