# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

Four follow-ups from the same consumer app whose reports drove 0.7.0. No API
changes; two of the four correct themselves on upgrade.

### Fixed

- **A `required` field with no `placeholder` painted the error state on first
  paint.** The invalid rule for `input` and `textarea` was keyed on
  `:invalid:not(:placeholder-shown)`. That guard only does anything on a field
  that *has* a placeholder: without one `:placeholder-shown` never matches, so
  its negation is unconditionally true and an empty `required` field matched
  `:invalid` from load — red before focus, before blur, before submit. There was
  no `aria-invalid` alongside it, so sighted users saw a rejection they had not
  earned while screen-reader users were told nothing; the two channels
  disagreed. `date_picker.css` had the same shape through a bare
  `input:invalid`, with no guard at all.

  All four now key on `:user-invalid`, which is the standardised form of the
  behaviour that guard was reaching for — it matches only after the reader has
  actually interacted with the field. It also fixes a second symptom nobody had
  reported: on an `email` or `url` field *with* a placeholder, typing removes
  `:placeholder-shown`, so the field went red mid-word.

  The destructive outline is now gated behind `:focus-visible` like every other
  ring in the engine. It was painting a permanent 3px halo on a resting field,
  not just a border
- **Field error text used the on-fill foreground token.**
  `[data-form-part="error"]` painted `--destructive-foreground` — the colour
  meant to sit *on* a destructive fill, which is how every other use of that
  token in the engine reads it. A field error is text on a card.

  The root cause was ours and it was bigger than the one rule: the engine has
  been shipping **two inverted definitions of the same token pair**. The install
  generator writes `--destructive` as a pale tint with `--destructive-foreground`
  as the dark readable red (matching `--success` and `--warning`), while the
  palette in `docs/getting-started.md` wrote the shadcn convention — saturated
  fill, near-white foreground. `form.css` silently depended on both at once: the
  error text only worked under the first, and the invalid *border* only worked
  under the second. Under the docs palette the error message rendered near-white
  on white and was simply not there; under the generator palette the invalid
  border was a pale tint against a pale border and equally invisible.

  Error text now reads `--destructive-text` (defaulting to
  `--destructive-foreground`) and the invalid border reads `--destructive-border`
  (defaulting to `--destructive`), using the same use-site-fallback idiom
  `--focus-ring-color` and `--control-fill` already use. Apps on the generator's
  palette need no change. Apps on a saturated palette set two lines; see
  [docs/theming.md](docs/theming.md). The docs palette now ships them
- **The dropdown menu and menu button opened past the bottom of the viewport.**
  Neither controller measured anything — 243 lines with no
  `getBoundingClientRect` — so a trigger near the fold opened straight through
  it. Because the clipped items are the ones at the *end* of the menu, the
  destructive action was the first thing to disappear, which is the worst
  available failure ordering: a reader who cannot see Delete concludes the row
  cannot be deleted. Both halves of the fix already shipped — the CSS styles all
  four sides — but nothing chose a side from geometry.

  Both controllers now measure on open and set `data-side` themselves. Two
  details that are easy to get wrong and are built in: the measurement resets to
  the authored placement first, so a menu flipped in a short window unflips once
  the window grows; and it runs inside a `requestAnimationFrame`, because the
  controller sets `data-state` and paints in the same tick and a synchronous
  read returns the pre-open box
- **Nine leaf partials silently dropped a block.** `alert/_title`,
  `alert/_description`, `card/_title`, `card/_description`, `combobox/_label`,
  `drawer/_title`, `drawer/_description`, `toast/_title` and
  `toast/_description` rendered `text || content`, while nine others accepted a
  block — so `render "components/alert" do … end` worked and
  `render "components/alert/title" do … end`, one line below it, produced an
  element with correct classes, correct data attributes and no content. No
  error, no warning, no missing-local exception. In a form or a toast that is a
  message that is simply absent, which is the failure mode least likely to be
  caught in review.

  All eighteen leaf partials now resolve `text.presence || content || yield`.
  That also settles a third inconsistency nobody had reported: the block-aware
  half was itself split between `text ||` and `text.presence ||`, so `text: ""`
  rendered empty in four partials and fell through to the block in five. It now
  falls through everywhere. The change is additive — `yield` is only reached
  when both locals are nil, which rendered empty before

### Added

- `--destructive-text` and `--destructive-border`, so field error text and the
  invalid field border can be themed independently of the destructive *fill*.
  Both default to today's values
