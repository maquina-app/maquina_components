# New Component Template

> Copy-paste templates for creating new components in maquina_components.

## Quick Start Checklist

- [ ] Create ERB partial: `app/views/components/_{component}.html.erb` (+ `app/views/components/{component}/` for parts)
- [ ] Create CSS file: `app/assets/stylesheets/{component}.css` (everything inside `@layer components`)
- [ ] Import CSS in `app/assets/tailwind/maquina_components_engine/engine.css` — in the right group, after anything it overrides
- [ ] Create documentation: `docs/{component}.md`
- [ ] Create previews: `test/dummy/app/views/previews/{component}/{example}.html.erb` for each `<!-- preview:NAME height:N -->` tag
- [ ] (Optional) Helper: `app/helpers/maquina_components/{component}_helper.rb`
- [ ] (Optional) Stimulus: `app/javascript/controllers/{component}_controller.js`
- [ ] Run the guards: `cd test/dummy && bin/rails tailwindcss:build && cd - && bin/test`

Naming: `{component}` is snake_case in file names and kebab-case in `data-component` values (`toggle_group.css` / `data-component="toggle-group"`).

---

## ERB Partial Template

### Simple Component

```erb
<%# app/views/components/_{component}.html.erb %>
<%# locals: (variant: :default, size: :md, css_classes: "", **html_options) %>
<% merged_data = merge_component_data(html_options,
    component: "{component}",
    variant: variant,
    size: size
  ) %>

<%= content_tag :div, class: css_classes.presence, data: merged_data, **html_options do %>
  <%= yield %>
<% end %>
```

### Leaf Part (text, content or block)

```erb
<%# app/views/components/{component}/_title.html.erb %>
<%# locals: (text: nil, content: nil, css_classes: "", **html_options) %>
<% merged_data = merge_component_data(html_options, "{component}-part": :title) %>

<%= content_tag :div, class: css_classes.presence, data: merged_data, **html_options do %>
  <%= text.presence || content || yield %>
<% end %>
```

For a single-word component a symbol key works too: `card_part: :title` → `data-card-part="title"`.

### With Required Parameter

```erb
<%# app/views/components/_{component}.html.erb %>
<%# locals: (title:, description: nil, variant: :default, css_classes: "", **html_options) %>
<% merged_data = merge_component_data(html_options,
    component: "{component}",
    variant: variant
  ) %>

<%= content_tag :div, class: css_classes.presence, data: merged_data, **html_options do %>
  <div data-{component}-part="title"><%= title %></div>
  <% if description.present? %>
    <p data-{component}-part="description"><%= description %></p>
  <% end %>
  <%= yield %>
<% end %>
```

### With Disabled State and an Optional Flag

```erb
<%# app/views/components/_{component}.html.erb %>
<%# locals: (variant: :default, size: :md, disabled: false, pressed: false, css_classes: "", **html_options) %>
<% merged_data = merge_component_data(html_options,
    component: "{component}",
    variant: variant,
    size: size,
    state: (pressed ? :on : :off)
  ) %>

<%= content_tag :button,
      type: :button,
      disabled: (disabled || nil),
      aria: { pressed: pressed.to_s },
      class: css_classes.presence,
      data: merged_data,
      **html_options do %>
  <%= yield %>
<% end %>
```

Pass `nil` (not `false`) for a data attribute that should be absent — `merge_component_data` drops `nil` values.

### With a Stimulus Controller

```erb
<%# locals: (open: false, css_classes: "", **html_options) %>
<% merged_data = merge_component_data(html_options,
    component: "{component}",
    controller: "{component}",
    "{component}-open-value": open
  ) %>
```

`controller:` and `action:` concatenate with any the caller passes.

---

## CSS Template

