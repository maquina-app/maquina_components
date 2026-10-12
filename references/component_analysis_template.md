# Component Analysis Template

> Use this template when analyzing, updating, or creating components in maquina_components.

## Task

Analyze and document the `{COMPONENT_NAME}` component for the maquina_components library.

## Context

This is a Rails component library that ports shadcn/ui components using:
- ERB partials with strict locals, merging `data:` through `merge_component_data`
- Data attributes for styling (no inline Tailwind classes in partials)
- CSS variables following shadcn/ui theming conventions, plus engine role tokens for shape, focus, elevation and weight (`--control-radius`, `--focus-ring-*`, `--elevation-*`, `--label-weight`)
- Tailwind CSS v4 with `@apply` for spacing/sizing/typography; every rule in `@layer components`, flattened to 0,1,0 with `:where()`
- Optional Stimulus controllers for interactivity

## Instructions

### Step 1: Load Component Files

1. Switch to the `maquina_components` project
2. Load the partial: `app/views/components/_{component_name}.html.erb`
3. Load the sub-partials if it is a compound component (e.g. `app/views/components/card/_header.html.erb`)
4. Load the CSS file: `app/assets/stylesheets/{component_name}.css`
5. Load the docs page `docs/{component_name}.md`, any helper in `app/helpers/maquina_components/`, and any controller in `app/javascript/controllers/`
6. Note where the CSS is imported in `app/assets/tailwind/maquina_components_engine/engine.css` (primitives vs composites group)

### Step 2: Search shadcn/ui

Search for "shadcn ui {component_name} component docs" to compare with the original.

### Step 3: Provide Diagnosis

Create a diagnosis table covering:

| Area | Current | Recommended |
|------|---------|-------------|
| Parameter defaults | Check symbols, default values | Fix any issues |
| Parameter naming | Check conventions | Use `css_classes`, `**html_options`, `text:`/`content:` on leaves |
| HTML passthrough | Check if `**html_options` exists | Add if missing |
| Data attribute merging | Hand-rolled `.merge` or none | `merge_component_data(html_options, …)` |
| Block support | Leaf renders `text \|\| content` only | `text.presence \|\| content \|\| yield` |
| Absent attributes | `data-x="false"` emitted | Pass `nil` so the attribute is dropped |
| CSS approach | Inline Tailwind vs CSS file | CSS file with data-attribute selectors |
| Cascade | Unlayered / stacked attribute selectors | `@layer components`, qualifiers in `:where()`, base → sizes → variants → states |

Then compare with shadcn/ui:

| Feature | shadcn/ui | maquina_components |
|---------|-----------|-------------------|
| Variants | List theirs | List ours |
| Sizes | List theirs | List ours |
| Special features | Note any | Note any |

Assess CSS quality:
- Data-attribute selectors ✓/✗
- Inside `@layer components`, specificity 0,1,0 ✓/✗
- Theme variables for colors; fallbacks for anything outside the base palette (`--success`, `--warning`, `--info`) ✓/✗
- Radius from `--control-radius` / `--surface-radius` (with a `--{component}-radius` escape hatch) ✓/✗
- Elevation from `--elevation-*` ✓/✗
- Focus ring: `:focus-visible` outline longhands from `--focus-ring-*` ✓/✗
- No `transition-colors` (it transitions `outline-color`) ✓/✗
- Disabled states ✓/✗
- Dark mode via tokens only (no `.dark` property rules, no `prefers-color-scheme`) ✓/✗

### Step 4: Propose Partial Update

Provide the recommended ERB partial code with:
- Correct strict locals declaration
- Symbol defaults (`:default` not `"default"`)
- `css_classes` parameter (not `class:`)
- `**html_options` for passthrough
- `merge_component_data` for data attributes (component keeps `component`/`variant`/`size`/`*_part`; `controller`/`action` concatenate)

### Step 5: Create/Update CSS File

Create `app/assets/stylesheets/{component_name}.css` with:
- A header comment describing the cascade order (copy from an existing file)
- Every rule inside `@layer components`; `@keyframes` outside it
- Data-attribute selectors with qualifiers in `:where()` (`[data-component="{component}"]:where([data-variant="primary"])`)
- CSS variables for colors (`var(--primary)`, `var(--muted-foreground)`)

**Use `@apply` for:**
- Spacing: `@apply p-6 px-2.5 gap-4`
- Typography size/leading/tracking: `@apply text-sm leading-none tracking-tight`
- Sizes: `@apply h-6 size-4`
- Transitions with named properties: `@apply transition-[color,background-color,border-color] duration-150`
- Layout helpers: `@apply shrink-0 pointer-events-none`

