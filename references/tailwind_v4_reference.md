# Tailwind CSS v4 Reference

> Quick reference for Tailwind CSS v4 features used in maquina_components.

## Key Changes from v3

| Feature | v3 | v4 |
|---------|----|----|
| Config | `tailwind.config.js` | CSS `@theme` directive |
| Import | `@tailwind base/components/utilities` | `@import "tailwindcss"` |
| Custom utilities | `@layer utilities { }` | `@utility name { }` |
| Custom variants | Plugin API | `@custom-variant name (selector)` |
| PostCSS plugin | `tailwindcss` | `@tailwindcss/postcss` |
| Content sources | `content: []` in JS | `@source` in CSS |

## CSS-First Configuration

### Basic Setup

```css
@import "tailwindcss";

:root {
  --primary: oklch(0.645 0.246 16);
  --primary-foreground: oklch(0.969 0.015 12);
}

@theme {
  --color-primary: var(--primary);
  --color-primary-foreground: var(--primary-foreground);
}
```

### Source Detection

```css
/* Scan specific directory */
@source "../../../views/";

/* Add additional sources */
@source "../node_modules/@my-company/ui-lib";
```

## @theme Directive

Defines design tokens that generate utilities:

```css
@theme {
  /* Colors → bg-avocado-500, text-avocado-500, etc. */
  --color-avocado-500: oklch(0.84 0.18 117.33);
  
  /* Fonts → font-display */
  --font-display: "Satoshi", "sans-serif";
  
  /* Breakpoints → 3xl:* variants */
  --breakpoint-3xl: 1920px;
  
  /* Spacing → Uses --spacing for all spacing utilities */
  --spacing: 0.25rem;
  
  /* Border radius → rounded-xl */
  --radius-xl: 1rem;
  
  /* Shadows → shadow-soft */
  --shadow-soft: 0 2px 8px rgb(0 0 0 / 0.1);
  
  /* Easing → ease-fluid */
  --ease-fluid: cubic-bezier(0.3, 0, 0, 1);
  
  /* Animations → animate-marquee */
  --animate-marquee: marquee 3s linear infinite;
  
  @keyframes marquee {
    to { transform: translateY(-50%); }
  }
}
```

### Namespace Reference

| Namespace | Utilities Generated |
|-----------|---------------------|
| `--color-*` | `bg-*`, `text-*`, `border-*`, `fill-*`, `stroke-*` |
| `--font-*` | `font-*` (family) |
| `--text-*` | `text-*` (size) |
| `--font-weight-*` | `font-*` (weight) |
| `--tracking-*` | `tracking-*` |
| `--leading-*` | `leading-*` |
| `--spacing-*` | `p-*`, `m-*`, `gap-*`, `w-*`, `h-*` |
| `--breakpoint-*` | `sm:*`, `md:*`, `lg:*` variants |
| `--radius-*` | `rounded-*` |
| `--shadow-*` | `shadow-*` |
| `--ease-*` | `ease-*` |
| `--animate-*` | `animate-*` |

### `@theme static`

By default Tailwind only emits theme variables that something references through a utility. `@theme static` always emits them. The engine's `tokens.css` uses it because its tokens are read from hand-written `var()` calls, never from utility classes:

```css
@theme static {
  --control-radius: 0.375rem;
  --focus-ring-width: 3px;
  --elevation-overlay: var(--shadow-md, 0 4px 6px -1px rgb(0 0 0 / 0.1));
}
```

`@theme` emits into `@layer theme`, which loses to any unlayered `:root`, so a host's token always beats the engine default regardless of import order.

### Overriding Defaults

```css
@theme {
  /* Reset entire namespace */
  --color-*: initial;
  
  /* Then define your own */
  --color-primary: oklch(0.5 0.2 250);
  --color-secondary: oklch(0.8 0.1 200);
}
```

This is why the engine's role tokens are **not** named into Tailwind namespaces (`--radius-control`, `--shadow-overlay`): a host's `--radius-*: initial` would wipe them.

## @utility Directive

Define custom utilities:

```css
/* Simple utility */
@utility content-auto {
  content-visibility: auto;
}

/* With nested selectors */
@utility scrollbar-hidden {
  &::-webkit-scrollbar {
    display: none;
  }
}

/* Functional utility with values */
@utility tab-* {
  tab-size: --value(integer);
}
```

### Usage

```html
<div class="content-auto scrollbar-hidden tab-4">
```

## @custom-variant Directive

Define custom variants:

```css
/* Media query variant */
@custom-variant pointer-coarse (@media (pointer: coarse));

/* Selector variant */
@custom-variant theme-midnight (&:where([data-theme="midnight"] *));

/* Class-based dark mode — what the maquina_components installer writes */
@custom-variant dark (&:is(.dark *));
```

`@variant` (no `custom-`) *applies* an existing variant inside your own CSS:

```css
.my-element {
  background: white;
  @variant dark {
    background: black;
  }
}
```

### Usage

```html
<div class="pointer-coarse:text-lg theme-midnight:bg-slate-900">
```

## @layer Directive

Use native CSS cascade layers. Tailwind v4 emits `theme, base, components, utilities` in that order; unlayered CSS beats all of them.

maquina_components puts **every** component rule in `@layer components` (so `css_classes:` utilities win) and the installer's `* { border-color }` shim in `@layer base` (an unlayered `*` would override every component border).

