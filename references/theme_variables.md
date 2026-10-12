# Theme Variables Reference

> Complete reference for CSS variables used in maquina_components: the shadcn/ui color palette the host declares, and the engine's role tokens for shape, focus, elevation and weight.

Sources of truth: `lib/generators/maquina_components/install/templates/theme.css.tt` (palette), `.../shape_state_tokens.css.tt` (hover/info/opt-in tokens), `app/assets/tailwind/maquina_components_engine/tokens.css` (engine defaults), and `docs/theming.md`.

## Variable Architecture

### Two-Layer Pattern

Colors are declared once as plain shadcn-named variables, then bound into Tailwind's `--color-*` namespace:

```css
:root {
  /* Raw values - read directly by engine CSS */
  --primary: oklch(0.645 0.246 16);
  --primary-foreground: oklch(0.969 0.015 12);
}

@theme {
  /* Tailwind bindings - enable utilities */
  --color-primary: var(--primary);
  --color-primary-foreground: var(--primary-foreground);
}
```

**Result:**
- Engine CSS: `background-color: var(--primary)`
- Tailwind: `bg-primary`, `text-primary-foreground`

There is no `-color` suffix (`--primary-color` is not used anywhere).

### Where Declarations Go

- **Palette and token overrides:** plain, *unlayered* `:root` / `.dark` blocks. Unlayered CSS beats the engine's `@theme static` defaults (which emit into `@layer theme`) regardless of import order.
- **Do not** put token values in `@theme` (they would compete with the engine's defaults by source order), and do not rename role tokens into Tailwind namespaces (`--radius-*`, `--shadow-*`).
- **`.dark` must be top-level**, never nested in `:root` (nested compiles to `:root .dark`, which never matches `<html class="dark">`). `bin/rails maquina:doctor` reports a nested block as `nested-dark-block`.

## Base Palette (host-declared)

These are what the installer writes and what engine CSS may read **without** a fallback (`BASE_PALETTE` in `test/stylesheets/css_conventions_test.rb`).

### Core Semantic Colors

| Variable | Purpose | Used By |
|----------|---------|---------|
| `--background` / `--foreground` | Page background, default text | Body, inputs' select fill |
| `--card` / `--card-foreground` | Card and in-page surfaces | Card, alert, calendar, stats, empty |
| `--popover` / `--popover-foreground` | Floating surfaces | Dropdown menu, combobox, date-picker popover, toast, menu button |
| `--primary` / `--primary-foreground` | Brand/action color | Primary/default buttons, checked marks, link buttons |
| `--secondary` / `--secondary-foreground` | Subtle fills | Secondary buttons and badges |
| `--muted` / `--muted-foreground` | Subtle backgrounds, secondary text | Default badge, descriptions, placeholders |
| `--accent` / `--accent-foreground` | Hover/highlight fills | Outline/ghost hover, menu items |
| `--destructive` / `--destructive-foreground` | Danger fill / text on that fill | Destructive buttons, badges, alerts, toasts |
| `--border` | Default borders | Cards, tables, separators |
| `--input` | Form control borders | Input, textarea, select, outline button |
| `--ring` | Focus ring | Every focus ring (via `--focus-ring-color` fallback) |

### Sidebar

| Variable | Purpose |
|----------|---------|
| `--sidebar` | Sidebar background (not `--sidebar-background`) |
| `--sidebar-foreground` | Sidebar text |
| `--sidebar-primary` / `--sidebar-primary-foreground` | Active/brand items |
| `--sidebar-accent` / `--sidebar-accent-foreground` | Hover and active item fills |
| `--sidebar-border` | Sidebar borders |
| `--sidebar-ring` | Sidebar and menu-button focus ring |

### Layout

| Variable | Installer value |
|----------|-----------------|
| `--header-height` | `calc(var(--spacing) * 12 + 1px)` |
| `--sidebar-width` | `calc(var(--spacing) * 72)` |
| `--sidebar-width-icon` | `3rem` (collapsed icon rail) |

### Charts (optional, unused by the engine)

`--chart-1` … `--chart-5` are written by the installer for host use.

## Status Colors (read with fallbacks)

The installer declares `--success` / `--warning` (palette) and `--info` (shape/state token block). Engine CSS always reads them with a fallback, because a host theme may not define them:

```css
:root {
  --success: oklch(0.92 0.04 168);
  --success-foreground: oklch(0.35 0.08 168);
  --warning: oklch(0.93 0.04 55);
  --warning-foreground: oklch(0.4 0.08 50);
  --info: oklch(0.93 0.04 240);
  --info-foreground: oklch(0.4 0.12 250);
}

.dark {
  --success: oklch(0.32 0.06 168);
  --success-foreground: oklch(0.82 0.06 168);
  --warning: oklch(0.36 0.06 55);
  --warning-foreground: oklch(0.86 0.06 55);
  --info: oklch(0.34 0.07 250);
  --info-foreground: oklch(0.88 0.06 240);
}
```

`--info` never falls back to `--primary` (an info badge must not read as a brand call to action); it falls back to `--muted` / `--muted-foreground`.

### Tinted vs Saturated Destructive

The installer's palette is **tinted** (`--destructive` a pale tint, `--destructive-foreground` a readable dark red), matching `--success`/`--warning`. A shadcn-style **saturated** palette inverts that. Field error text and invalid borders therefore read their own tokens:

| Token | Default | Applies to |
|-------|---------|------------|
| `--destructive-text` | `var(--destructive-foreground)` | `[data-form-part="error"]` text |
| `--destructive-border` | `var(--destructive)` | Border of an invalid field |

Under a saturated palette:

```css
:root {
  --destructive-text: var(--destructive);
  --destructive-border: var(--destructive);
}
```

## Hover Tokens

Hover fills are tokens (the outcome, not the recipe — darkening is wrong in dark mode). Each falls back to the 0.5.1 recipe:

| Token | Fallback |
|-------|----------|
| `--primary-hover` | `color-mix(in oklch, var(--primary) 90%, black)` |
| `--secondary-hover` | `color-mix(in oklch, var(--secondary) 80%, black)` |
| `--destructive-hover` | `color-mix(in oklch, var(--destructive) 90%, black)` |
| `--accent-hover` | `var(--accent)` |
| `--sidebar-accent-hover` | `var(--sidebar-accent)` |

## Engine Role Tokens

Declared by the engine in `tokens.css` inside `@theme static` (so Tailwind never prunes them). Override them in an unlayered `:root`.

| Token | Default | Applies to |
|-------|---------|------------|
| `--control-radius` | `0.375rem` | Buttons, inputs, selects, textareas, badges, menu items, pagination links, calendar days, sidebar items |
| `--surface-radius` | `0.5rem` | Cards, alerts, popovers, toasts, tables, stats, empty, calendar, drawer, inset sidebar |
| `--mark-radius` | `4px` | Checkbox box |
| `--pill-radius` | `calc(infinity * 1px)` | Radio, switch track |
| `--focus-ring-width` | `3px` | Every focus ring |
| `--focus-ring-offset` | `0px` | Every focus ring |
| `--focus-ring-style` | `solid` | Every focus ring |
| `--focus-ring-color` | *per-family fallback* | `var(--ring)`; `var(--sidebar-ring, var(--ring))` in the sidebar/menu button; `color-mix(in oklch, var(--ring) 50%, transparent)` on form fields |
| `--elevation-control` | `var(--shadow-xs)` | Inputs, selects, textareas, checkbox, radio |
| `--elevation-raised` | `var(--shadow-sm)` | Cards, stats cards, floating sidebar, filled buttons |
| `--elevation-overlay` | `var(--shadow-md)` | Dropdown/combobox popovers, date-picker popover, toasts, drawer panel |
| `--elevation-none` | `none` (use-site fallback) | Ghost and link buttons, inset sidebar |
| `--label-weight` | `500` | Labels, buttons |
| `--value-weight` | `700` | Stat values |

### Use-site Tokens (no engine declaration)

These must stay redefinable inside a `.dark` scope, so the engine only supplies them as `var()` fallbacks:

| Token | Purpose |
|-------|---------|
| `--focus-ring-color` | Ring color (invalid fields and destructive buttons set it on the element) |
| `--control-fill` | Field background; engine default is `transparent` (light) / `color-mix(in oklch, var(--input) 30%, transparent)` (dark) |
| `--checkbox-mark-image`, `--checkbox-indeterminate-image`, `--radio-mark-image`, `--switch-thumb-image`, `--select-chevron-image` | Control-mark SVG data URIs |

A `:root` value for `--control-fill` or `--select-chevron-image` wins in both schemes: the scheme-dependent defaults live on inherited internal variables (`--maquina-control-fill-default`, `--maquina-select-fill-default`, `--maquina-select-chevron-default`) declared on `:root` / `.dark` in `tokens.css`. Those `--maquina-*` names are **not** public API.

Per-instance mark ink without CSS: `data-mark="dark"` on checkbox, radio, switch or select; `data-mark="light"` on select.

### Component-level Escape Hatches

Every radius and elevation site reads a component token that falls back to the role token, so one component can be pinned without redefining a role:

| Property | Falls back to |
|----------|---------------|
| `--button-radius`, `--input-radius`, `--textarea-radius`, `--select-radius`, `--badge-radius`, `--pagination-radius`, `--toggle-group-radius`, `--date-picker-radius`, `--menu-button-radius`, `--sidebar-item-radius`, `--calendar-cell-radius`, `--combobox-item-radius`, `--dropdown-menu-item-radius`, `--toast-action-radius`, `--toast-close-radius`, `--drawer-close-radius` | `--control-radius` |
| `--card-radius`, `--alert-radius`, `--table-radius`, `--stats-radius`, `--empty-radius`, `--fieldset-radius`, `--calendar-radius`, `--combobox-radius`, `--dropdown-menu-radius`, `--menu-button-content-radius`, `--date-picker-popover-radius`, `--sidebar-radius`, `--inset-radius`, `--avatar-radius`, `--toast-radius` | `--surface-radius` |
| `--checkbox-radius` | `--mark-radius` |
| `--radio-radius`, `--switch-radius` | `--pill-radius` |
| `--card-shadow`, `--stats-shadow` | `--elevation-raised` |
| `--combobox-shadow`, `--dropdown-menu-shadow`, `--menu-button-shadow`, `--date-picker-popover-shadow`, `--toast-shadow`, `--toast-hover-shadow`, `--drawer-shadow` | `--elevation-overlay` |

## Variable Usage in CSS

### In Component CSS Files

```css
@layer components {
  /* Base-palette colors need no fallback */
  [data-component="button"]:where([data-variant="primary"]) {
    background-color: var(--primary);
    color: var(--primary-foreground);
  }

  /* Role token with component escape hatch and literal fallback */
  [data-component="input"] {
    border-color: var(--input);
    border-radius: var(--input-radius, var(--control-radius, 0.375rem));
  }

  /* Focus ring pattern */
  [data-component="button"]:where(:focus-visible) {
    outline-width: var(--focus-ring-width, 3px);
    outline-style: var(--focus-ring-style, solid);
    outline-color: var(--focus-ring-color, var(--ring));
    outline-offset: var(--focus-ring-offset, 0px);
  }
}
```

### With Tailwind Utilities (host views)

After the `@theme` binding, utilities work: `bg-primary`, `text-muted-foreground`, `border-sidebar-border`.

## Complete Host App Template

What `bin/rails generate maquina_components:install` appends to `app/assets/tailwind/application.css`:

```css
@import "tailwindcss";

@import "../builds/tailwind/maquina_components_engine.css";

@custom-variant dark (&:is(.dark *));

:root {
  /* Layout */
  --header-height: calc(var(--spacing) * 12 + 1px);
  --sidebar-width: calc(var(--spacing) * 72);
  --sidebar-width-icon: 3rem;

  /* Core Colors */
  --background: oklch(1 0 0);
  --foreground: oklch(0.145 0 0);
  --card: oklch(1 0 0);
  --card-foreground: oklch(0.145 0 0);
  --popover: oklch(1 0 0);
  --popover-foreground: oklch(0.145 0 0);
  --primary: oklch(0.645 0.246 16);
  --primary-foreground: oklch(0.969 0.015 12);
  --secondary: oklch(0.97 0 0);
  --secondary-foreground: oklch(0.205 0 0);
  --muted: oklch(0.97 0 0);
  --muted-foreground: oklch(0.556 0 0);
  --accent: oklch(0.97 0 0);
  --accent-foreground: oklch(0.205 0 0);
  --success: oklch(0.92 0.04 168);
  --success-foreground: oklch(0.35 0.08 168);
  --warning: oklch(0.93 0.04 55);
  --warning-foreground: oklch(0.4 0.08 50);
  --destructive: oklch(0.92 0.05 8);
  --destructive-foreground: oklch(0.4 0.12 8);

  /* Borders & Inputs */
  --border: oklch(0.922 0 0);
  --input: oklch(0.922 0 0);
  --ring: oklch(0.645 0.246 16);

  /* Charts (optional) */
  --chart-1: oklch(0.645 0.246 16);
  /* ... --chart-2 … --chart-5 */

  /* Sidebar */
  --sidebar: oklch(0.96 0 0);
  --sidebar-foreground: oklch(0.2 0 0);
  --sidebar-primary: oklch(0.645 0.246 16);
  --sidebar-primary-foreground: oklch(0.969 0.015 12);
  --sidebar-accent: oklch(0.9 0 0);
  --sidebar-accent-foreground: oklch(0.145 0 0);
  --sidebar-border: oklch(0.88 0 0);
  --sidebar-ring: oklch(0.645 0.246 16);
}

/* Top level, not nested in :root */
.dark {
  --background: oklch(0.145 0 0);
  --foreground: oklch(0.985 0 0);
  --card: oklch(0.205 0 0);
  --card-foreground: oklch(0.985 0 0);
  --popover: oklch(0.269 0 0);
  --popover-foreground: oklch(0.985 0 0);
  --primary: oklch(0.712 0.194 13);
  --primary-foreground: oklch(0.15 0.052 13);
  --secondary: oklch(0.269 0 0);
  --secondary-foreground: oklch(0.985 0 0);
  --muted: oklch(0.269 0 0);
  --muted-foreground: oklch(0.708 0 0);
  --accent: oklch(0.371 0 0);
  --accent-foreground: oklch(0.985 0 0);
  --success: oklch(0.32 0.06 168);
  --success-foreground: oklch(0.82 0.06 168);
  --warning: oklch(0.36 0.06 55);
  --warning-foreground: oklch(0.86 0.06 55);
  --destructive: oklch(0.34 0.07 8);
  --destructive-foreground: oklch(0.88 0.06 8);
  --border: oklch(1 0 0 / 10%);
  --input: oklch(1 0 0 / 15%);
  --ring: oklch(0.455 0.188 13);
  /* ... charts */
  --sidebar: oklch(0.14 0 0);
  --sidebar-foreground: oklch(0.9 0 0);
  --sidebar-primary: oklch(0.712 0.194 13);
  --sidebar-primary-foreground: oklch(0.15 0.052 13);
  --sidebar-accent: oklch(0.22 0 0);
  --sidebar-accent-foreground: oklch(0.95 0 0);
  --sidebar-border: oklch(1 0 0 / 12%);
  --sidebar-ring: oklch(0.455 0.188 13);
}

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
  --color-ring-destructive: var(--destructive);
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

/* Must stay in @layer base: unlayered, it beats every engine component border */
@layer base {
  * {
    border-color: var(--color-border);
  }
}

/* maquina_components:shape-state-tokens ... (marker — keep it) */
:root {
  --primary-hover: color-mix(in oklch, var(--primary) 90%, black);
  --secondary-hover: color-mix(in oklch, var(--secondary) 80%, black);
  --destructive-hover: color-mix(in oklch, var(--destructive) 90%, black);
  --accent-hover: var(--accent);
  --info: oklch(0.93 0.04 240);
  --info-foreground: oklch(0.4 0.12 250);
}

.dark {
  --info: oklch(0.34 0.07 250);
  --info-foreground: oklch(0.88 0.06 240);
}

/* ...followed by a commented-out block listing every shape/focus/elevation/
   weight/control-fill/mark token at its 0.5.1 value. */
```

The installer's `@theme` block does not bind `--success`, `--warning` or `--info`; add `--color-success: var(--success);` etc. if you want `bg-success` utilities (the dummy app does).

## Theme Variants

### Color themes

Override palette variables under an attribute on `<html>` (as the dummy app does with `data-theme`):

```css
:root[data-theme="green"] {
  --primary: oklch(0.596 0.145 163);
  /* ... */
}

.dark[data-theme="green"] {
  /* ... */
}
```

### Shape themes

A theme changes token **values**, not selectors. If a theme needs `[data-component="…"]`, the token layer is missing a token.

```css
/* Flat */
:root {
  --elevation-control: none;
  --elevation-raised: none;
  --elevation-overlay: none;
  --elevation-none: none;
  --control-radius: 0.25rem;
  --surface-radius: 0.25rem;
}

/* Brutal (test/dummy: :root[data-shape-theme="brutal"]) */
:root[data-shape-theme="brutal"] {
  --control-radius: 0;
  --surface-radius: 0;
  --mark-radius: 0;
  --pill-radius: 0;
  --focus-ring-width: 4px;
  --focus-ring-offset: 3px;
  --elevation-control: none;
  --elevation-raised: none;
  --elevation-overlay: none;
  --label-weight: 700;
  --value-weight: 900;
}
```

Keep mark inks (`--*-image`) in the color theme, not the shape theme — ink is a color concern.

## Color Format: OKLCH

All colors use OKLCH format for:
- Wider color gamut (P3 displays)
- Perceptually uniform
- Easier to create harmonious palettes

```
oklch(L C H)        oklch(L C H / alpha)
- L: Lightness (0-1, or 0-100%)
- C: Chroma (0-0.4 typical)
- H: Hue (0-360 degrees)
```

When checking surface-against-surface contrast (e.g. `--card` vs `--background`), compare ΔL, not a WCAG ratio — WCAG contrast is a text metric.

## Quick Reference Table

| Variable | Purpose | Used By |
|----------|---------|---------|
| `--primary` | Brand color | Default/primary buttons, checked controls |
| `--primary-foreground` | Text on primary | Button text |
| `--secondary` | Subtle fills | Secondary buttons/badges |
| `--muted` | Subtle backgrounds | Default badge, skeleton fills |
| `--muted-foreground` | Subtle text | Placeholders, descriptions |
| `--accent` | Hover backgrounds | Menu hovers, ghost/outline hover |
| `--destructive` | Danger fill | Destructive variants, invalid border |
| `--background` | Page background | Body, select fill |
| `--foreground` | Default text | Body text |
| `--card` | In-page surface | Card, alert, calendar |
| `--popover` | Floating surface | Menus, popovers, toasts |
| `--border` | Default borders | Dividers, cards, tables |
| `--input` | Input borders | Form fields, outline button |
| `--ring` | Focus ring | Focus states |
| `--sidebar` | Sidebar background | Sidebar |
| `--control-radius` / `--surface-radius` | Shape | Controls / surfaces |
| `--elevation-*` | Shadows | Controls, raised surfaces, overlays |
| `--focus-ring-*` | Focus ring geometry/color | Every focus ring |