- `maquina:doctor` gained five rules for this release, and now tags every
  finding with the release it came from rather than describing a single 0.6.0
  migration:
  - `destructive-error-invisible` (breaking) — measures your own
    `--destructive-foreground` against your own `--card` and reports when field
    errors cannot be read. It measures the symptom rather than guessing the
    convention: a tinted palette's *dark* block has the same numeric shape as a
    saturated palette's *light* block, so a rule keyed on lightness alone would
    fire on every app that ran our own generator
  - `invalid-styling-without-aria` (breaking) — an app that renders errors but
    never sets `aria-invalid` was relying on the `:invalid` fallback and will
    lose its error border on upgrade
  - `required-without-placeholder` (review) — matched against a whole tag rather
    than a line, since Rails form helpers routinely span five or six
  - `destructive-error-workaround` (cleanup) — a hand-rolled `text-destructive`
    on top of the engine's error part
  - `app-level-dropdown-flip` (cleanup) — an app-owned dropdown collision
    controller that 0.7.1 makes redundant

### Changed

- The `maquina-ui-standards` skill sets `aria-invalid` in its form examples. Its
  quick-start patterns rendered the error paragraph without it, which is what
  led apps to depend on the `:invalid` styling this release narrows

## [0.7.0] - 2026-08-15

An accessibility release, from two reports filed by a consumer app. Every focus
ring in the engine appeared 150ms late and faded in from the control's own text
color; two triggers had been shipping with no chevron at all; and a collapsed
mobile sidebar stayed in the tab order while reserving a sidebar's width of
layout. No API changes — if you carry workarounds for any of the below, this
release is an invitation to delete them.

### Fixed

- **Focus rings now appear instantly, in the right color.** Every component that
  paints a token ring also carried `transition-colors`, and Tailwind v4 folds
  `outline-color` into that utility. `outline-width`, `-style` and `-offset` are
  not in its property list, so they applied immediately while the *color*
  animated over 150ms from its pre-focus value — which, on a control that has
  never painted an outline, is the initial `currentColor`: the control's own text
  color. On a ghost or outline button that looked correct by accident; on a
  filled variant (near-white text on a saturated fill) the ring was near-white
  for the first frames, i.e. no visible focus indicator on the highest-stakes
  controls in a page. Sixteen rules dropped `transition-colors` for an explicit
  `transition-[color,background-color,border-color,text-decoration-color]`.

  The same transition is why `--focus-ring-color` was reported as an inert token:
  a `getComputedStyle` read taken right after a `Tab` press returns the previous
  color. The token was working. If you wrote your own component against the focus
  tokens, it has the same latent bug — see [docs/theming.md](docs/theming.md)
- Focus rings are written as `outline-width` / `-style` / `-color` longhands
  rather than the `outline` shorthand, at all 30 sites. The shorthand is invalid
  at computed-value time as a unit: one unresolvable `var()` reset all three
  longhands to their initial values and took the whole ring down, and
  `outline-color: currentColor` looks plausible enough on a dark-text control
  that nobody reports it
- **Breadcrumb links had no focus ring** — `:focus-visible` applied `outline-none`
  and substituted an underline, which was also its hover treatment, so on a page
  whose breadcrumbs are the only keyboard stops nothing appeared to happen. The
  ring is restored and the underline kept. The breadcrumb ellipsis is a dropdown
  trigger and had no focus rule at all; it has one now
- **The combobox search field had no focus ring.** It clears its outline in the
  base rule and never painted one back, despite being the tab stop the popover
  opens onto
- **The dropdown menu trigger rendered no chevron.** It asks
  `builtin_icon_for :chevron_down`, and the engine's built-in set had no
  `chevron_down` — so the default trigger read as a static text label with
  everything behind it undiscoverable. `chevron_down` now ships
- **The combobox trigger rendered no chevron either**, for a different reason: it
  asked for `:chevrons_up_down` (plural) against a singular `:chevron_up_down`
  built-in. The call site is fixed and the plural now resolves as an alias
- **`apply_icon_options` silently dropped `data:`.** It handled only `class:` and
  `stroke_width:`, so `data-dropdown-menu-target="chevron"` never reached the DOM
  and the chevron-rotation rules in `dropdown_menu.css` were dead. Fixing the icon
  name alone would not have restored the affordance
- **A collapsed off-canvas sidebar stayed in the tab order.** It is parked at
  `left: calc(var(--sidebar-width) * -1)` with `visibility: visible`, so a phone
  user tabbed through every off-screen link before reaching page content — focus
  landing where no pointer can go. The container now carries `inert` for exactly
  the off-canvas-collapsed case, server-side as well as from the controller, so
  the invariant holds before Stimulus connects. A `collapsible: "icon"` sidebar is
  a visible rail and stays reachable. `inert` rather than `aria-hidden`: the
  latter hides the subtree from the accessibility tree while leaving it focusable