```css
@layer base {
  h1 {
    font-size: var(--text-2xl);
  }
}

@layer components {
  .card {
    background-color: var(--color-white);
    border-radius: var(--radius-lg);
    padding: var(--spacing-6);
  }
}
```

## New Utilities in v4

### Container Queries

```html
<div class="@container">
  <div class="@sm:grid-cols-3 @lg:grid-cols-4">
</div>
```

### 3D Transforms

```html
<div class="perspective-distant rotate-x-45 rotate-y-30 translate-z-10">
```

### Inset Shadows/Rings

```html
<button class="shadow-md inset-shadow-sm inset-ring inset-ring-white/15">
```

### Field Sizing

```html
<textarea class="field-sizing-content">
```

### Color Scheme

```html
<html class="scheme-light dark:scheme-dark">
```

## New Variants in v4

### Composable Variants

```html
<!-- Simplified data attribute variants -->
<div class="group-has-data-potato:opacity-100">

<!-- Instead of -->
<div class="group-has-[&[data-potato]]:opacity-100">
```

### not-* Variant

```html
<button class="hover:not-focus:bg-indigo-700">
```

### in-* Variant (like group-* without adding group)

```html
<div tabindex="0">
  <div class="in-focus:opacity-100">
```

### nth-* Variants

```html
<div class="nth-3:underline nth-last-5:font-bold">
```

### starting Variant (@starting-style)

```html
<div class="starting:opacity-0 opacity-100 transition-opacity">
```

### inert Variant

```html
<main inert class="inert:opacity-50 inert:blur">
```

## Breaking Changes

### Default Values Changed

| Utility | v3 | v4 |
|---------|----|----|
| `shadow-sm` | Small shadow | Now `shadow-xs` |
| `shadow` | Medium shadow | Now `shadow-sm` |
| `blur-sm` | Small blur | Now `blur-xs` |
| `blur` | Medium blur | Now `blur-sm` |
| `rounded-sm` | Small radius | Now `rounded-xs` |
| `rounded` | Medium radius | Now `rounded-sm` |
| `ring` | 3px ring | Now 1px (use `ring-3`) |

### Border Color

```css
/* v3: gray-200 by default */
/* v4: currentColor by default */

/* To restore v3 behavior: */
@layer base {
  *, ::after, ::before {
    border-color: var(--color-gray-200, currentColor);
  }
}

/* maquina_components installer equivalent — keep it inside @layer base */
@layer base {
  * {
    border-color: var(--color-border);
  }
}
```

### transition-colors Includes outline-color

In v4, `transition-colors` transitions `outline-color` too. On a focus ring this fades the ring in from the element's text color. maquina_components never uses `transition-colors` on anything that paints a token focus ring; name the properties instead:

```css
@apply transition-[color,background-color,border-color,text-decoration-color];
```

### outline-none → outline-hidden

```html
<!-- v3 -->
<input class="focus:outline-none">

<!-- v4 -->
<input class="focus:outline-hidden">
```

### CSS Variables Syntax

```html
<!-- v3 -->
<div class="bg-[--brand-color]">

<!-- v4 -->
<div class="bg-(--brand-color)">
```

### Hover on Mobile

v4 hover only applies when device supports hover:

```css
@media (hover: hover) {
  .hover\:underline:hover {
    text-decoration: underline;
  }
}
```

## Engine Integration

### engine.css Structure

tailwindcss-rails builds `app/assets/tailwind/maquina_components_engine/engine.css` into the host's `app/assets/builds/tailwind/maquina_components_engine.css`.

```css
/* Token defaults first: every component stylesheet reads them */
@import "./tokens.css";

/* Scan engine views */
@source "../../../views/";

/* Import component styles — grouped primitives → composites; order is load-bearing */
@import "../../stylesheets/form.css";
@import "../../stylesheets/badge.css";
/* ... */
@import "../../stylesheets/breadcrumbs.css";
```

### Host App Integration

```css
/* app/assets/tailwind/application.css */
@import "tailwindcss";

@import "../builds/tailwind/maquina_components_engine.css";

@custom-variant dark (&:is(.dark *));

:root {
  /* Define theme variables (unlayered) */
}

.dark {
  /* Dark values — top level, never nested inside :root */
}

@theme {
  /* Bind to Tailwind: --color-primary: var(--primary); ... */
}

@layer base {
  * { border-color: var(--color-border); }
}
```

## Using theme() Function

```css
/* For media queries (CSS variables don't work) */
@media (width >= theme(--breakpoint-xl)) {
  /* ... */
}

/* Prefer CSS variables elsewhere */
.my-class {
  /* Prefer this */
  background-color: var(--color-red-500);
  
  /* Over this */
  background-color: theme(--color-red-500);
}
```

## @apply Directive

Still works in v4:

```css
.button-primary {
  @apply bg-primary text-primary-foreground rounded-md px-4 py-2;
}

/* With hover */
.button-primary {
  @apply bg-primary hover:bg-primary/90;
}
```

In engine stylesheets, `@apply` is limited to spacing, sizing, typography size, layout and transitions; colors, radius, shadows and weights come from theme variables and tokens (see `css_patterns.md`).

## Plugins

```css
@plugin "@tailwindcss/typography";
@plugin "./my-custom-plugin.js";
```

## Legacy JS Config

If needed, load with `@config`:

```css
@import "tailwindcss";
@config "../../tailwind.config.js";
```
