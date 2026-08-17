# Upgrading

> What breaks between releases, and what to do about it.

## 0.7.0 → 0.7.1

No API changes. Four fixes reported by a consuming app, all of which either
correct themselves on upgrade or take one line of theme CSS.

```bash
bundle update maquina-components
bin/rails maquina:doctor
```

The doctor gained five rules for this release, and every finding is now tagged
with the release it came from.

### A required field with no placeholder no longer paints the error state

The invalid rule for `input` and `textarea` was keyed on
`:invalid:not(:placeholder-shown)`. That guard only works on a field that *has* a
placeholder: without one `:placeholder-shown` never matches, so its negation is
always true and an empty `required` field matched `:invalid` from first paint —
red before focus, before blur, before submit, and with no `aria-invalid`, so the
visual and assistive channels disagreed. The same shape applied to the date
picker through a bare `input:invalid`.

Both now key on `:user-invalid`, which only matches once the reader has actually
interacted with the field. The destructive outline is also gated behind
`:focus-visible` now, rather than painting a permanent halo on a resting field.

**If you were relying on the old behaviour** — that is, you render server-side
errors and never set `aria-invalid` — the border will stop appearing. Set it
explicitly:

```erb
<%= f.email_field :email, data: { component: "input" },
    aria: { invalid: @user.errors[:email].any? } %>
```

The doctor reports this as `breaking` / `invalid-styling-without-aria`, and
flags remaining required-without-placeholder fields as `review` /
`required-without-placeholder`.

### Field error text has its own colour token

`[data-form-part="error"]` painted `--destructive-foreground`, which is the
colour meant to sit **on** a destructive fill — every other use of that token in
the engine pairs it with a `--destructive` background. A field error is text on
a card, so under a saturated (shadcn-style) palette it rendered near-white on
white and the message was simply not there.

It now reads `--destructive-text`, defaulting to `--destructive-foreground`, and
the invalid border reads `--destructive-border`, defaulting to `--destructive`.

**Nothing to do if you use the palette the installer wrote.** If your
`--destructive` is a saturated red and `--destructive-foreground` is near-white,
add two lines:

```css
:root {
  --destructive-text: var(--destructive);
  --destructive-border: var(--destructive);
}
```

The doctor measures your actual tokens against your `--card` and reports
`breaking` / `destructive-error-invisible` when the error text cannot be read. If
you worked around this with your own `text-destructive` utility, it reports
`cleanup` / `destructive-error-workaround`.

### The dropdown menu and menu button flip when they hit the fold

Neither controller measured anything, so a trigger near the bottom of the window
opened straight past it — and because the clipped items are the ones at the *end*
of the menu, the destructive action was the first thing to disappear. Both now
measure on open and set `data-side` themselves. The CSS for every side already
shipped; nothing was choosing one.

If you carry your own flip controller, you can delete it — the doctor reports it
as `cleanup` / `app-level-dropdown-flip`.

### Every leaf partial accepts a block

Nine leaf partials rendered `text || content` and silently dropped a block, while
nine others accepted one — so `render "components/alert" do … end` worked and
`render "components/alert/title" do … end`, one line below it, produced an empty
element with no error. All eighteen now take `text:`, `content:` or a block
interchangeably, and `text: ""` consistently falls through to the block rather
than rendering empty in half of them.

This is additive: anything that worked before still works.

---

## 0.6.1 → 0.7.0

No breaking changes and nothing to migrate — an accessibility release. One
deprecation, and a good deal of host-side code you can now delete.

```bash
bundle update maquina-components
```

### What changes on its own

- **Focus rings appear instantly.** They used to fade in over 150ms from the
  control's own text colour, because every component painting a token ring also
  carried `transition-colors` and Tailwind v4 folds `outline-color` into that
  utility. On a filled variant that meant a near-white ring for the first frames
  — no visible focus indicator on the highest-stakes controls in a page. If you
  built your own components against `--focus-ring-*`, they have the same latent
  bug; see [theming](theming.md#never-transition-outline-color).
- **Two triggers gain the chevron they never had.** The dropdown menu trigger and
  the combobox trigger both asked for icon names the engine did not ship, and
  rendered nothing. Any `as_child` trigger you wrote *purely* to supply a chevron
  can collapse back to the default path — but keep the ones carrying their own
  content.
- **A collapsed off-canvas sidebar leaves the tab order,** and below 768px the
  sidebar reserves no layout. Both are structural now; see
  [sidebar](sidebar.md#accessibility).
- **Breadcrumbs collapse on available space.** The width measurement never
  actually fired before — the last item's flex-shrink absorbed the overflow, so
  the row reported a perfect fit at every width.

### Deprecated: `collapse_after`

`responsive_breadcrumbs(..., collapse_after: 3)` still accepts the argument and
now ignores it. It existed only to fake collapsing while the measurement was
broken, and it collapsed on item count alone — so it also collapsed a trail with
plenty of room. Delete it from your calls; it goes away in 0.8.0.

```erb
<%%# before %>
<%%= responsive_breadcrumbs(links, current, collapse_after: 3) %>

<%%# after %>
<%%= responsive_breadcrumbs(links, current) %>
```

### Workarounds you can delete

Several apps carry host-side code for the bugs above. Deleting it is the right
outcome, not keeping it:

- a restated focus ring on buttons — especially a `box-shadow` one on a filled
  variant, which collides with the elevation each variant declares and is clipped
  by any `overflow-hidden` ancestor
- a low-specificity `:focus-visible` baseline standing in for engine rings that
  "did not paint", and any rule restoring the ring on breadcrumb links
- a controller setting `inert` on the sidebar when it is off-canvas
- an unlayered `@media (width < 768px)` rule forcing the sidebar gap to 0

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

/* 0.6.0 onward — an outline, keyboard focus only, from tokens.
   Written as longhands since 0.7.0: the shorthand is invalid at
   computed-value time as a unit, so one unresolvable var() took the
   whole ring down and left outline-color: currentColor behind. */
[data-component="input"]:focus-visible {
  outline-width: var(--focus-ring-width);
  outline-style: var(--focus-ring-style);
  outline-color: var(--focus-ring-color);
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
