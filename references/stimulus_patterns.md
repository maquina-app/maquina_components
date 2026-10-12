# Stimulus Patterns Guide

> Patterns for interactive components using Stimulus JS in maquina_components.

## When to Use Stimulus

Use Stimulus **only** when components need:
- Toggle/collapse behavior
- Popover positioning (flip on overflow)
- Focus management
- Keyboard navigation
- State persistence (cookies)
- Animation coordination
- Measuring layout (e.g. breadcrumb collapse)

**Don't use Stimulus for:**
- Hover effects (CSS)
- Focus states (CSS)
- Form validation display (`aria-invalid` + CSS)
- Responsive behavior (CSS)

## Current Stimulus Controllers

Identifiers follow the file name (`dropdown_menu_controller.js` → `dropdown-menu`).

| Controller | Identifier | Component | Purpose |
|------------|------------|-----------|---------|
| `breadcrumb_controller` | `breadcrumb` | Breadcrumbs (`responsive: true`) | Collapse middle items into an ellipsis when the trail overflows (ResizeObserver on the list) |
| `calendar_controller` | `calendar` | Calendar | Month navigation, single/range selection, keyboard grid; emits `calendar:change`, `calendar:navigate` |
| `combobox_controller` | `combobox` | Combobox | Searchable popover list, keyboard navigation; emits `combobox:change` |
| `date_picker_controller` | `date-picker` | Date Picker | Popover around a calendar, hidden input sync; emits `date-picker:change` |
| `drawer_controller` | `drawer` | Drawer | Open/close, cookie persistence, keyboard shortcut, scroll lock, `inert`; emits `drawer:stateChanged` |
| `drawer_trigger_controller` | `drawer-trigger` | Drawer trigger | Toggles a drawer via outlet; mirrors `aria-expanded` |
| `dropdown_menu_controller` | `dropdown-menu` | Dropdown Menu | Toggle, click-outside, Escape, arrow-key navigation, flip to `data-side="top"`, optional `autoClose` |
| `menu_button_controller` | `menu-button` | Menu Button | Toggle the `components/dropdown` panel, flip on overflow |
| `sidebar_controller` | `sidebar` | Sidebar provider | Expand/collapse, cookie persistence, keyboard shortcut, mobile overlay + scroll lock, `inert`; emits `sidebar:stateChanged` |
| `sidebar_trigger_controller` | `sidebar-trigger` | Sidebar trigger | Toggles the sidebar via outlet; mirrors `aria-expanded`/`aria-controls` |
| `toast_controller` | `toast` | Toast | Auto-dismiss timer, pause on hover, dismiss; emits `toast:action` |
| `toaster_controller` | `toaster` | Toaster | Container; exposes the global `Toast` JS API (`Toast.success(...)`, `Toast.dismissAll()`), enforces `maxVisible` |
| `toggle_group_controller` | `toggle-group` | Toggle Group | Single/multiple pressed state, roving focus; emits `toggle-group:change` |

## Basic Controller Structure

```javascript
// app/javascript/controllers/{component}_controller.js

import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  // DOM elements to reference
  static targets = ["trigger", "content"]

  // Reactive values
  static values = {
    open: { type: Boolean, default: false }
  }

  // Lifecycle: element connected to DOM
  connect() {
    this.handleClickOutside = this.handleClickOutside.bind(this)
    this.handleKeydown = this.handleKeydown.bind(this)
    this.boundTeardown = this.teardown.bind(this)

    this.element.dataset.state = "closed"
    document.addEventListener("turbo:before-cache", this.boundTeardown)
  }

  // Lifecycle: element removed from DOM
  disconnect() {
    this.removeEventListeners()
    document.removeEventListener("turbo:before-cache", this.boundTeardown)
  }

  // Actions
  toggle(event) {
    event?.preventDefault()
    this.openValue ? this.close() : this.open()
  }

  open() {
    if (this.openValue || !this.hasContentTarget) return

    this.openValue = true
    this.element.dataset.state = "open"
    this.contentTarget.dataset.state = "open"
    this.contentTarget.hidden = false
    this.triggerTarget.setAttribute("aria-expanded", "true")
    this.addEventListeners()
  }

  close() {
    if (!this.openValue) return

    this.openValue = false
    this.element.dataset.state = "closed"
    this.contentTarget.dataset.state = "closed"
    this.contentTarget.hidden = true
    this.triggerTarget.setAttribute("aria-expanded", "false")
    this.removeEventListeners()
    this.triggerTarget.focus()
  }

  // Reset to the server-rendered state before Turbo snapshots the page,
  // so a cached page never restores with a menu stuck open.
  teardown() {
    this.openValue = false
    this.element.dataset.state = "closed"
    if (this.hasContentTarget) {
      this.contentTarget.dataset.state = "closed"
      this.contentTarget.hidden = true
    }
    this.removeEventListeners()
  }

  // Private
  addEventListeners() {
    document.addEventListener("click", this.handleClickOutside)
    document.addEventListener("keydown", this.handleKeydown)
  }

  removeEventListeners() {
    document.removeEventListener("click", this.handleClickOutside)
    document.removeEventListener("keydown", this.handleKeydown)
  }

  handleClickOutside(event) {
    if (!this.element.contains(event.target)) this.close()
  }

  handleKeydown(event) {
    if (event.key === "Escape") this.close()
  }
}
```

