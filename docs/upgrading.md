# Upgrading

> What breaks between releases, and what to do about it.

## 0.5.1 → 0.6.0

Start here, then run the scanner:

```bash
bundle update maquina-components
bin/rails maquina:doctor
```

`maquina:doctor` reads your CSS, views and JavaScript and prints file:line for
every pattern this release changes, grouped `BREAKING` / `REVIEW` / `CLEANUP`. It
never edits anything and never fails a build.

---

### 1. Your theme.css preflight shim now flattens alert and toast borders

**This affects every existing app.** The `theme.css` shipped by earlier
installers ends with an unlayered universal rule:

```css
/* 0.5.1 — as installed */
* {
  border-color: var(--color-border);
}
```

In 0.6.0 the engine's rules live in `@layer components`. Unlayered CSS outranks
every layer at any specificity, so that one rule now wins over the tinted borders
on all alert and toast variants: a destructive alert's border measures
`oklch(0.928 0.006 264)` — plain `--border` — where 0.5.1 painted
`oklch(0.92 0.05 25)`.

The generator template is fixed, but the rule lives in *your* file. Wrap it:

```css
/* 0.6.0 — one line of nesting */
@layer base {
  * {
    border-color: var(--color-border);
  }
}
```

`maquina:doctor` reports this as `breaking` / `unlayered-universal-rule`. The same
applies to any other unlayered `*` rule you have added.

---

### 2. Utilities passed through css_classes now win

Every engine rule is flattened to specificity 0,1,0 and layered, so a Tailwind
utility passed as `css_classes:` finally takes effect. It used to be silently
swallowed — which means utilities you already pass may start applying.

```erb
<%%= render "components/form", css_classes: "flex" do %>
```

| Site | 0.5.1 | 0.6.0 |
|------|-------|-------|
| Input with a width utility | 448px | 137px |
| Form actions with a hidden utility | display: flex | display: none |
| Form with a flex utility | display: grid | display: flex |

Search your views for `css_classes:` before upgrading. Anything you passed as
decoration and never saw is now live; delete what you did not mean.

---

### 3. Radius and elevation defaults normalize

Radius now comes from four role tokens. Eight sites move:

| Component / part | 0.5.1 | 0.6.0 |
|------------------|-------|-------|
| [data-component="card"] | 12px | 8px |
| [data-sidebar-part="inset"] (variant inset) | 12px | 8px |
| [data-sidebar-part="inset"] [data-component="header"] top corners | 12px | 8px |
| [data-combobox-part="content"] popover | 6px | 8px |
| [data-dropdown-menu-part="content"] popover | 6px | 8px |
| [data-combobox-part="option"] | 4px | 6px |
| [data-dropdown-menu-part="item"] | 4px | 6px |
| [data-toast-part="close"] | 4px | 6px |

Four elevation sites collapse from `shadow-lg` to `--elevation-overlay`, which
resolves to `shadow-md`: the toast, the toast on hover, the drawer panel and the
date-picker popover.