```css
/* app/assets/stylesheets/{component}.css */

/* ===== {ComponentName} Component Styles ===== */
/*
 * {Brief description of the component}
 *
 * Cascade order in this file (full contract documented in form.css):
 *   1. base      [data-component="{component}"], [data-{component}-part="…"]
 *   2. sizes     [data-component="{component}"]:where([data-size="…"])
 *   3. variants  [data-component="{component}"]:where([data-variant="…"])
 *   4. states    :where(:hover, :focus-visible, :active, :disabled)
 *   5. dark      — none; dark-mode differences are tokens (see tokens.css)
 * Every rule is flattened to 0,1,0 with :where() and lives in
 * @layer components, so a caller's utility class wins and source order is
 * the only tie-breaker. (Rules whose target is a bare element or a
 * pseudo-element read 0,1,1 — an element selector cannot be zeroed away.)
 */

@layer components {
  /* ===== Base Styles ===== */
  [data-component="{component}"] {
    /* Layout */
    display: inline-flex;
    align-items: center;

    /* Spacing & Typography via @apply */
    @apply gap-2 text-sm border border-transparent;
    font-weight: var(--label-weight, 500);

    /* Shape: component escape hatch → role token → literal */
    border-radius: var(--{component}-radius, var(--control-radius, 0.375rem));

    /* Transitions: name the properties (transition-colors includes outline-color) */
    @apply transition-[color,background-color,border-color] duration-150;
  }

  /* ===== Parts ===== */
  :where([data-component="{component}"]) [data-{component}-part="title"] {
    @apply leading-none tracking-tight;
    font-weight: var(--label-weight, 500);
  }

  /* ===== Icon Support ===== */
  [data-component="{component}"] svg {
    width: 1em;
    height: 1em;
    @apply shrink-0 pointer-events-none;
  }

  /* ===== Size Variants ===== */
  [data-component="{component}"]:where([data-size="sm"]) {
    @apply text-xs px-2 py-0.5 h-7;
  }

  [data-component="{component}"]:where([data-size="md"]) {
    @apply text-sm px-3 py-1.5 h-9;
  }

  [data-component="{component}"]:where([data-size="lg"]) {
    @apply text-base px-4 py-2 h-11;
  }

  [data-component="{component}"]:where([data-size="icon"]) {
    @apply p-0 size-9;
  }

  /* ===== Visual Variants ===== */
  [data-component="{component}"]:where([data-variant="default"]) {
    background-color: var(--secondary);
    color: var(--secondary-foreground);
  }

  [data-component="{component}"]:where([data-variant="primary"]) {
    background-color: var(--primary);
    color: var(--primary-foreground);
    box-shadow: var(--elevation-raised, var(--shadow-sm, 0 1px 2px 0 rgb(0 0 0 / 0.05)));
  }

  [data-component="{component}"]:where([data-variant="destructive"]) {
    background-color: var(--destructive);
    color: var(--destructive-foreground);
  }

  [data-component="{component}"]:where([data-variant="success"]) {
    /* Not in the base palette: always give a fallback */
    background-color: var(--success, oklch(0.627 0.194 149.214));
    color: var(--success-foreground, oklch(0.985 0 0));
  }

  [data-component="{component}"]:where([data-variant="outline"]) {
    background-color: transparent;
    color: var(--foreground);
    border-color: var(--border);
  }

  [data-component="{component}"]:where([data-variant="ghost"]) {
    background-color: transparent;
    color: var(--foreground);
    box-shadow: var(--elevation-none, none);
  }

  /* ===== States (always after the variants) ===== */
  [data-component="{component}"]:where([data-variant="default"]:hover) {
    background-color: var(--secondary-hover, color-mix(in oklch, var(--secondary) 80%, black));
  }

  [data-component="{component}"]:where([data-variant="primary"]:hover) {
    background-color: var(--primary-hover, color-mix(in oklch, var(--primary) 90%, black));
  }

  [data-component="{component}"]:where([data-variant="outline"]:hover, [data-variant="ghost"]:hover) {
    background-color: var(--accent-hover, var(--accent));
    color: var(--accent-foreground);
  }

  [data-component="{component}"]:where(:focus-visible) {
    outline-width: var(--focus-ring-width, 3px);
    outline-style: var(--focus-ring-style, solid);
    outline-color: var(--focus-ring-color, var(--ring));
    outline-offset: var(--focus-ring-offset, 0px);
  }

  [data-component="{component}"]:where([data-variant="destructive"]:focus-visible) {
    --focus-ring-color: var(--destructive);
  }

  [data-component="{component}"]:where(:disabled, [aria-disabled="true"]) {
    @apply opacity-50 cursor-not-allowed pointer-events-none;
  }

  /* Dynamic state from Stimulus */
  [data-component="{component}"]:where([data-state="on"]) {
    background-color: var(--accent);
    color: var(--accent-foreground);
  }
}

/* Outside the layer: @keyframes are not cascade participants. */
@keyframes {component}-in {
  from { opacity: 0; transform: translateY(-4px); }
  to   { opacity: 1; transform: translateY(0); }
}
```

Never add `.dark` property rules or `@media (prefers-color-scheme)` — add a token instead.

---

## Documentation Template

Docs in `docs/` are rendered through ERB by the docs site, so ERB in code blocks is escaped as `<%%= … %>` / `<%% … %>`. Each `<!-- preview:NAME height:N -->` tag becomes a live iframe of `test/dummy/app/views/previews/{component}/NAME.html.erb`; `test/integration/docs_previews_contract_test.rb` fails if the preview is missing or the height is absent.

