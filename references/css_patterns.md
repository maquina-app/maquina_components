# CSS Patterns Guide

> Detailed guide for styling components in maquina_components using Tailwind CSS v4 and data attributes.

## Core Principle

**No inline Tailwind classes in ERB partials.** All styling is done in dedicated CSS files using data-attribute selectors. Callers add utilities through the `css_classes:` parameter, and those utilities **win** over the engine.

## The Cascade Contract

Every engine stylesheet follows the same contract (documented in full at the top of `form.css`, enforced by `test/stylesheets/css_conventions_test.rb`):

1. **Every rule lives in `@layer components`.** `@layer utilities` beats `@layer components`, so a caller's Tailwind utility wins; a host's unlayered CSS wins too, whatever its specificity. The single exception is `body[data-maquina-scroll-locked]` in `drawer.css`, a functional scroll lock.
2. **Every selector is flattened to specificity 0,1,0.** The component attribute is the only thing outside `:where()`; variant, size, state and ancestor qualifiers go inside it.
3. **Source order is the only tie-breaker**, so rules are written in this order in each file:

   | Tier | Selector shape |
   |------|----------------|
   | 1. base | `[data-component="x"]` |
   | 2. sizes | `[data-component="x"]:where([data-size="…"])` |
   | 3. variants | `[data-component="x"]:where([data-variant="…"])` |
   | 4. states | `[data-component="x"]:where(:hover, :focus-visible, :disabled, [aria-invalid], …)` |
   | 5. dark | none — dark-mode differences are tokens (`tokens.css`) |

   States come last so a state always beats a variant. Cross-file order is fixed in `engine.css` — do not alphabetize the imports.
4. **`@keyframes` sit outside the layer** (they are not cascade participants).

Rules whose target is a bare element or pseudo-element read 0,1,1 — an element selector cannot be zeroed away. That is fine.

## Data Attribute Selectors

### Component Identification

```css
@layer components {
  /* Base component */
  [data-component="button"] { }

  /* Sizes */
  [data-component="button"]:where([data-size="sm"]) { }
  [data-component="button"]:where([data-size="lg"]) { }

  /* Variants */
  [data-component="button"]:where([data-variant="primary"]) { }
  [data-component="button"]:where([data-variant="destructive"]) { }

  /* States */
  [data-component="button"]:where([data-variant="primary"]:hover) { }
  [data-component="button"]:where(:disabled, [aria-disabled="true"]) { }

  /* Compound component parts — scope the part under its root with :where() */
  :where([data-component="card"]) [data-card-part="header"] { }
  :where([data-component="card"]) [data-card-part="header"]:where([data-layout="row"]) { }
}
```

### Naming Convention

| Attribute | Purpose | Example |
|-----------|---------|---------|
| `data-component` | Identifies component type (kebab-case for multi-word) | `data-component="dropdown-menu"` |
| `data-variant` | Visual style variant | `data-variant="destructive"` |
| `data-size` | Size variant | `data-size="sm"` |
| `data-{component}-part` | Compound component part | `data-card-part="header"`, `data-dropdown-menu-part="item"` |
| `data-layout` / `data-align` / `data-spacing` | Layout variant | `data-layout="row"` |
| `data-state` | Dynamic state (often set by Stimulus) | `data-state="open"` |
| `data-side` | Popover placement (flipped by controllers) | `data-side="top"` |
| `data-active` | Active item — **present only when true** | `data-active="true"` |
| `data-mark` | Control-mark ink override | `data-mark="dark"` |

Match `data-active="true"`, not bare `[data-active]` presence — inactive items omit the attribute.

## When to Use @apply vs Explicit CSS

### Use `@apply` For

```css
/* Spacing */
@apply p-6 px-2.5 py-1 gap-4 m-2;

/* Typography (size, leading, tracking) */
@apply text-sm text-base text-lg;
@apply leading-none leading-tight;
@apply tracking-tight;

/* Sizing */
@apply h-6 h-9 w-full;
@apply size-4 size-5;

/* Transitions — name the properties, see "Never transition outline-color" */
@apply transition-[color,background-color,border-color] duration-150;

/* Layout helpers */
@apply shrink-0 grow flex-1;
@apply pointer-events-none select-none;

/* Borders (width, not color) */
@apply border border-2 border-transparent;
```

### Use Tokens / Explicit CSS For

```css
/* Colors - always theme variables */
background-color: var(--primary);
color: var(--primary-foreground);
border-color: var(--border);

/* Radius - role token with a component escape hatch, never rounded-* */
border-radius: var(--card-radius, var(--surface-radius, 0.5rem));
border-radius: var(--button-radius, var(--control-radius, 0.375rem));

/* Elevation - role token, never shadow-* */
box-shadow: var(--elevation-raised, var(--shadow-sm, 0 1px 2px 0 rgb(0 0 0 / 0.05)));

/* Weight - role token for labels/values */
font-weight: var(--label-weight, 500);

/* Hover fills - tokenize the outcome */
background-color: var(--primary-hover, color-mix(in oklch, var(--primary) 90%, black));

/* Display and flex properties */
display: inline-flex;
align-items: center;

/* Custom em-based sizing (scales with font) */
width: 0.875em;
height: 0.875em;

/* Position, z-index */
position: absolute;
z-index: 50;
```