## ERB Integration

### Basic Pattern

```erb
<div data-controller="{component}">
  <button type="button"
          aria-expanded="false"
          data-{component}-target="trigger"
          data-action="click->{component}#toggle">
    Toggle
  </button>

  <div data-{component}-target="content"
       data-state="closed"
       hidden>
    Panel content
  </div>
</div>
```

### With Component Partial

Pass the controller and its values through `merge_component_data` — `controller` and `action` **concatenate** with any the caller adds:

```erb
<%# app/views/components/_dropdown_menu.html.erb %>
<%# locals: (auto_close: false, css_classes: "", **html_options) %>
<% merged_data = merge_component_data(html_options,
    component: "dropdown-menu",
    controller: "dropdown-menu"
  ) %>
<% merged_data["dropdown-menu-auto-close-value"] = true if auto_close %>

<%= content_tag :div, class: css_classes.presence, data: merged_data, **html_options do %>
  <%= yield %>
<% end %>
```

```erb
<%# Caller adds its own controller without losing the component's %>
<%= render "components/dropdown_menu", data: { controller: "analytics" } do %>
  ...
<% end %>
<%# => data-controller="dropdown-menu analytics" %>
```

Value keys written as symbols are dasherized (`sidebar_open_value:` → `data-sidebar-open-value`).

## Common Patterns

### Toggle with State Attribute

Controllers set `data-state` on the root and the content; CSS targets it:

```css
@layer components {
  :where([data-component="dropdown-menu"][data-state="open"]) [data-dropdown-menu-target="chevron"] {
    transform: rotate(180deg);
  }

  [data-dropdown-menu-part="content"]:where([data-state="open"]) {
    animation: dropdown-menu-in 150ms ease-out;
  }
}
```

### Flip on Overflow (dropdown menu, menu button)

Measure after the paint, always from the authored placement, and flip only when the other side fits:

```javascript
open() {
  // ...show content...
  requestAnimationFrame(() => this.positionContent())
}

get authoredSide() {
  if (this._authoredSide === undefined) {
    this._authoredSide = this.contentTarget.dataset.side || "bottom"
  }
  return this._authoredSide
}

positionContent() {
  const content = this.contentTarget
  const side = this.authoredSide
  content.dataset.side = side // reset, so a flip doesn't stick
  if (side !== "bottom" && side !== "top") return

  const triggerRect = this.triggerTarget.getBoundingClientRect()
  const needed = content.getBoundingClientRect().height + 4
  const roomBelow = window.innerHeight - triggerRect.bottom
  const roomAbove = triggerRect.top

  if (side === "bottom" && needed > roomBelow && needed <= roomAbove) {
    content.dataset.side = "top"
  } else if (side === "top" && needed > roomAbove && needed <= roomBelow) {
    content.dataset.side = "bottom"
  }
}
```

The CSS styles every `data-side`; the controller only chooses one.

### Cookie Persistence (Sidebar / Drawer pattern)

```javascript
// sidebar_controller.js (abridged)

static values = {
  open: { type: Boolean, default: true },
  defaultOpen: { type: Boolean, default: true },
  cookieName: { type: String, default: "sidebar_state" },
  cookieMaxAge: { type: Number, default: 60 * 60 * 24 * 365 },
  keyboardShortcut: { type: String, default: "b" }
}

getCookie(name) {
  const value = `; ${document.cookie}`
  const parts = value.split(`; ${name}=`)
  if (parts.length === 2) return parts.pop().split(";").shift()
  return null
}

setCookie(name, value, maxAge) {
  document.cookie = `${name}=${value}; path=/; max-age=${maxAge}; SameSite=Lax`
}
```

The server reads the same cookie so the first paint is already correct:

```erb
<%= render "components/sidebar/provider", default_open: sidebar_open? do %>
  <%= render "components/sidebar", state: sidebar_state do %>
```

