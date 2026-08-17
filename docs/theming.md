# Theming

> Reshape every component by declaring token values, not override CSS.

Colors have always been CSS variables. As of 0.6.0 so are shape, focus rings,
elevation and weight, which is the whole of what used to require override CSS.

**The contract: a theme changes values, not selectors.** If a theme needs a
selector, either you are changing one component's shape on purpose, or the token
layer is missing a token — [open an issue](https://github.com/maquina-app/maquina_components/issues).

## Role tokens

Tokens are named for the role a value plays, not for a size, so controls and
surfaces can be shaped independently.

| Token | Default | Applies to |
|-------|---------|------------|
| --control-radius | 0.375rem | Buttons, inputs, selects, textareas, badges, menu items, pagination links, calendar days, sidebar items |
| --surface-radius | 0.5rem | Cards, alerts, popovers, toasts, tables, stats, empty, calendar, drawer, the sidebar inset |
| --mark-radius | 4px | The checkbox box |
| --pill-radius | calc(infinity * 1px) | Radio, switch track |
| --focus-ring-width | 3px | Every focus ring |
| --focus-ring-offset | 0px | Every focus ring |
| --focus-ring-style | solid | Every focus ring |
| --focus-ring-color | *see below* | Every focus ring; invalid fields and destructive buttons override it with the destructive tint |
| --elevation-control | shadow-xs | Inputs, selects, textareas, checkbox, radio |
| --elevation-raised | shadow-sm | Cards, stats cards, floating sidebar, every filled button |
| --elevation-overlay | shadow-md | Dropdown and combobox popovers, the date-picker popover, toasts, the drawer panel |
| --elevation-none | none | Ghost and link buttons, the inset sidebar |
| --label-weight | 500 | Labels, buttons |
| --value-weight | 700 | Stat values |

### `--focus-ring-color` has no single default

The other three focus tokens are declared in the engine's `@theme` block and have
one value each. `--focus-ring-color` is declared nowhere: each rule supplies its
own default as the `var()` fallback, because the right resting colour differs by
family.

| Family | Default when you do not set the token |
|--------|---------------------------------------|
| Buttons, cards, badges, toasts, drawer, pagination, calendar, toggle group, date picker | `var(--ring)` |
| Everything inside the sidebar, and the menu button | `var(--sidebar-ring, var(--ring))` |
| Form fields — input, textarea, select, checkbox, radio | `color-mix(in oklch, var(--ring) 50%, transparent)` |

Setting `--focus-ring-color` once at `:root` overrides all three at the same
time, which is usually what you want — a declared token means no fallback ever
fires. Set it in a narrower scope to keep the families apart.

Two states deliberately outrank a `:root` override, because a state must win: an
`aria-invalid` field (and anything inside `.field_with_errors`) and a
`data-variant="destructive"` button declare `--focus-ring-color` on the element
itself. An element's own custom property beats an inherited one, so those rings
stay on the destructive tint whatever `:root` says. This is the same rule
`--control-fill` follows.

### Never transition `outline-color`

If you write your own component against these tokens, keep `outline-color` out of
its `transition` — and that means not using Tailwind's `transition-colors`, which
includes `outline-color` in v4. A transitioned ring animates from its pre-focus
value, which on a control that has never painted an outline is the initial
`currentColor`: the control's own text colour. On a filled variant that is a
near-white ring for the first 150ms, which is no focus indicator at all on
exactly the controls that matter most. It also makes `getComputedStyle` read the
*previous* colour if you measure right after a `Tab` press, which is a reliable
way to convince yourself a working ring is broken.

Name the properties instead:

```css
transition-property: color, background-color, border-color, text-decoration-color;
```
| --control-fill | transparent | Field background; re-set under .dark |
| --destructive-text | --destructive-foreground | Field error text (`[data-form-part="error"]`) |
| --destructive-border | --destructive | The border on an invalid field |

### `--x` is a fill; `--x-foreground` is the text on that fill

Every `-foreground` token names the colour that sits **on** its pair, never text
on the page. `[data-form-part="error"]` is the one place that distinction bites:
a field error is body text on a card, so painting it with
`--destructive-foreground` is only correct if your palette happens to define that
token as a readable-on-page red.

Both conventions are in the wild, and they are inverses of each other:

| Convention | `--destructive` | `--destructive-foreground` |
|---|---|---|
| Tinted (what `bin/rails g maquina_components:install` writes, matching `--success` / `--warning`) | pale tint | dark readable red |
| Saturated (shadcn-style) | saturated red | near-white |

So error text routes through `--destructive-text`, which defaults to
`--destructive-foreground` — correct under the tinted palette, and one line to
fix under a saturated one:

```css
:root {
  --destructive-text: var(--destructive);
  --destructive-border: var(--destructive);
}
```

`rake maquina:doctor` measures your own tokens and reports
`destructive-error-invisible` if the error text cannot be read against your card.

<!-- preview:shape height:520 -->

## Flat theme in six lines

```css
:root {
  --elevation-control: none;
  --elevation-raised: none;
  --elevation-overlay: none;
  --elevation-none: none;
  --control-radius: 0.25rem;
  --surface-radius: 0.25rem;
}
```

Every shadow in the library disappears and every box takes a 4px corner. The
checkbox and the switch keep their own roles, which is the point of separating
them.

## Brutalist theme in twelve lines

```css
:root {
  --control-radius: 0;
  --surface-radius: 0;
  --mark-radius: 0;
  --pill-radius: 0;
  --focus-ring-width: 4px;
  --focus-ring-offset: 3px;
  --focus-ring-color: var(--foreground);
  --elevation-control: none;
  --elevation-raised: none;
  --elevation-overlay: none;
  --label-weight: 700;
  --value-weight: 900;
}
```

Square everything, thicken the ring and push it off the edge, drop every shadow,
and make labels and values shout. No component selector anywhere.

<!-- preview:elevation height:560 -->

## Where the declarations go

Put them in a plain, unlayered `:root` block in your `theme.css` — that is what
the installer generates, and unlayered CSS wins over the engine's `@theme`
defaults whatever the import order.

Do not wrap them in `@theme`: that emits into `@layer theme` alongside the
engine's own defaults, where source order becomes the only tie-breaker. Do not
rename them into Tailwind's namespaces (`--radius-*`, `--shadow-*`) either — a
`@theme { --radius-*: initial }` in an app would wipe them.

```css
/* app/assets/tailwind/theme.css */
:root {
  --surface-radius: 1rem;
}
```

## Recoloring control marks

The checkbox tick, the checkbox dash, the radio dot, the switch thumb and the
select chevron are whole SVG data URIs rather than a color token, and that is
forced by CSS, not a choice: `var()` cannot be interpolated into `url()`, a data
URI is a separate SVG document so `currentColor` never resolves inside it, and
`mask-image` would mask the whole element — box, border and shadow — along with
the glyph. So each mark is exposed as its own property.

| Token | Mark |
|-------|------|
| --checkbox-mark-image | Checkbox tick |
| --checkbox-indeterminate-image | Checkbox dash |
| --radio-mark-image | Radio dot |
| --switch-thumb-image | Switch thumb |
| --select-chevron-image | Select chevron |

They theme like every other token: set one in `:root` (or in any theme block) and
every control picks it up. The engine keeps its own artwork in the use-site
fallback rather than declaring it on the control, precisely so that a global
declaration wins.

```css
:root {
  --checkbox-mark-image: url("data:image/svg+xml,%3csvg viewBox='0 0 16 16' fill='%23ffffff' xmlns='http://www.w3.org/2000/svg'%3e%3cpath d='M8 2l1.8 4.2L14 8l-4.2 1.8L8 14l-1.8-4.2L2 8l4.2-1.8z'/%3e%3c/svg%3e");
}
```

A light `--primary` makes the default white ink measure about 1.15:1 against the
checked fill. If that is a one-off rather than a theme-wide decision, one
attribute fixes it with no CSS at all:

```erb
<%%= f.check_box :terms, data: { component: "checkbox", mark: "dark" } %>
```

`data-mark="dark"` works on the checkbox, radio, switch and select;
`data-mark="light"` is also available on the select. Both are declared on the
control, so an explicit per-instance opt-in beats a global default — which is the
right way round.

The select chevron carries a different default per color scheme, because
gray-500 alone is low-contrast on a dark field. That default is inherited rather
than declared on the control, so one `:root` line still retints it in both
schemes. If you want a different ink per scheme, say so explicitly:

```css
:root      { --select-chevron-image: url("…dark ink…"); }
.dark      { --select-chevron-image: url("…light ink…"); }
```

<!-- preview:marks height:420 -->

## Dark mode

Dark-mode differences are token values too, so you rarely need a `.dark` twin of
a component rule. Set the token inside your own `.dark` block:

```css
.dark {
  --focus-ring-color: color-mix(in oklch, var(--ring) 70%, transparent);
}
```

`--control-fill` is the one to know about: the engine re-declares it under
`.dark` on the fields themselves, so overriding the dark field background needs a
selector that reaches the control.

```css
.dark [data-component="input"],
.dark [data-component="textarea"],
.dark [data-component="select"] {
  --control-fill: oklch(0.2 0.03 260);
}
```

## Pinning one component

Every radius and elevation site also reads a component-level property that falls
back to the role token, so you can pin one component without redefining a role.
Role tokens are the public API; these exist for the one-off.

```css
:root {
  --card-radius: 0.75rem;   /* cards only; everything else stays 0.5rem */
  --toast-shadow: none;     /* toasts only */
}
```

| Property | Falls back to |
|----------|---------------|
| --button-radius, --input-radius, --textarea-radius, --select-radius, --badge-radius, --pagination-radius, --toggle-group-radius, --date-picker-radius, --menu-button-radius, --sidebar-item-radius, --calendar-cell-radius, --combobox-item-radius, --dropdown-menu-item-radius, --toast-action-radius, --toast-close-radius, --drawer-close-radius | --control-radius |
| --card-radius, --alert-radius, --table-radius, --stats-radius, --empty-radius, --fieldset-radius, --calendar-radius, --combobox-radius, --dropdown-menu-radius, --menu-button-content-radius, --date-picker-popover-radius, --sidebar-radius, --inset-radius, --avatar-radius, --toast-radius | --surface-radius |
| --checkbox-radius | --mark-radius |
| --radio-radius, --switch-radius | --pill-radius |
| --card-shadow, --stats-shadow | --elevation-raised |
| --combobox-shadow, --dropdown-menu-shadow, --menu-button-shadow, --date-picker-popover-shadow, --toast-shadow, --toast-hover-shadow, --drawer-shadow | --elevation-overlay |

## Auditing an existing theme

`rake maquina:doctor` scans an app's CSS, views and JavaScript and prints every
place that restates something the token layer now owns, plus the one pattern that
breaks outright. It never edits anything.

```bash
bin/rails maquina:doctor
```

Each finding names the release it came from, so the report stays useful across
upgrades rather than describing one migration. See [upgrading](upgrading.md) for
what changed in each release.