Radius must come from a token: the conventions test fails on a hardcoded radius outside a short list of structural zeros (calendar range cells, outline toggle group, inset sidebar).

### Fallback Rule

Every `var()` either names a variable in the host's base palette (`--background`, `--primary`, `--border`, `--sidebar-*`, … — see `theme_variables.md`) or carries a fallback. `--success`, `--warning` and `--info` may not exist in a host theme:

```css
background-color: var(--success, oklch(0.627 0.194 149.214));
/* --info never falls back to --primary — fall back to a neutral */
background-color: var(--info, var(--muted));
```

## Complete Component CSS Template

```css
/* ===== {ComponentName} Component Styles ===== */
/*
 * {Brief description}
 *
 * Cascade order in this file (full contract documented in form.css):
 *   1. base      [data-component="{component}"]
 *   2. sizes     [data-component="{component}"]:where([data-size="…"])
 *   3. variants  [data-component="{component}"]:where([data-variant="…"])
 *   4. states    :where(:hover, :focus-visible, :active, :disabled)
 *   5. dark      — none; dark-mode differences are tokens (see tokens.css)
 * Every rule is flattened to 0,1,0 with :where() and lives in
 * @layer components, so a caller's utility class wins and source order is
 * the only tie-breaker.
 */

@layer components {
  /* ===== Base Styles ===== */
  [data-component="{component}"] {
    display: inline-flex;
    align-items: center;
    @apply gap-2 text-sm border border-transparent;
    border-radius: var(--{component}-radius, var(--control-radius, 0.375rem));
    font-weight: var(--label-weight, 500);
    /* NOT transition-colors: it includes outline-color in v4 */
    @apply transition-[color,background-color,border-color] duration-150;
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

  [data-component="{component}"]:where([data-variant="outline"]) {
    background-color: transparent; /* not --background: must work on a card */
    color: var(--foreground);
    border-color: var(--border);
  }

  [data-component="{component}"]:where([data-variant="ghost"]) {
    background-color: transparent;
    color: var(--foreground);
    box-shadow: var(--elevation-none, none);
  }

  /* ===== States (after every variant) ===== */
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

  /* Focus ring: outline longhands from tokens, keyboard focus only */
  [data-component="{component}"]:where(:focus-visible) {
    outline-width: var(--focus-ring-width, 3px);
    outline-style: var(--focus-ring-style, solid);
    outline-color: var(--focus-ring-color, var(--ring));
    outline-offset: var(--focus-ring-offset, 0px);
  }

  /* A state that must keep its own ring sets the token, not the outline */
  [data-component="{component}"]:where([data-variant="destructive"]:focus-visible) {
    --focus-ring-color: var(--destructive);
  }

  [data-component="{component}"]:where(:disabled, [aria-disabled="true"]) {
    @apply opacity-50 cursor-not-allowed pointer-events-none;
  }

  [data-component="{component}"]:where(:active:not(:disabled)) {
    @apply scale-[0.98];
  }
}
```

## Focus Rings

- **Outlines, never box-shadows.** An outline cannot be clipped by an `overflow` ancestor, does not collide with the elevation `box-shadow`, and survives forced-colors mode.
- **Longhands, not the `outline` shorthand.** If one `var()` in the shorthand fails, the whole declaration is invalid at computed-value time and the ring vanishes (leaving `currentColor`).
- **`:focus-visible` only.** A bare `:focus` rings on mouse click.
- **Never transition `outline-color`.** That means not using `transition-colors`, which includes `outline-color` in Tailwind v4 — the ring would fade in from the text color. Name the properties: `transition-[color,background-color,border-color,text-decoration-color]`.
- A part that suppresses its outline (`outline: none`) must restore a token ring, except roving-focus menu items (`tabindex="-1"`) that show focus as a background change.

`--focus-ring-color` has no single default — each rule supplies its own fallback:

| Family | Fallback |
|--------|----------|
| Buttons, cards, badges, toasts, drawer, pagination, calendar, toggle group | `var(--ring)` |
| Sidebar parts, menu button | `var(--sidebar-ring, var(--ring))` |
| Form fields | `color-mix(in oklch, var(--ring) 50%, transparent)` |

## Form Component Patterns

Error styling keys on `aria-invalid="true"` (set by the caller) and `:user-invalid` (only after interaction). Never key on `:invalid:not(:placeholder-shown)`.

