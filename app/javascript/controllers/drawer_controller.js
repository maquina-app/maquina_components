import { Controller } from "@hotwired/stimulus";

/**
 * Drawer Controller
 *
 * Manages drawer state (slide-out panel), keyboard shortcuts, and persistence.
 * Works with drawer_trigger_controller via Stimulus outlets.
 *
 * @example
 * <div data-controller="drawer" data-outlet="drawer">
 *   <!-- drawer content -->
 * </div>
 */
export default class extends Controller {
  static values = {
    open: { type: Boolean, default: false },
    defaultOpen: { type: Boolean, default: false },
    cookieName: { type: String, default: "drawer_state" },
    cookieMaxAge: { type: Number, default: 60 * 60 * 24 * 365 },
    keyboardShortcut: { type: String, default: "d" }
  }

  static targets = ["drawer", "backdrop", "panel"]

  initialize() {
    const cookieValue = this.getCookie(this.cookieNameValue)
    this.openValue = cookieValue !== null
      ? cookieValue === "true"
      : this.defaultOpenValue

    // Set by a same-URL "replace" visit (a page refresh) until it renders
    this._refreshing = false
  }

  connect() {
    this.boundTrackVisit = this.trackVisit.bind(this)
    this.boundClearVisit = this.clearVisit.bind(this)
    this.boundTeardown = this.teardown.bind(this)
    this.boundPreserveAttribute = this.preserveAttribute.bind(this)
    this.boundHandleMorph = this.handleMorph.bind(this)
    document.addEventListener("turbo:visit", this.boundTrackVisit)
    document.addEventListener("turbo:load", this.boundClearVisit)
    document.addEventListener("turbo:before-cache", this.boundTeardown)
    document.addEventListener("turbo:before-morph-attribute", this.boundPreserveAttribute)
    document.addEventListener("turbo:morph", this.boundHandleMorph)

    this.updateStateImmediate()
  }

  disconnect() {
    document.removeEventListener("turbo:visit", this.boundTrackVisit)
    document.removeEventListener("turbo:load", this.boundClearVisit)
    document.removeEventListener("turbo:before-cache", this.boundTeardown)
    document.removeEventListener("turbo:before-morph-attribute", this.boundPreserveAttribute)
    document.removeEventListener("turbo:morph", this.boundHandleMorph)
  }

  // ============================================================================
  // Turbo Integration (cache teardown and page-refresh morphs)
  // ============================================================================

  // A page refresh is a same-path "replace" visit -- Turbo's own isPageRefresh
  // test. It covers Turbo.visit(location.href, { action: "replace" }), refresh
  // broadcasts and same-URL form redirects. An open drawer must survive it.
  trackVisit(event) {
    const { url, action } = event.detail
    this._refreshing = action === "replace" &&
      new URL(url, window.location.href).pathname === window.location.pathname
  }

  clearVisit() {
    this._refreshing = false
  }

  // Runs before Turbo snapshots the page: real navigation closes the drawer so
  // the cached snapshot starts closed; a page refresh leaves it open. Either
  // way the scroll lock is released so no snapshot is cached locked --
  // handleMorph() re-locks after a refresh.
  teardown() {
    if (this._refreshing) {
      this.unlockScroll()
      return
    }

    this.openValue = false

    if (this.hasBackdropTarget) {
      this.backdropTarget.setAttribute("data-state", "hidden")
      this.backdropTarget.classList.add("hidden")
    }

    this.unlockScroll()
  }

  // The morph must not overwrite the attributes this controller owns; the
  // drawer's contents still morph normally.
  preserveAttribute(event) {
    const owned = this.ownedAttributes(event.target)
    if (owned?.includes(event.detail.attributeName)) {
      event.preventDefault()
    }
  }

  ownedAttributes(element) {
    if (element === this.element) return ["data-drawer-open-value"]
    if (this.hasDrawerTarget && element === this.drawerTarget) return ["data-state"]
    if (this.hasBackdropTarget && element === this.backdropTarget) return ["data-state", "class"]
    if (this.hasPanelTarget && element === this.panelTarget) return ["aria-hidden", "inert"]
    return null
  }

  // After a morph, keep the live state and re-apply what the morph can still
  // reset: the body scroll lock (<body> is morphed) and the trigger's aria.
  handleMorph() {
    this._refreshing = false

    if (this.hasDrawerTarget) {
      this.drawerTarget.classList.remove("drawer-loading")
    }

    this.updateState()
    this.dispatchStateChange()
  }