- **The sidebar gap reserved a sidebar's width of layout on phones.**
  `[data-sidebar-part="gap"]` only dropped to 0 under
  `[data-collapsible="offcanvas"]`, and the controller computes
  `isOpen ? "none" : (isMobile ? "offcanvas" : "icon")` — `isOpen` wins over
  `isMobile`. So a phone load carrying an expanded `sidebar_state` cookie rendered
  a ~102px content column until the mobile check ran and a 200ms width transition
  finished, on every mobile load; a desktop window narrowed past 768px kept that
  column permanently; and a sidebar *opened* on a phone reserved the full width
  behind its own overlay. A `@media (width < 768px)` rule now zeroes it
  structurally, so no JS has to have run
- `menu_button`'s ring fell back to `var(--sidebar-ring)` with no `var(--ring)`
  arm, so it had no color in a theme that defines only the base palette
- **The responsive breadcrumb collapsed on item count, never on available
  space — and in the default configuration never collapsed at all.** Every item
  was `shrink-0` so that `scrollWidth` could exceed `clientWidth`, but the last
  item was then given `shrink min-w-0`, which is exactly the case that rule
  existed to prevent: flex resolves a deficit by shrinking a shrinkable item
  *before* it lets the line overflow, so the current-page label absorbed the
  whole deficit down to 0px and the row reported a perfect fit at every width.
  Measured: content wanting 430px in a 300px container reported zero overflow.
  The bar silently clipped instead of collapsing. `collapse_after` was added in
  0.4.4 to work around this by counting items, which meant it collapsed a trail
  with metres of room to spare. The controller now pins the last item to its
  natural width for the duration of a measurement, so the row reports the space
  it actually wants, and collapses only when it genuinely does not fit
- The breadcrumb hid middle items from the *back*, nearest the current page,
  while the ellipsis renders immediately after the *first* item — so the `…`
  stood in front of items it did not represent and its dropdown listed the tail
  rather than the head. It now hides from the front
- The breadcrumb collapsed everything when it happened to be measured at zero
  width — inside a collapsing sidebar, a Turbo Frame mid-swap, an unshown tab
  panel — and nothing scheduled a re-measure. A zero-width container is now read
  as "not laid out yet" rather than as infinite overflow
- The breadcrumb watched `window.resize`, so a container that changed width on
  its own never re-fit. Collapsing this engine's own sidebar re-flows the header
  without resizing the window, and the trail kept a stale state until something
  else happened to fire a resize. It now uses a `ResizeObserver` on the list,
  re-fits once on `document.fonts.ready`, and re-fits on `turbo:morph` (morphing
  does not replace the element, so `connect()` never re-ran)
- The breadcrumb compared integer-rounded widths with no tolerance, so a 0.4px
  shortfall collapsed a row that visually fits. There is a 1px buffer now
- **The breadcrumb's last item never truncated with an ellipsis.**
  `text-overflow` has no effect on a flex container's own box and the item was
  `inline-flex`, so a long current-page title hard-clipped mid-word — "A Very
  Long Current Pag". 0.4.3 traded away working collapse detection for a graceful
  truncation that never rendered. The inner element is `display: block` now, so
  it truncates as intended
- Removed a dead `@media (max-width: 640px)` breadcrumb rule keyed on
  `[data-auto-collapse]`, which nothing in the engine emits. It was a third,
  viewport-only collapse mechanism that would have pre-hidden items behind the
  controller's back

### Changed

- `builtin_icon_for` raises `MaquinaComponents::UnknownIconError` under
  `strict_icons` (development and test by default) instead of returning `nil`,
  the way `icon_for` already did. An engine component asking for an icon the
  engine does not ship is unfixable from an app — `builtin_icon_for` deliberately
  never consults `main_icon_svg_for` — so silence was the wrong default. The error
  message says so, rather than sending you to an override that cannot help

### Deprecated

- `collapse_after:` on `responsive_breadcrumbs` and the breadcrumbs partial. It
  existed only to fake collapsing while the width measurement was broken, and it
  collapses without consulting available width, which is the opposite of what
  the component is for. Still accepted so existing calls do not raise, now
  ignored, removed in 0.8.0 — delete it from your calls

### Added

- Stylesheet guards: no rule may transition `outline-color` (`transition-colors`
  is banned outright, since v4 always folds it in), and a part that clears its
  outline must restore a token ring unless it is listed as roving-focus
- Breadcrumb guards: the measuring class must exist in both the controller and
  `breadcrumbs.css` and must pin the last item with `flex-shrink: 0` (a rename on
  either side silently restores the never-collapses bug with no visible symptom),
  and the controller must observe its container rather than the window. Plus the
  first render tests this component has ever had: the trail renders fully
  expanded with a hidden ellipsis, the ellipsis sits ahead of the items it stands
  for, and `collapse_after` reaches the DOM no more
- An icon guard that renders every literal `builtin_icon_for` call site in the
  engine's views and asserts the name resolves — the sweep that names both
  chevron bugs in one failure
- Render tests asserting the dropdown and combobox triggers each emit exactly one
  chevron, and that the dropdown's carries the target attribute its rotation CSS
  keys off