**Use tokens / explicit CSS for:**
- Colors: `background-color: var(--muted)`
- Radius: `border-radius: var(--{component}-radius, var(--control-radius, 0.375rem))`
- Shadows: `box-shadow: var(--elevation-raised, var(--shadow-sm, …))`
- Weight: `font-weight: var(--label-weight, 500)`
- Focus rings: `outline-width/style/color/offset` from `--focus-ring-*`
- Display/flex properties: `display: flex; flex-direction: column`
- Custom em-based sizing: `width: 0.875em` (scales with font)

### Step 6: Write Documentation

Create `docs/{component_name}.md` following the existing pages (see `docs/badge.md`):

1. **Title & Description** — `# Name` and a `>` one-liner
2. **Preview tag** — `<!-- preview:default height:N -->` (needs `test/dummy/app/views/previews/{component_name}/default.html.erb`)
3. **Usage** — simplest example
4. **Examples** — variants, sizes, with icons (`icon_for`), each with its own preview tag
5. **Accessibility** — roles, keyboard, aria (when relevant)
6. **API Reference** — one parameters table per partial (Parameter, Type, Default, Description)

New theming tokens go in `docs/theming.md`; breaking changes in `docs/upgrading.md`.

## Output Format

1. First, show diagnosis (DO NOT make changes yet)
2. Wait for approval
3. Then update partial, CSS file, previews and documentation

## Component CSS (if available)

{PASTE CSS HERE OR NOTE "Inline Tailwind - needs CSS extraction"}

## Additional Notes

- Use `icon_for :icon_name` for icon examples, with names that exist in `icons_helper.rb` (unknown names raise in development/test)
- Use `<%%= ... %>` in markdown code blocks (escaped ERB)
- Keep examples copy-paste ready
- Structure docs for both humans and LLMs

---

## ERB Partial Template

```erb
<%# locals: (variant: :default, size: :md, css_classes: "", **html_options) %>
<% merged_data = merge_component_data(html_options,
    component: "{component_name}",
    variant: variant,
    size: size
  ) %>

<%= content_tag :{element}, class: css_classes.presence, data: merged_data, **html_options do %>
  <%= yield %>
<% end %>
```

## CSS File Template

```css
/* ===== {ComponentName} Component Styles ===== */
/*
 * {Description of component purpose}
 *
 * Cascade order in this file (full contract documented in form.css):
 *   1. base      [data-component="{component_name}"]
 *   2. sizes     [data-component="{component_name}"]:where([data-size="…"])
 *   3. variants  [data-component="{component_name}"]:where([data-variant="…"])
 *   4. states    :where(:hover, :focus-visible, :active, :disabled)
 *   5. dark      — none; dark-mode differences are tokens (see tokens.css)
 */

@layer components {
  /* ===== Base Styles ===== */
  [data-component="{component_name}"] {
    display: inline-flex;
    align-items: center;
    @apply gap-2 text-sm border border-transparent;
    border-radius: var(--{component_name}-radius, var(--control-radius, 0.375rem));
    font-weight: var(--label-weight, 500);
    @apply transition-[background-color,border-color,color,opacity] duration-150;
  }

  /* ===== Icon Support ===== */
  [data-component="{component_name}"] svg {
    width: 0.875em;
    height: 0.875em;
    @apply shrink-0 pointer-events-none;
  }

  /* ===== Size Variants ===== */
  [data-component="{component_name}"]:where([data-size="sm"]) {
    @apply text-xs px-2 py-0.5 h-5;
  }

  [data-component="{component_name}"]:where([data-size="md"]) {
    @apply text-sm px-2.5 py-1 h-6;
  }

  [data-component="{component_name}"]:where([data-size="lg"]) {
    @apply text-sm px-3 py-1.5 h-7;
  }

  /* ===== Visual Variants ===== */
  [data-component="{component_name}"]:where([data-variant="default"]) {
    background-color: var(--muted);
    color: var(--muted-foreground);
  }

  [data-component="{component_name}"]:where([data-variant="primary"]) {
    background-color: var(--primary);
    color: var(--primary-foreground);
  }

  [data-component="{component_name}"]:where([data-variant="destructive"]) {
    background-color: var(--destructive);
    color: var(--destructive-foreground);
  }

  [data-component="{component_name}"]:where([data-variant="info"]) {
    /* never fall back to --primary */
    background-color: var(--info, var(--muted));
    color: var(--info-foreground, var(--muted-foreground));
  }

  [data-component="{component_name}"]:where([data-variant="outline"]) {
    @apply bg-transparent;
    color: var(--foreground);
    border-color: var(--border);
  }

  /* ===== Interactive States ===== */
  [data-component="{component_name}"]:where(
      [data-variant="default"]:hover,
      [data-variant="primary"]:hover,
      [data-variant="destructive"]:hover
    ) {
    @apply opacity-90;
  }

  [data-component="{component_name}"]:where([data-variant="outline"]:hover) {
    background-color: var(--accent-hover, var(--accent));
    color: var(--accent-foreground);
  }

  [data-component="{component_name}"]:where(a:focus-visible, button:focus-visible) {
    outline-width: var(--focus-ring-width, 3px);
    outline-style: var(--focus-ring-style, solid);
    outline-color: var(--focus-ring-color, var(--ring));
    outline-offset: var(--focus-ring-offset, 0px);
  }

  [data-component="{component_name}"]:where(:disabled, [aria-disabled="true"]) {
    @apply opacity-50 cursor-not-allowed pointer-events-none;
  }

  /* ===== Dark Mode ===== */
  /*
   * None. Dark mode is the .dark class on <html>, handled through CSS
   * variables. If a value must differ in dark mode, add a token.
   */
}
```