```markdown
# {Component Name}

> {One-line description of the component.}

<!-- preview:default height:120 -->

## Usage

\`\`\`erb
<%%= render "components/{component}" do %>
  Content here
<%% end %>
\`\`\`

## Examples

### Variants

<!-- preview:variants height:80 -->

\`\`\`erb
<%%= render "components/{component}", variant: :primary do %>Primary<%% end %>
<%%= render "components/{component}", variant: :secondary do %>Secondary<%% end %>
<%%= render "components/{component}", variant: :destructive do %>Destructive<%% end %>
<%%= render "components/{component}", variant: :outline do %>Outline<%% end %>
<%%= render "components/{component}", variant: :ghost do %>Ghost<%% end %>
\`\`\`

### Sizes

<!-- preview:sizes height:80 -->

\`\`\`erb
<%%= render "components/{component}", size: :sm do %>Small<%% end %>
<%%= render "components/{component}", size: :md do %>Medium<%% end %>
<%%= render "components/{component}", size: :lg do %>Large<%% end %>
\`\`\`

### With Icons

<!-- preview:with_icons height:80 -->

\`\`\`erb
<%%= render "components/{component}", variant: :primary do %>
  <%%= icon_for :check, class: "size-4" %>
  With Icon
<%% end %>
\`\`\`

### With Custom Attributes

\`\`\`erb
<%%= render "components/{component}",
  id: "my-{component}",
  css_classes: "w-full",
  data: { controller: "tooltip" } do %>
  Custom
<%% end %>
\`\`\`

## Accessibility

- {Semantic element / role}
- {Keyboard behavior}
- {aria attributes the component sets}

## API Reference

### {Component Name}

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| variant | Symbol | :default | :default, :primary, :secondary, :destructive, :outline, :ghost |
| size | Symbol | :md | :sm, :md, :lg |
| css_classes | String | "" | Additional CSS classes |
| html_options | Hash | {} | Additional HTML attributes |

### {Component Name} Title

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| text | String | nil | Title text (or pass `content:` or a block) |
| css_classes | String | "" | Additional CSS classes |
```

Theming tokens a component adds (e.g. a new `--{component}-radius` escape hatch) are documented in `docs/theming.md`, not in the component page.

---

## Preview Template

```erb
<%# test/dummy/app/views/previews/{component}/default.html.erb %>
<%= render "components/{component}" do %>
  Content here
<% end %>
```

---

## Import in engine.css

After creating CSS, add the import to `app/assets/tailwind/maquina_components_engine/engine.css`. **Do not alphabetize** — put it in the matching group and after every file it overrides (e.g. anything whose parts carry `data-component="button"` goes after `form.css`):

```css
@import "./tokens.css";

@source "../../../views/";

/* ----- 1. Primitives ----- */
@import "../../stylesheets/form.css";
/* ... */

/* ----- 2. Composites ----- */
@import "../../stylesheets/alert.css";
/* ... */
@import "../../stylesheets/{component}.css";  /* Add this */
```

---

## Helper Template (Optional)

```ruby
# app/helpers/maquina_components/{component}_helper.rb

module MaquinaComponents
  module {ComponentName}Helper
    # Renders a {component} with sensible defaults.
    #
    # @param title [String] Title text
    # @param variant [Symbol] Visual style
    # @return [ActiveSupport::SafeBuffer] Rendered HTML
    #
    # @example
    #   <%= {component}_simple "Hello", variant: :primary %>
    #
    def {component}_simple(title, variant: :default, **options)
      render "components/{component}", variant: variant, **options do
        title
      end
    end
  end
end
```

The engine is not isolated, so its `app/helpers` are on the host's helper path and every module is available in host views under Rails' default `include_all_helpers`. The installed `app/helpers/maquina_components_helper.rb` also includes the modules whose methods it overrides or re-exports.

---

## Stimulus Controller Template (Optional)

```javascript
// app/javascript/controllers/{component}_controller.js
// Identifier: "{component}" with underscores → dashes (toggle_group → toggle-group)

import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["trigger", "content"]
  static values = {
    open: { type: Boolean, default: false }
  }

  connect() {
    this.boundTeardown = this.teardown.bind(this)
    document.addEventListener("turbo:before-cache", this.boundTeardown)
  }

  disconnect() {
    document.removeEventListener("turbo:before-cache", this.boundTeardown)
  }

  toggle(event) {
    event?.preventDefault()
    this.openValue = !this.openValue
  }

  openValueChanged() {
    const state = this.openValue ? "open" : "closed"
    this.element.dataset.state = state

    if (this.hasContentTarget) {
      this.contentTarget.dataset.state = state
      this.contentTarget.hidden = !this.openValue
    }
    if (this.hasTriggerTarget) {
      this.triggerTarget.setAttribute("aria-expanded", String(this.openValue))
    }

    this.dispatch("change", { detail: { open: this.openValue } }) // "{component}:change"
  }

  teardown() {
    this.openValue = false
  }
}
```

The engine's `config/importmap.rb` pins every file in `app/javascript/controllers/`, so a new controller needs no extra registration in importmap hosts.