### Docs

- [docs/theming.md](docs/theming.md): `--focus-ring-color` has no single default —
  the three per-family defaults are documented, along with the two states that
  deliberately outrank a `:root` override, and a warning never to transition
  `outline-color` in your own components
- [docs/dropdown_menu.md](docs/dropdown_menu.md): the default trigger renders its
  own chevron; `as_child` is for different content, not for an affordance, and it
  hands you the aria attributes to write yourself
- [docs/breadcrumbs.md](docs/breadcrumbs.md): what `responsive:` actually
  guarantees, the deprecation of `collapse_after` and why, and the ellipsis
  dropdown — which has existed since 0.4.3 and was never documented
- [docs/getting-started.md](docs/getting-started.md): what the
  `main_icon_svg_for` override reaches and what it deliberately does not — two
  consumer apps lost an investigation each to the fact that an engine
  component's own icons never consult it — plus `strict_icons`, which has been
  on in development since 0.6.0 and was documented nowhere
- [docs/sidebar.md](docs/sidebar.md): an Accessibility section covering the
  `inert` off-canvas sidebar and the zero-width mobile gap, both of which apps
  were working around by hand
- [docs/combobox.md](docs/combobox.md): the trigger renders its own chevron and
  the search field rings on focus
- [docs/upgrading.md](docs/upgrading.md): the ring example shows longhands, the
  form the engine actually emits

### Workarounds you can now delete

If your app carries any of these, this release removes the reason for them.
Delete rather than keep — several are the exact patterns the engine's own guard
tests now forbid.

- A restated focus ring on buttons, especially a `box-shadow` one on a filled
  variant. Uncomment your `--focus-ring-color` and drop the shadow; a box-shadow
  ring collides with the elevation each variant declares and is clipped by any
  `overflow-hidden` ancestor, which is why the engine does not use one
- A 0,0,0 `:focus-visible` baseline in `@layer components` standing in for
  engine rings that "did not paint"
- A higher-specificity rule restoring the ring on breadcrumb links
- `as_child` hand-written dropdown triggers that exist *only* to supply a
  chevron. Keep the ones that carry their own content — icons, `sr-only` labels,
  a `title` — since `as_child` still hands you the whole button
- A controller that sets `inert` on the sidebar for the off-canvas-collapsed case
- An unlayered `@media (width < 768px)` rule forcing `[data-sidebar-part="gap"]`
  to 0


## [0.6.1] - 2026-07-27

A `maquina:doctor` fix. No component, CSS or API changes — if the doctor
reported findings for you on 0.6.0, its report was correct and nothing here
changes it.

### Fixed

- `maquina:doctor` scanned zero files, and reported `No at-risk patterns found`,
  when the app's own path contained a directory named `tmp`, `vendor`,
  `node_modules` or `coverage`. The exclusion list names directories *inside* an
  app, but it was matched against the absolute path, so the root's own prefix
  could match it and reject every file. A migration scanner that says *clean*
  when it means *nothing* is worse than one that errors, so re-run
  `bin/rails maquina:doctor` on 0.6.1 if your checkout sits under any of those
  names — the "Scanned N files" line in the report header is the tell

### Docs

- The README now warns about the 0.6.0 breaking changes under the tagline,
  naming the unlayered `theme.css` shim that affects every existing app and
  fails silently, and `Upgrading` is a top-level section rather than a
  subsection of `Generator Options`

## [0.6.0] - 2026-07-27

A theming release. Shape, focus rings, elevation and weight become design tokens, every engine rule moves into `@layer components` at specificity 0,1,0, and a set of long-standing CSS and rendering defects are fixed. Read [docs/upgrading.md](docs/upgrading.md) before upgrading, then run `bin/rails maquina:doctor` — it prints file:line for every pattern this release changes and never edits anything.

### Breaking changes

See [docs/upgrading.md](docs/upgrading.md) for the full migration, including an appendix that reverts every visual change with one token block.