## Documentation Template

```markdown
# {Component Name}

> {One-line description of the component.}

<!-- preview:default height:80 -->

## Usage

\`\`\`erb
<%%= render "components/{component_name}" do %>
  Content
<%% end %>
\`\`\`

## Examples

### Variants

<!-- preview:variants height:80 -->

\`\`\`erb
<%%= render "components/{component_name}", variant: :primary do %>Primary<%% end %>
<%%= render "components/{component_name}", variant: :destructive do %>Destructive<%% end %>
<%%= render "components/{component_name}", variant: :outline do %>Outline<%% end %>
\`\`\`

### Sizes

<!-- preview:sizes height:80 -->

\`\`\`erb
<%%= render "components/{component_name}", size: :sm do %>Small<%% end %>
<%%= render "components/{component_name}", size: :md do %>Medium<%% end %>
<%%= render "components/{component_name}", size: :lg do %>Large<%% end %>
\`\`\`

### With Icons

<!-- preview:with_icons height:80 -->

\`\`\`erb
<%%= render "components/{component_name}", variant: :primary do %>
  <%%= icon_for :check, class: "size-3" %>
  Success
<%% end %>
\`\`\`

## API Reference

### {Component Name}

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| variant | Symbol | :default | :default, :primary, :destructive, :info, :outline |
| size | Symbol | :md | :sm, :md, :lg |
| css_classes | String | "" | Additional CSS classes |
| html_options | Hash | {} | Additional HTML attributes |
```

---

## Quality Checklist

Before completing a component:

### ERB Partial
- [ ] Uses strict locals declaration
- [ ] Symbol defaults (`:default` not `"default"`)
- [ ] `css_classes` parameter (not `class:`), rendered with `.presence`
- [ ] `**html_options` for passthrough
- [ ] `merge_component_data` for data attributes
- [ ] Leaf parts accept `text:`, `content:` and a block
- [ ] Optional data attributes pass `nil`, never `false`
- [ ] Icons resolve (`icon_for` / `builtin_icon_for` names exist)

### CSS File
- [ ] All rules inside `@layer components` (`@keyframes` outside)
- [ ] Qualifiers inside `:where()` (specificity 0,1,0)
- [ ] Order: base → sizes → variants → states
- [ ] Theme variables for all colors; fallbacks for non-palette variables
- [ ] Radius and elevation from role tokens with a component escape hatch
- [ ] Hover fills from `--*-hover` tokens
- [ ] `:focus-visible` outline longhands from `--focus-ring-*`
- [ ] No `transition-colors`
- [ ] Disabled state
- [ ] Icon support (svg sizing)
- [ ] No `.dark` / `prefers-color-scheme` rules

### Documentation
- [ ] Title and description
- [ ] Preview tags with heights, each backed by a preview template
- [ ] Usage example
- [ ] Variants / sizes / icons examples
- [ ] Accessibility notes (interactive components)
- [ ] API Reference table per partial
- [ ] New tokens documented in `docs/theming.md`

### Integration
- [ ] CSS imported in engine.css, in the right group and order
- [ ] Works with Rails helpers (link_to, button_to, form_with)
- [ ] Examples are copy-paste ready
- [ ] `bin/test` passes after `bin/rails tailwindcss:build` in `test/dummy`