```css
@layer components {
  [data-component="input"] {
    @apply h-9 w-full min-w-0 border px-3 py-1 text-base md:text-sm outline-none;
    @apply transition-[color,box-shadow];
    border-radius: var(--input-radius, var(--control-radius, 0.375rem));
    background-color: var(--control-fill, var(--maquina-control-fill-default, transparent));
    border-color: var(--input);
    color: var(--foreground);
    box-shadow: var(--elevation-control, var(--shadow-xs, 0 1px 2px 0 rgb(0 0 0 / 0.05)));
  }

  [data-component="input"]::placeholder {
    color: var(--muted-foreground);
  }

  [data-component="input"]:where(:focus-visible) {
    border-color: var(--ring);
    outline-width: var(--focus-ring-width, 3px);
    outline-style: var(--focus-ring-style, solid);
    outline-color: var(--focus-ring-color, color-mix(in oklch, var(--ring) 50%, transparent));
    outline-offset: var(--focus-ring-offset, 0px);
  }

  [data-component="input"]:where(:disabled) {
    @apply pointer-events-none cursor-not-allowed opacity-50;
  }

  /* Invalid: the border reads --destructive-border; the ring color is set as a
     token on the element so it outranks a :root --focus-ring-color */
  [data-component="input"]:where([aria-invalid="true"], :user-invalid) {
    --focus-ring-color: color-mix(in oklch, var(--destructive) 20%, transparent);
    border-color: var(--destructive-border, var(--destructive));
  }
}
```

Field error text reads `--destructive-text`, never `--destructive-foreground` directly (that token is the text that sits *on* a destructive fill):

```css
[data-form-part="error"] {
  color: var(--destructive-text, var(--destructive-foreground));
}
```

## Handling field_with_errors

Rails wraps invalid fields in `<div class="field_with_errors">`. `form.css` already ships the compatibility rules — `display: contents` on the wrapper plus the destructive border and ring on `input`/`textarea`/`select` inside it — so host apps do not need to add them.

## Dark Mode

Dark mode is the host's `.dark` class on `<html>`; component CSS never references it.

- **No `.dark` rules that set a real property** in component CSS. A `.dark` selector adds specificity and becomes impossible to override. If a component needs a different value in dark mode, that is a missing token.
- **No `@media (prefers-color-scheme: dark)`.** It would flip a component against the user's in-app choice.
- Scheme-dependent engine defaults live on inherited scopes in `tokens.css` (`--maquina-control-fill-default`, `--maquina-select-chevron-default`, …) and are read as the *last* fallback, so a host's public token (`--control-fill`, `--select-chevron-image`) always wins in both schemes.

```css
/* Host app CSS — top-level blocks */
:root {
  --primary: oklch(0.645 0.246 16);
  --background: oklch(1 0 0);
}

.dark {
  --primary: oklch(0.712 0.194 13);
  --background: oklch(0.145 0 0);
}
```

**No `dark:` prefixes needed in component CSS.**

## Responsive Patterns

Use `@apply` for responsive utilities when needed:

```css
:where([data-component="card"]) [data-card-part="content"] {
  @apply p-4 md:p-6;
}
```

Or media queries nested inside the layer:

```css
@layer components {
  /* ... base rules ... */

  /* Hide prev/next labels on small screens */
  @media (max-width: 640px) {
    :is([data-pagination-part="previous"], [data-pagination-part="next"]) span {
      @apply sr-only;
    }
  }
}
```

## Animation Patterns

Controllers set `data-state` (`open` / `closing` / `closed`) and `data-side`; CSS animates per side. Keyframes live outside the layer:

```css
@layer components {
  [data-dropdown-menu-part="content"]:where([data-state="open"]) {
    animation: dropdown-menu-in 150ms ease-out;
  }

  [data-dropdown-menu-part="content"]:where([data-state="closing"]) {
    animation: dropdown-menu-out 100ms ease-in forwards;
  }
}

/* Outside the layer: @keyframes are not cascade participants. */
@keyframes dropdown-menu-in {
  from { opacity: 0; transform: translateY(-4px) scale(0.95); }
  to   { opacity: 1; transform: translateY(0) scale(1); }
}

@keyframes dropdown-menu-out {
  from { opacity: 1; transform: translateY(0) scale(1); }
  to   { opacity: 0; transform: translateY(-4px) scale(0.95); }
}
```

Keep the close duration in sync with the controller's timeout (`dropdown_menu_controller.js` waits 100ms).

## Specificity Tips

1. **Never use `!important`, and never double an attribute selector to win.** Fix the source order instead.
2. **Order matters** — base, sizes, variants, states; across files, the `engine.css` import order.
3. **A new composite that overrides a primitive** (e.g. a trigger carrying `data-component="button"`) must be imported *after* `form.css`.
4. **Pin one component without a selector** by setting its component-level token (`--card-radius`, `--toast-shadow`) — see `theme_variables.md`.

## Importing in engine.css

Import new CSS files in `app/assets/tailwind/maquina_components_engine/engine.css`, in the right group and after anything they override:

```css
@import "./tokens.css";

@source "../../../views/";

/* ----- 1. Primitives ----- */
@import "../../stylesheets/form.css";
/* ... badge, separator, card, table */

/* ----- 2. Composites ----- */
@import "../../stylesheets/alert.css";
/* ... */
@import "../../stylesheets/{component}.css";  /* Add new import here */
```