1. **The `* { border-color }` shim in your installed `theme.css` must be wrapped in `@layer base`.** This affects every existing app and fails silently. Engine rules now live in `@layer components`, and unlayered CSS outranks every layer at any specificity, so that one universal rule wins over the tinted borders of all alert and toast variants: a destructive alert's border measures plain `--border` where 0.5.1 painted the destructive tint. The generator template is fixed, but the rule lives in your file. `maquina:doctor` reports it as `breaking` / `unlayered-universal-rule`.
2. **Utilities passed through `css_classes:` now win.** Flattening every rule to 0,1,0 inside a layer means a Tailwind utility finally applies where it used to be swallowed. Measured on the specimen pages: an input with a width utility goes `448px → 137px`, form actions with a hidden utility go `display: flex → none`, and a form with a flex utility goes `display: grid → flex`. Search your views for `css_classes:` and delete what you passed as decoration and never saw.
3. **Radius and elevation defaults normalize.** Card, the inset sidebar panel and the inset header's top corners go 12px → 8px; the combobox and dropdown popovers 6px → 8px; the combobox option, dropdown item and toast close 4px → 6px. Four elevation sites collapse `shadow-lg` → `--elevation-overlay` (= `shadow-md`): the toast, the toast on hover, the drawer panel and the date-picker popover. Every site keeps a component-level escape hatch, so any one can be pinned without redefining a role.
4. **Focus rings are outlines, and six button variants gain a ring they never had.** Form fields no longer ring on a mouse click — the bare `:focus` half of each `:focus, :focus-visible` pair is gone. Rings are `outline` + `outline-offset`, uniformly 3px at offset 0, read from `--focus-ring-*`; the sites that faked a backdrop band with `0 0 0 2px var(--background)` lose the band. If your app restated a ring on buttons to work around the old bug, delete it.
5. **Components that sit above the page stop painting the page color.** An alert, a calendar and the date-picker popover painted `--background`; they now paint `--card` / `--popover`. In a theme where those are the same value nothing moves, which is why this was invisible in the default light theme — but in the default dark theme the alert and calendar backgrounds go `oklch(0.13 0.028 261)` → `oklch(0.178 0.032 260)`. This was measured as ΔL 0.00 against the page before, i.e. an invisible surface. Relatedly, the `outline` and `ghost` buttons and the active pagination link now paint `transparent` rather than `--background`, so they finally work inside a card. Use ΔL on the L\* axis, not a WCAG contrast ratio, if you are checking surface-against-surface: WCAG is a text metric and reads a misleading ~1.1 on two adjacent large surfaces.
6. **Tinted badges lose a stray hairline.** Badge's `success` / `warning` / `destructive` variants set `border-color: transparent`, which the unlayered `*` shim had been overriding with `--border`. With the shim layered (break 1) the intended transparent border shows through, so those badges no longer carry a grey 1px outline they were never meant to have.
7. **`merge_component_data` precedence narrows to identity keys.** The component now wins only `:component`, `:variant`, `:size` and any `*_part` key; `:controller` and `:action` still concatenate (component tokens first, then yours); the caller wins everything else. The merged hash is compacted, so a `nil` value emits no attribute where it used to emit an empty one — `false` still renders `"false"`. Related: a sidebar item omits `data-active` entirely when inactive instead of writing `data-active="false"`, so `[data-active]` presence selectors must become `[data-active="true"]`.

### Added

- Design tokens for everything that is not a color — shape (`--control-radius`, `--surface-radius`, `--mark-radius`, `--pill-radius`), focus ring (`--focus-ring-width` / `-offset` / `-style` / `-color`), elevation (`--elevation-control` / `-raised` / `-overlay`) and weight (`--label-weight`, `--value-weight`) — plus a component-level escape hatch at every radius and elevation site. All 63 `rounded-*` sites, every focus ring and the five control marks now read from them. Documented in [docs/theming.md](docs/theming.md)
- `rake maquina:doctor`: scans an app's CSS, views and JavaScript and prints file:line for every pattern this release changes, grouped `BREAKING` / `REVIEW` / `CLEANUP`. Advisory only — it never edits anything and always exits 0
- A `components/label` partial, so `[data-required]` finally has something that emits it
- `icon_for` name aliases and a `strict_icons` configuration option that raises on an unknown icon instead of rendering nothing
- Drawer triggers accept `for_id:`, so a page can drive more than one drawer
- Specimen previews for shape, elevation, marks and states, plus `?shape_theme=brutal|soft` on the preview pages — both themes are token declarations only, which is the claim the previews exist to prove
- Stylesheet guard tests (`test/stylesheets/`): token fallbacks, no hardcoded radii, outline-only focus rings, state-after-variant source order, `@layer components` completeness, no `prefers-color-scheme` or `.dark` property overrides, plus compiled-output checks for token survival, layer order and cross-file rule order
- A docs/previews contract test: every `<!-- preview:NAME -->` tag in `docs/*.md` must resolve to a preview template, so a rename cannot silently 404 a live documentation page

### Fixed