(`sidebar_state` / `sidebar_open?` and `drawer_state` / `drawer_open?` live in `app/helpers/maquina_components/`.)

### Keyboard Shortcuts via Action Descriptors

No global listeners to manage — declare them on the provider:

```erb
action: "keydown.meta+b@window->sidebar#toggleWithKeyboard keydown.ctrl+b@window->sidebar#toggleWithKeyboard"
```

### Outlets (trigger anywhere on the page)

The trigger reaches its controller through an outlet, not a DOM ancestor:

```erb
<%# Provider: data-outlet="sidebar" makes it addressable %>
<%# Trigger: %>
<button type="button"
        data-controller="sidebar-trigger"
        data-action="click->sidebar-trigger#triggerClick"
        data-sidebar-trigger-sidebar-outlet="[data-outlet='sidebar']">
```

```javascript
export default class extends Controller {
  static outlets = ["sidebar"]

  triggerClick() {
    if (this.hasSidebarOutlet) {
      this.sidebarOutlets.forEach(outlet => outlet.toggle())
    }
  }
}
```

The trigger keeps `aria-expanded` in sync by listening for the controller's `sidebar:stateChanged` event (`drawer:stateChanged` for the drawer).

### Custom Events

Use `this.dispatch(name, { detail })`, which prefixes the identifier and bubbles by default — don't also dispatch a hand-built `CustomEvent` with the same name (listeners would fire twice):

```javascript
this.dispatch("change", { detail: { value } })   // → "toggle-group:change"
this.dispatch("stateChanged", { detail: { open: this.openValue }, bubbles: true })
```

```erb
<div data-action="combobox:change->filters#apply"> ... </div>
```

### Click Outside to Close

```javascript
connect() {
  this.handleClickOutside = this.handleClickOutside.bind(this)
}

open() {
  // ...
  document.addEventListener("click", this.handleClickOutside)
}

close() {
  // ...
  document.removeEventListener("click", this.handleClickOutside)
}

handleClickOutside(event) {
  if (!this.element.contains(event.target)) this.close()
}

disconnect() {
  document.removeEventListener("click", this.handleClickOutside)
}
```

### Keyboard Navigation

```javascript
handleKeydown(event) {
  switch (event.key) {
    case "Escape":
      this.close()
      break
    case "ArrowDown":
      event.preventDefault()
      this.focusNextItem()
      break
    case "ArrowUp":
      event.preventDefault()
      this.focusPreviousItem()
      break
    case "Home":
      event.preventDefault()
      this.focusFirstItem()
      break
    case "End":
      event.preventDefault()
      this.focusLastItem()
      break
  }
}

get menuItems() {
  return this.contentTarget.querySelectorAll(
    '[role="menuitem"]:not([disabled]):not([aria-disabled="true"])'
  )
}

focusNextItem() {
  const items = Array.from(this.menuItems)
  const index = items.indexOf(document.activeElement)
  items[(index + 1) % items.length]?.focus()
}

focusPreviousItem() {
  const items = Array.from(this.menuItems)
  const index = items.indexOf(document.activeElement)
  items[(index - 1 + items.length) % items.length]?.focus()
}
```

Roving-focus items carry `tabindex="-1"` and show focus as a background change, so their CSS may drop the outline.

### Taking Panels Out of the Tab Order

Use `inert`, not `aria-hidden`, for a collapsed off-canvas sidebar or a closed drawer panel — `inert` also removes focusability. Render it server-side for the initial state, then keep it in sync:

```javascript
updateInert(state, collapsible) {
  if (!this.hasContainerTarget) return

  // Only the offcanvas-collapsed case; an icon rail must stay reachable
  const offscreen = state === "collapsed" && collapsible === "offcanvas"

  if (offscreen) {
    this.containerTarget.setAttribute("inert", "")
  } else {
    this.containerTarget.removeAttribute("inert")
  }
}
```

### Focus Trap (for Modals)

```javascript
trapFocus() {
  const focusable = this.panelTarget.querySelectorAll(
    'button, [href], input, select, textarea, [tabindex]:not([tabindex="-1"])'
  )

  this.firstFocusable = focusable[0]
  this.lastFocusable = focusable[focusable.length - 1]

  this.boundTrapFocus = (event) => {
    if (event.key !== "Tab") return

    if (event.shiftKey && document.activeElement === this.firstFocusable) {
      event.preventDefault()
      this.lastFocusable.focus()
    } else if (!event.shiftKey && document.activeElement === this.lastFocusable) {
      event.preventDefault()
      this.firstFocusable.focus()
    }
  }

  this.panelTarget.addEventListener("keydown", this.boundTrapFocus)
}

releaseFocus() {
  this.panelTarget.removeEventListener("keydown", this.boundTrapFocus)
}
```