Each site keeps a component-level escape hatch, so any one of them can be pinned
without redefining a role. See [theming](theming.md#pinning-one-component), or
take the whole block from the appendix below.

---

### 4. Focus rings are outlines, and buttons finally have them

Three changes in one:

```css
/* 0.5.1 — a box-shadow ring, on :focus as well as :focus-visible */
[data-component="input"]:focus,
[data-component="input"]:focus-visible {
  box-shadow: 0 0 0 2px var(--background), 0 0 0 4px var(--ring);
}

/* 0.6.0 — an outline, keyboard focus only, from tokens */
[data-component="input"]:focus-visible {
  outline: var(--focus-ring-width) var(--focus-ring-style) var(--focus-ring-color);
  outline-offset: var(--focus-ring-offset);
}
```

- **Form fields no longer ring on a mouse click.** The bare `:focus` half of each
  `:focus, :focus-visible` pair is gone; keyboard focus still rings.
- **Rings are `outline` + `outline-offset`, uniformly 3px at offset 0.** The sites
  that faked a backdrop band with `0 0 0 2px var(--background), 0 0 0 4px var(--ring)`
  lose the band. An outline cannot be clipped by an ancestor's `overflow` and
  never affects layout, which is why the drawer and the sidebar could not use a
  ring before.
- **Six button variants gain a ring they never had.** `:focus-visible` used to be
  declared before the variant rules at equal specificity, so every variant that
  set a background overwrote it: 2 of 16 buttons on the specimen page actually
  ringed. If your app restated a ring on buttons to work around this, delete it.

If a custom component of yours keys off the engine's ring, read the tokens
instead: `--focus-ring-width`, `--focus-ring-offset`, `--focus-ring-style`,
`--focus-ring-color`.

---

### 5. merge_component_data precedence narrows

The component used to win every key it set. Now it wins only its identity keys:
`:component`, `:variant`, `:size`, and any key ending in `_part` or `-part`.
`:controller` and `:action` still concatenate — the component's tokens first, then
yours. Everything else the caller wins.

```erb
<%# 0.5.1: the toast's own state won, this did nothing %>
<%# 0.6.0: renders data-state="exiting" %>
<%%= render "components/toast", title: "Saved", data: { state: "exiting" } %>
```

The merged hash is also `.compact`ed, so a `nil` value emits no attribute at all
where it used to emit an empty one. `false` still renders `"false"` — that is a
value, not an absence.

Related, and also reported by the doctor as `breaking`: a sidebar item now omits
`data-active` entirely when it is inactive, instead of writing
`data-active="false"`. Presence selectors no longer match:

```css
/* before */ [data-sidebar-part="menu-button"][data-active] { }
/* after  */ [data-sidebar-part="menu-button"][data-active="true"] { }
```

```html
<!-- before --> <a data-[active]:bg-accent>
<!-- after  --> <a data-[active=true]:bg-accent>
```

---

### 6. Surfaces above the page stop painting the page color

An alert, a calendar and the date-picker popover painted `--background` — the
page. Anything floating above the page is a surface, so they now paint `--card`
or `--popover`.

If your theme sets those to the same value, nothing moves. That is exactly why
this went unnoticed: in the default light theme all three are white. In the
default dark theme they separate.

```
alert, calendar background (dark)   oklch(0.13 0.028 261) → oklch(0.178 0.032 260)
```

Measured the old way, the calendar sat at ΔL 0.00 against the page — an
invisible surface. Related: the `outline` and `ghost` buttons and the active
pagination link now paint `transparent` instead of `--background`, so they work
inside a card, which they previously did not.

To pin the old behavior, point the surface tokens at the page:

```css
:root {
  --popover: var(--background);
  --card: var(--background);
}
```

> Checking surface-against-surface contrast? Use ΔL on the CIE L\* axis, not a
> WCAG ratio. WCAG contrast is a text metric; on two adjacent large surfaces it
> reads a misleading ~1.1 and tells you nothing.

### 7. Tinted badges lose a stray hairline

Badge's `success` / `warning` / `destructive` variants have always set
`border-color: transparent`. The unlayered `*` shim from step 1 was overriding
it with `--border`, so those badges carried a grey 1px outline they were never
meant to have. Once the shim is layered, the intended transparent border shows
through.

Nothing to do — but if you had compensated for the hairline elsewhere, remove
the compensation.

---

## Appendix: keeping the 0.5.1 look

Everything above is a value, so a single token block reverts the visual changes.
Drop this into your `theme.css` and delete the lines you do not want.

```css
:root {
  /* Radius — the eight sites that moved */
  --card-radius: 0.75rem;
  --inset-radius: 0.75rem;
  --combobox-radius: 0.375rem;
  --dropdown-menu-radius: 0.375rem;
  --combobox-item-radius: 0.25rem;
  --dropdown-menu-item-radius: 0.25rem;
  --toast-close-radius: 0.25rem;

  /* Elevation — the four sites that collapsed shadow-lg → shadow-md */
  --toast-shadow: 0 10px 15px -3px rgb(0 0 0 / 0.1), 0 4px 6px -4px rgb(0 0 0 / 0.1);
  --toast-hover-shadow: 0 10px 15px -3px rgb(0 0 0 / 0.1), 0 4px 6px -4px rgb(0 0 0 / 0.1);
  --drawer-shadow: 0 10px 15px -3px rgb(0 0 0 / 0.1), 0 4px 6px -4px rgb(0 0 0 / 0.1);
  --date-picker-popover-shadow: 0 10px 15px -3px rgb(0 0 0 / 0.1), 0 4px 6px -4px rgb(0 0 0 / 0.1);

  /* Focus ring — the closest outline equivalent of the old two-step ring */
  --focus-ring-width: 2px;
  --focus-ring-offset: 2px;
}
```

Two things this block cannot bring back, because they are not values:

- The **backdrop band**. The old ring drew `--background` under `--ring` inside a
  single `box-shadow`; an outline is one line. `--focus-ring-offset: 2px` leaves
  the same gap, showing whatever is actually behind the control.
- The **mouse-click ring** on form fields, and the **absent ring** on five button
  variants. Both were `:focus-visible` bugs, and both are fixed on purpose.

Running `rails generate maquina_components:install` again is safe: it is
idempotent, appends the token block only once, and never rewrites your palette.