- The button focus ring: `:focus-visible` sat before the variant rules at equal specificity, so each variant's own `box-shadow` overwrote it. 2 of 16 buttons on the specimen page actually ringed; now all 14 focusable ones do
- The badge and card focus bands used `--border`, which measures 1.11:1 against the page — they now use `--ring`
- Removed the lone `@media (prefers-color-scheme: dark)` block, which flipped one component against the host's explicit `.dark` choice
- Added `align-content: start` to the form grids, which stretched rows to fill the container
- Every stylesheet moved into `@layer components` and flattened to specificity 0,1,0 with `:where()`, base selectors un-grouped from variants, and imports reordered primitives-before-composites — alphabetical order had put the composites' button-carrying triggers ahead of `form.css`, so the button base silently won over each of them
- `dropdown_menu_simple` raised `NoMethodError` and `combobox_simple` rendered an empty popover; both had zero call sites in the repo, which is why they shipped
- `_table` and `calendar/_week` built a correct data hash and then threw it away, leaving `[data-variant="bordered"]` unreachable
- Sidebar items expose `aria-current="page"` when active
- The installed theme's `* { border-color }` preflight shim is generated inside `@layer base`
- The five control-mark defaults moved from element-level declarations into use-site fallbacks, so a `:root` override can reach them

### Docs

- [docs/theming.md](docs/theming.md): role tokens, flat and brutalist themes in a dozen lines each, recoloring control marks, dark mode, pinning one component
- [docs/upgrading.md](docs/upgrading.md): the seven breaking changes with measurements, and an appendix that restores the 0.5.1 look

## [0.5.1] - 2026-07-20

A bugfix release that polishes the component contract, tightens rendering edge cases, and aligns docs and tests with the actual library. No new public API and no breaking changes.

### Fixed

- Fix `stats_grid` responsive columns under Tailwind v4
- Use deterministic fallback IDs in combobox and date_picker to avoid duplicate-ID collisions across re-renders
- Fix `menu_button` component and remove the dead animations stylesheet that referenced it
- Guard the importmap initializer and fix a typo in the assets initializer
- Constrain toaster variant and duration interpolation to valid values; restore missing server-side toast icons
- Add dialog accessibility to the drawer and sync open/close state with its triggers
- Bring the separator up to the component conventions and document it
- Bring stats and `simple_table` up to the component contract (attribute passthrough, variant split)
- Give empty `title`/`description` the standard `content:` parameter so they render consistently
- Replace `block_given?` fallbacks with the `text:`/`content:` parameter convention across leaf partials

### Changed

- Unify the variant and size vocabulary across components for consistent naming
- Move imperative positioning to modern CSS and finish the inline-Tailwind cleanup
- Declare `importmap-rails` and `stimulus-rails` as runtime dependencies so the engine boots without manual gem additions
- Allow callers to extend `data-controller`/`data-action` on components instead of overwriting them

### Docs / Tests / CI

- Add component render tests and preview smoke tests
- Build the dummy app's Tailwind CSS in CI before running tests
- Align the README with the actual library
- Clarify the table docs: attribute passthrough, variant split, `simple_table`

## [0.5.0] - 2026-07-12

### Added

