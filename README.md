# Maquina Components

UI components for Ruby on Rails, built with ERB, TailwindCSS 4.0, and Stimulus.

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

**Prerequisite:** [tailwindcss-rails](https://github.com/rails/tailwindcss-rails) must be installed first.

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
| **Table** | Data tables with sorting support | [Table](https://maquina.app/documentation/components/table/) |
| **Empty State** | Placeholder for empty lists | [Empty State](https://maquina.app/documentation/components/empty/) |

### Navigation Components

| Component | Description | Documentation |
|-----------|-------------|---------------|
| **Breadcrumbs** | Navigation trail with overflow handling | [Breadcrumbs](https://maquina.app/documentation/components/breadcrumbs/) |
| **Dropdown Menu** | Accessible dropdown with keyboard navigation | [Dropdown Menu](https://maquina.app/documentation/components/dropdown-menu/) |
| **Pagination** | Page navigation with Pagy integration | [Pagination](https://maquina.app/documentation/components/pagination/) |

### Interactive Components

| Component | Description | Documentation |
|-----------|-------------|---------------|
| **Toggle Group** | Single/multiple selection button group | [Toggle Group](https://maquina.app/documentation/components/toggle-group/) |

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

- **[Toggle Group](https://maquina.app/documentation/components/toggle-group/)** — Toggle button groups

### Forms

- **[Form Components](https://maquina.app/documentation/components/form/)** — Buttons, inputs, and form styling

---

## Development

Run the dummy app:

```bash
cd test/dummy
bin/rails server
```

Run tests:

```bash
bin/rails test
```

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
