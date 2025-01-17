# Maquina Components

Modern UI components for Ruby on Rails, powered by TailwindCSS and Stimulus

![Dashboard Example](/imgs/home.png)

![Form Example](/imgs/new.png)

## Overview

Maquina Components provides a collection of ready-to-use UI components for Ruby on Rails applications. Built with ERB,
TailwindCSS 4.0, and Stimulus, it offers a modern and maintainable approach to building beautiful user interfaces
without the complexity of JavaScript frameworks.

### Key Features

- 🎨 Pre-built UI components based on shadcn/ui design system
- ⚡️ Powered by TailwindCSS 4.0
- 🧩 Seamless Rails integration with ERB partials
- 📱 Fully responsive components
- 🎯 Interactive behaviors with Stimulus controllers
- 🌙 Dark mode support out of the box
- ♿️ Accessibility-first components

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'maquina-components'
```

Then execute:

```bash
bundle install
```

### Setup

1. Install TailwindCSS 4.0 in your Rails application
2. Add the required Stimulus controllers to your application
3. Use Shadcn/UI standard color variables:

```css
/* app/assets/stylesheets/application.css */

@theme {
  /* Default background color of <body />...etc */
  --color-background: var(--background);
  --color-foreground: var(--foreground);

  /* Primary colors for Button */
  --color-primary: var(--primary-color);
  --color-primary-foreground: var(--primary-foreground-color);

  /* Muted colors */
  --color-muted: var(--muted);
  --color-muted-foreground: var(--muted-foreground);

  /* Secondary colors */
  --color-secondary: var(--secondary);
  --color-secondary-foreground: var(--secondary-foreground);

  /* Accent colors */
  --color-accent: var(--accent);
  --color-accent-foreground: var(--accent-foreground);

  /* Destructive colors */
  --color-destructive: var(--destructive);
  --color-destructive-foreground: var(--destructive-foreground);

  /* Default input color */
  --color-input: var(--input);

  /* Default border color */
  --color-border: var(--border);

  /* Default ring color */
  --color-ring: var(--ring);
  --color-ring-destructive: var(--destructive);

  /* Background color for Card */
  --color-card: var(--card);
  --color-card-foreground: var(--card-foreground);

  /* Sidebar colors */
  --color-sidebar: var(--sidebar-background);
  --color-sidebar-foreground: var(--sidebar-foreground);

  --color-sidebar-primary: var(--sidebar-primary);
  --color-sidebar-primary-foreground: var(--sidebar-primary-foreground);

  --color-sidebar-accent: var(--sidebar-accent);
  --color-sidebar-accent-foreground: var(--sidebar-accent-foreground);

  --color-sidebar-ring: var(--sidebar-ring);
  --color-sidebar-border: var(--sidebar-border);
}
```

## Usage

### Basic Layout Example

```erb
<%# app/views/layouts/application.html.erb %>
<body class="bg-background text-primary font-display antialiased">
  <div class="flex min-h-screen">
    <%= render "components/sidebar" do %>
      <%= render "components/sidebar_header" do %>
        <%= render "shared/ui/menu_button",
          title: "My App",
          subtitle: "Dashboard",
          text_icon: "MA" %>
      <% end %>

      <%= render "components/sidebar_content" do %>
        <!-- Sidebar content here -->
      <% end %>
    <% end %>

    <main class="flex-1 pl-(--sidebar-width)">
      <%= yield %>
    </main>
  </div>
</body>
```

### Components

#### Cards

```erb
<%= render "components/card" do %>
  <%= render "components/card_header",
    title: "Account Balance",
    icon: :dollar %>

  <%= render "components/card_content" do %>
    <p class="text-2xl font-bold">
      <%= number_to_currency(@balance) %>
    </p>
    <p class="text-xs text-muted-foreground">
      Current balance
    </p>
  <% end %>
<% end %>
```

#### Buttons

```erb
<%= link_to new_transaction_path, class: "button-primary" do %>
  New Transaction
  <%= icon_for(:money) %>
<% end %>
```

## Available Components

Work in progress...

- Layout
  - Sidebar
  - Card
- Navigation
  - Menu Button
  - Navigation Menu
- Elements
  - Button
  - Alert
  - Badge
- Forms
  - Input
  - Select
  - Checkbox
  - Radio

## Customization

### Theme Configuration

Customize the look and feel of your components by modifying the theme variables:

```css
@theme {
  /* Colors */
  --color-primary: oklch(21.34% 0 0);
  --color-primary-foreground: oklch(98.48% 0 0);

  /* Typography */
  --font-display: "Inter var", "sans-serif";

  /* Spacing */
  --sidebar-width: 16rem;

  /* ... other customizations ... */
}
```

## Contributing

Bug reports and pull requests are welcome on GitHub at <https://github.com/maquina-app/maquina_components>.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Acknowledgments

- Design system inspired by [shadcn/ui](https://ui.shadcn.com/)
- Built with [TailwindCSS](https://tailwindcss.com/)
- Powered by [Ruby on Rails](https://rubyonrails.org/)