  // ============================================================================
  // Keyboard Shortcut Actions
  // ============================================================================

  toggleWithKeyboard(event) {
    this.toggle()
  }

  closeOnEscape(event) {
    if (this.openValue) {
      this.close()
    }
  }

  // ============================================================================
  // State Management
  // ============================================================================

  openValueChanged(new_value, old_value) {
    if (new_value === old_value) return

    this.updateState()
    this.persistState()
    this.dispatchStateChange()

    // Only manage focus on user-driven changes, not the initial sync
    if (old_value !== undefined) {
      this.manageFocus(new_value)
    }
  }

  manageFocus(isOpen) {
    if (!this.hasPanelTarget) return

    if (isOpen) {
      this._previouslyFocused = document.activeElement
      this.panelTarget.focus()
    } else {
      if (this._previouslyFocused?.isConnected) {
        this._previouslyFocused.focus()
      }
      this._previouslyFocused = null
    }
  }

  updateState() {
    if (!this.hasDrawerTarget) return

    const isOpen = this.openValue
    const state = isOpen ? "open" : "closed"

    this.drawerTarget.setAttribute("data-state", state)

    if (this.hasBackdropTarget) {
      const backdropState = isOpen ? "visible" : "hidden"
      this.backdropTarget.setAttribute("data-state", backdropState)

      if (backdropState === "visible") {
        this.backdropTarget.classList.remove("hidden")
      } else {
        setTimeout(() => {
          if (this.backdropTarget.getAttribute("data-state") === "hidden") {
            this.backdropTarget.classList.add("hidden")
          }
        }, 300)
      }
    }

    if (this.hasPanelTarget) {
      // The closed panel stays in the DOM: hide it from AT and block focus
      if (isOpen) {
        this.panelTarget.removeAttribute("aria-hidden")
        this.panelTarget.removeAttribute("inert")
      } else {
        this.panelTarget.setAttribute("aria-hidden", "true")
        this.panelTarget.setAttribute("inert", "")
      }
    }

    if (isOpen) {
      this.lockScroll()
    } else {
      this.unlockScroll()
    }
  }

  updateStateImmediate() {
    if (!this.hasDrawerTarget) return

    this.updateState()

    requestAnimationFrame(() => {
      this.drawerTarget.classList.remove("drawer-loading")
    })
  }

  // ============================================================================
  // Public Actions
  // ============================================================================

  toggle() {
    this.openValue = !this.openValue
  }

  open() {
    this.openValue = true
  }

  close() {
    this.openValue = false
  }

  backdropClick(event) {
    if (this.openValue) {
      this.close()
    }
  }

  // ============================================================================
  // Persistence
  // ============================================================================

  persistState() {
    this.setCookie(
      this.cookieNameValue,
      this.openValue.toString(),
      this.cookieMaxAgeValue
    )
  }

  getCookie(name) {
    const value = `; ${document.cookie}`
    const parts = value.split(`; ${name}=`)
    if (parts.length === 2) {
      return parts.pop().split(";").shift()
    }
    return null
  }

  setCookie(name, value, maxAge) {
    document.cookie = `${name}=${value}; path=/; max-age=${maxAge}; SameSite=Lax`
  }

  // ============================================================================
  // Scroll Lock
  // ============================================================================

  // Styling lives in drawer.css (body[data-maquina-scroll-locked]); the
  // controller only records the scroll offset and flips the attribute
  // Idempotent and owned: the offset is recorded once per lock (re-locking
  // after a morph reset <body> must not record the locked page's offset of 0),
  // and a closed drawer never releases a lock it didn't take -- the sidebar
  // shares the same body attribute.
  lockScroll() {
    if (!this._scrollLocked) {
      this.scrollPosition = window.scrollY
      this._scrollLocked = true
    }
    document.body.style.setProperty("--maquina-scroll-lock-top", `-${this.scrollPosition}px`)
    document.body.setAttribute("data-maquina-scroll-locked", "")
  }

  unlockScroll() {
    if (!this._scrollLocked) return

    this._scrollLocked = false
    document.body.removeAttribute("data-maquina-scroll-locked")
    document.body.style.removeProperty("--maquina-scroll-lock-top")
    window.scrollTo(0, this.scrollPosition)
  }

  // ============================================================================
  // Events
  // ============================================================================

  dispatchStateChange() {
    this.dispatch("stateChanged", {
      detail: {
        open: this.openValue,
        state: this.openValue ? "open" : "closed"
      },
      bubbles: true
    })
  }
}