### Scroll Lock (for Overlays)

The controller only records the offset and flips an attribute; the styling lives in `drawer.css` (the engine's one unlayered rule, so a host's own `body` rule can't defeat it):

```javascript
lockScroll() {
  this.scrollPosition = window.pageYOffset
  document.body.style.setProperty("--maquina-scroll-lock-top", `-${this.scrollPosition}px`)
  document.body.setAttribute("data-maquina-scroll-locked", "")
}

unlockScroll() {
  document.body.removeAttribute("data-maquina-scroll-locked")
  document.body.style.removeProperty("--maquina-scroll-lock-top")
  if (this.scrollPosition !== undefined) window.scrollTo(0, this.scrollPosition)
}
```

```css
body[data-maquina-scroll-locked] {
  position: fixed;
  top: var(--maquina-scroll-lock-top, 0px);
  width: 100%;
  overflow: hidden;
}
```

### Animation with CSS Keyframes

Set a `closing` state, wait for the animation, then hide. Keep the timeout equal to the CSS duration:

```javascript
close() {
  if (!this.openValue) return

  this.contentTarget.dataset.state = "closing"

  this._closeTimeout = setTimeout(() => {
    this._closeTimeout = null
    this.openValue = false
    this.element.dataset.state = "closed"
    this.contentTarget.dataset.state = "closed"
    this.contentTarget.hidden = true
  }, 100) // matches the 100ms close animation in CSS
}
```

```css
@layer components {
  [data-dropdown-menu-part="content"]:where([data-state="open"]) {
    animation: dropdown-menu-in 150ms ease-out;
  }

  [data-dropdown-menu-part="content"]:where([data-state="closing"]) {
    animation: dropdown-menu-out 100ms ease-in forwards;
  }
}

@keyframes dropdown-menu-in {
  from { opacity: 0; transform: scale(0.95) translateY(-4px); }
  to   { opacity: 1; transform: scale(1) translateY(0); }
}

@keyframes dropdown-menu-out {
  from { opacity: 1; transform: scale(1) translateY(0); }
  to   { opacity: 0; transform: scale(0.95) translateY(-4px); }
}
```

Clear the pending timeout in `teardown()`.

### Turbo Integration

- **`turbo:before-cache`** — every popover/overlay controller resets to its closed state so cached snapshots don't restore open menus.
- **`turbo:before-morph-element` / `turbo:morph`** — the sidebar and drawer preserve their client-side open state across page refreshes with morphing.
- **`turbo:morph`** — the breadcrumb controller re-measures.

## Importmap Configuration

The engine pins its controllers in `config/importmap.rb`, and the engine initializer adds that file to the host's importmap automatically:

```ruby
# config/importmap.rb (engine)
pin_all_from MaquinaComponents::Engine.root.join("app/javascript/controllers"), under: "controllers"
```

A host using the standard `eagerLoadControllersFrom("controllers", application)` picks them up with no extra configuration. The initializer is skipped when the host has no `config.importmap` (jsbundling); such hosts import the controllers from the gem path and register them manually.

## Testing Controllers

The engine has no JavaScript unit-test harness; behavior is exercised through the dummy app previews (`test/dummy/app/views/previews/<component>/`) and `test/integration/previews_smoke_test.rb`. CSS ↔ controller contracts (e.g. the breadcrumb measuring class) are asserted in `test/stylesheets/css_conventions_test.rb`.

If you add a JS test setup, register the controller under its real identifier:

```javascript
import { Application } from "@hotwired/stimulus"
import DropdownMenuController from "controllers/dropdown_menu_controller"

const application = Application.start()
application.register("dropdown-menu", DropdownMenuController)
```

## Best Practices

1. **Bind handlers in `connect()`, remove them in `disconnect()`**
2. **Use the Values API** for state; write `data-state` for CSS
3. **Use Targets and Outlets** for DOM references, not `querySelector` across the page
4. **Render the initial state server-side** (`hidden`, `data-state="closed"`, `inert`, `aria-expanded="false"`) so the page is correct before Stimulus connects
5. **Handle keyboard navigation and return focus** to the trigger on close
6. **Reset on `turbo:before-cache`**
7. **Namespace custom events** via `this.dispatch` (`{identifier}:{event}`), and dispatch each event once
8. **Never style from JavaScript** beyond data attributes and CSS custom properties — the look belongs in the component's CSS file