- Add Drawer component with trigger and keyboard shortcut support (#21)
  - Slide-out panel with `provider`, `header`, `content`, `footer`, `trigger`, and `close` sub-partials; left/right side, overlay backdrop, cookie persistence
  - `Cmd/Ctrl+D` keyboard shortcut and full Turbo Drive/Morph compatibility
  - `drawer_state`, `drawer_open?`, `drawer_closed?` helpers; `docs/drawer.md`
- Add `scaffold_templates` generator (#20)
  - `rails g maquina_components:scaffold_templates` copies ERB scaffold templates to `lib/templates/erb/scaffold/` so `rails g scaffold` produces maquina_components-styled views (index, show, new, edit, _form, partial)
- Include engine helper modules in the generated helper template (#19)
  - `MaquinaComponentsHelper` now includes `IconsHelper`, `SidebarHelper`, and `ToastHelper`, so `icon_for`, `sidebar_open?`, `toast_flash_messages`, etc. are available in host-app views without extra configuration

### Fixed

- Improve icon class handling in `apply_icon_options` (#17)
  - Guard against nil options and non-string `class` values; HTML-escape classes
  - Inject a `class` attribute on `<svg>` elements that don't already have one

### Contributors

Thanks to the contributors who made this release possible:

- [@GregorioNeto](https://github.com/GregorioNeto) — Drawer component (#21), icon class handling (#17)
- [@JuanVqz](https://github.com/JuanVqz) — scaffold_templates generator (#20), engine helper modules in generated helper (#19)

## [0.4.4] - 2026-03-09

### Added

- Add configurable `collapse_after` threshold to responsive breadcrumbs (#16)
  - New `collapse_after:` parameter on `responsive_breadcrumbs` helper and `_breadcrumbs.html.erb` partial
  - Count-based collapsing force-hides middle items when total breadcrumb count exceeds the threshold, fixing cases where CSS text truncation absorbs overflow before JS can detect it
  - Works alongside existing overflow detection: count-based collapse runs first, then overflow check handles any remaining items

## [0.4.3] - 2026-03-08

### Fixed

- Fix responsive breadcrumb collapsing and add ellipsis dropdown (#15)
  - Toggle adjacent separators when hiding/showing items to prevent orphaned double separators
  - Allow last breadcrumb item to truncate with text-overflow ellipsis instead of hard-clipping
  - Add portal dropdown on ellipsis click showing hidden items as clickable links, with click-outside and Escape to close

## [0.4.2] - 2026-03-08

### Changed

- Separate internal icons from public `icon_for` API (#14)
  - Internal component views (toast, combobox, calendar, breadcrumbs, etc.) now use `builtin_icon_for` which always renders from the engine's built-in SVG set
  - Public `icon_for` checks app override first (`main_icon_svg_for`), falling back to built-in SVGs, letting apps use their own icon system (Tabler, Heroicons, Lucide, etc.)
  - Components that accept icon names from the app (alert, sidebar menu, empty state, breadcrumb separator) continue using `icon_for`

## [0.4.1] - 2026-03-04

### Fixed

- Fix stats_grid partial path for stats_card (#12)

## [0.4.0] - 2026-02-12

### Fixed

#### Sidebar: Turbo Morph & Turbo Frame compatibility
- Replace random IDs (`sidebar-<random_hex>`) with deterministic `sidebar-left` / `sidebar-right` to fix idiomorph element matching across renders
- Add `turbo:before-morph-element` listener with `_morphing` guard flag to prevent stale server values from overwriting cookie state during morph
- Enhance `handleMorph()` to read the cookie (client truth), reassert correct state, and remove the `sidebar-loading` class that morph re-adds from server HTML
- Add stable `id` to sidebar provider (`sidebar-provider` by default)

#### Sidebar: Layout shift fix
- Add CSS rule scoped to `@media (min-width: 768px)` that overrides the gap width during `sidebar-loading` phase when sidebar state is `expanded`, eliminating the layout shift before Stimulus initializes

#### Partials: Replace yield with explicit content parameter
- Add `content: nil` parameter to 9 partials and replace `yield` with `content` to fix Rails partial rendering bug where `yield` silently renders entire page content when no explicit block is passed
  - card/title, card/description
  - alert/title, alert/description
  - toast/title, toast/description
  - combobox/label
  - toast (main), toaster
- Remove `&block` from all 5 toast helper methods (`toast`, `toast_success`, `toast_error`, `toast_warning`, `toast_info`)

### Changed

- Updated documentation for sidebar, card, alert, toast, combobox, date picker, and dropdown menu components

### Breaking Changes

- Block syntax no longer works for affected partials — use `content: capture { ... }` instead of `do ... end`
- Toast helper methods no longer accept blocks — use `content:` parameter instead
- Sidebar IDs changed from `sidebar-<random_hex>` to `sidebar-left` / `sidebar-right`
- Sidebar provider now has an `id` attribute (`sidebar-provider` by default)

## [0.3.1.1] - 2025-02-02

### Fixed

- Fix date picker and calendar locale handling (#9)
- Fix form error text using wrong CSS variable (#8)
- Set default icon for dropdown trigger (#7)
- Fix badge primary variant CSS variable names (#6)

## [0.3.1] - 2025-01-19

### Added

#### Interactive Components
- **Calendar** — Inline date picker calendar
  - Single and range date selection modes
  - Min/max date constraints
  - Disabled dates support
  - Configurable week start (Sunday/Monday)
  - Show/hide outside days
  - Hidden inputs for form integration
  - Full keyboard navigation (arrow keys, Home, End)
  - Stimulus controller with month navigation
  - ARIA-compliant accessibility (`role="grid"`)

- **Date Picker** — Popover-based date selection
  - Uses native HTML5 Popover API for light-dismiss behavior
  - Wraps Calendar component in a popover
  - Single and range selection modes
  - Customizable placeholder text
  - Size variants (sm, default, lg)
  - Full-width option
  - Error state styling
  - Auto-close on selection (single mode) or range completion
  - Smooth open/close animations with CSS transitions
  - Fallback positioning for browsers without anchor positioning

### Technical Details
- Calendar uses CSS custom property `--cell-size` for responsive sizing
- Date Picker uses `position-area` with fallbacks for cross-browser support
- Both components support dark mode via CSS variables
- Added `chevron_left` and `calendar` icons to icons helper

## [0.3.0] - 2025-01-07

### Added

#### Interactive Components
- **Combobox** — Searchable dropdown selection with keyboard navigation
  - HTML5 Popover API for native light-dismiss behavior
  - Filtering/search functionality
  - Support for grouped options with labels and separators
  - Width variants (sm, default, md, lg, full)
  - Helper methods: `combobox` (builder pattern) and `combobox_simple` (data-driven)
  - Full keyboard navigation (arrow keys, enter, escape, home, end)
  - ARIA-compliant accessibility (`role="combobox"`, `role="listbox"`)

#### Feedback Components
- **Toast** — Non-intrusive notification system
  - Five variants: default, success, info, warning, error
  - Six position options: top-left, top-center, top-right, bottom-left, bottom-center, bottom-right
  - Auto-dismiss with configurable duration
  - Pause timer on hover
  - Global JavaScript API (`Toast.success()`, `Toast.error()`, etc.)
  - Flash message integration via `toast_flash_messages` helper
  - Action button support
  - Enter/exit animations based on position
  - Maximum visible toasts enforcement

### Technical Details
- Combobox uses HTML5 Popover API with `@oddbird/popover-polyfill` recommended for older browsers
- Toast system includes two Stimulus controllers: `toaster` (container/API) and `toast` (individual lifecycle)

## [0.2.0] - 2025-01-01

### Added

#### Layout Components
- **Sidebar** — Collapsible navigation sidebar with cookie persistence for state
- **Header** — Top navigation bar component

#### Content Components
- **Card** — Content container with header, title, description, content, action, and footer slots
- **Alert** — Callout messages with title and description slots, supports default and destructive variants
- **Badge** — Status indicators with variants (default, primary, secondary, destructive, success, warning, outline) and sizes (sm, md, lg)
- **Table** — Data tables with header, body, row, cell, and head partials
- **Empty State** — Placeholder component for empty lists and no-data scenarios

#### Navigation Components
- **Breadcrumbs** — Navigation trail with overflow handling, keyboard navigation, and customizable separators
- **Dropdown Menu** — Accessible dropdown with keyboard navigation, focus management, and variant support
- **Pagination** — Page navigation with Pagy integration (full and simple variants)

#### Interactive Components
- **Toggle Group** — Single/multiple selection button groups with Stimulus controller

#### Form Components (CSS-only with data attributes)
- **Button** — Variants: default, primary, secondary, destructive, outline, ghost, link; Sizes: sm, default, lg, icon
- **Input** — Text input with validation error states
- **Textarea** — Multi-line text input
- **Select** — Dropdown select input
- **Checkbox** — Checkbox input with custom styling
- **Radio** — Radio button input with custom styling
- **Switch** — Toggle switch input

#### Infrastructure
- Install generator (`bin/rails generate maquina_components:install`) for easy setup
- Automatic engine CSS import configuration
- Theme variables following shadcn/ui convention (light and dark mode)
- Helper file generation for icon customization
- Generator options: `--skip-theme`, `--skip-helper`

#### Documentation
- Component documentation at https://maquina.app/documentation/components/
- Getting started guide
- Individual component guides with examples and API reference

#### Test/Dummy Application
- Component showcase pages demonstrating all variants
- Dark/light theme toggle implementation
- Theme selector for switching color schemes

### Technical Details
- ERB partials with strict locals for type safety
- Data attributes for styling (no inline Tailwind classes in partials)
- CSS variables for theming compatibility
- Stimulus controllers only where JavaScript interactivity is required
- TailwindCSS 4.0 with `@theme` directive support
- Progressive enhancement (components work without JavaScript where possible)

## [0.1.0] - 2024-12-01

### Added
- Initial project setup
- Rails Engine structure
- Basic TailwindCSS integration

[Unreleased]: https://github.com/maquina-app/maquina_components/compare/v0.7.0...HEAD
[0.7.0]: https://github.com/maquina-app/maquina_components/compare/v0.6.1...v0.7.0
[0.6.1]: https://github.com/maquina-app/maquina_components/compare/v0.6.0...v0.6.1
[0.6.0]: https://github.com/maquina-app/maquina_components/compare/v0.5.1...v0.6.0
[0.5.1]: https://github.com/maquina-app/maquina_components/compare/v0.5.0...v0.5.1
[0.5.0]: https://github.com/maquina-app/maquina_components/compare/v0.4.4...v0.5.0
[0.4.4]: https://github.com/maquina-app/maquina_components/compare/v0.4.3...v0.4.4
[0.4.3]: https://github.com/maquina-app/maquina_components/compare/v0.4.2...v0.4.3
[0.4.2]: https://github.com/maquina-app/maquina_components/compare/v0.4.1...v0.4.2
[0.4.1]: https://github.com/maquina-app/maquina_components/compare/v0.4.0...v0.4.1
[0.4.0]: https://github.com/maquina-app/maquina_components/compare/v0.3.1.1...v0.4.0
[0.3.1.1]: https://github.com/maquina-app/maquina_components/compare/v0.3.1...v0.3.1.1
[0.3.1]: https://github.com/maquina-app/maquina_components/compare/v0.3.0...v0.3.1
[0.3.0]: https://github.com/maquina-app/maquina_components/compare/v0.2.0...v0.3.0
[0.2.0]: https://github.com/maquina-app/maquina_components/compare/v0.1.0...v0.2.0
[0.1.0]: https://github.com/maquina-app/maquina_components/releases/tag/v0.1.0
