import { Controller } from "@hotwired/stimulus"

/**
 * Sidebar Controller
 * 
 * Manages sidebar state, keyboard shortcuts, responsive behavior, and persistence.
 * Works with sidebar_trigger_controller via Stimulus outlets.
 * 
 * @example
 * <div data-controller="sidebar" data-outlet="sidebar">
 *   <!-- sidebar content -->
 * </div>
 */
export default class extends Controller {
  static values = {
    open: { type: Boolean, default: true },
    defaultOpen: { type: Boolean, default: true },
    cookieName: { type: String, default: "sidebar_state" },
    cookieMaxAge: { type: Number, default: 60 * 60 * 24 * 365 },
    keyboardShortcut: { type: String, default: "b" }
  }

  static targets = ["sidebar", "container", "backdrop"]

  initialize() {
    // Load saved state from cookie or use default
    // Note: Rails backend can set defaultOpen based on cookie value
    // via sidebar_state helper
    const cookieValue = this.getCookie(this.cookieNameValue)
    this.openValue = cookieValue !== null
      ? cookieValue === "true"
      : this.defaultOpenValue

    // Track if we're on mobile
    this._isMobile = null

    // Set by a same-URL "replace" visit (a page refresh) until it renders
    this._refreshing = false
  }

  connect() {
    // Detect initial screen size
    this.checkScreenSize()

    // Setup resize handler with debounce
    this.resizeHandler = this.debounce(this.checkScreenSize.bind(this), 150)
    window.addEventListener("resize", this.resizeHandler)

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

    // Apply initial state without animation
    this.updateStateImmediate()
  }

  disconnect() {
    window.removeEventListener("resize", this.resizeHandler)
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
  // broadcasts and same-URL form redirects. The open state must survive it.
  trackVisit(event) {
    const { url, action } = event.detail
    this._refreshing = action === "replace" &&
      new URL(url, window.location.href).pathname === window.location.pathname
  }

  clearVisit() {
    this._refreshing = false
  }

  // Runs before Turbo snapshots the page. Real navigation parks the mobile
  // drawer so the cached snapshot (and the next page) starts closed; a page
  // refresh leaves it open. Either way the scroll lock is released so no
  // snapshot is cached locked -- handleMorph() re-locks after a refresh.
  teardown() {
    if (this._refreshing) {
      this.unlockScroll()
      return
    }

    if (this.isMobile()) {
      this.openValue = false
    }

    if (this.hasBackdropTarget) {
      this.backdropTarget.setAttribute("data-state", "hidden")
      this.backdropTarget.classList.add("hidden")
    }

    this.unlockScroll()
  }

  // The server renders open state from the desktop cookie, which mobile never
  // writes, so a morph must not overwrite the attributes this controller owns.
  // The menu contents below them still morph normally.
  preserveAttribute(event) {
    const owned = this.ownedAttributes(event.target)
    if (owned?.includes(event.detail.attributeName)) {
      event.preventDefault()
    }
  }

  ownedAttributes(element) {
    if (element === this.element) return ["data-sidebar-open-value"]
    if (this.hasSidebarTarget && element === this.sidebarTarget) return ["data-state", "data-collapsible"]
    if (this.hasBackdropTarget && element === this.backdropTarget) return ["data-state", "class"]
    if (this.hasContainerTarget && element === this.containerTarget) return ["inert"]
    return null
  }

  // After a morph: keep the live state on mobile, re-read the cookie on
  // desktop, then re-apply everything the morph can still reset -- the body
  // scroll lock (<body> is morphed) and the trigger's aria-expanded.
  handleMorph() {
    this._refreshing = false

    if (!this.isMobile()) {
      const cookieValue = this.getCookie(this.cookieNameValue)
      if (cookieValue !== null) {
        this.openValue = cookieValue === "true"
      }
    }

    if (this.hasSidebarTarget) {
      this.sidebarTarget.classList.remove("sidebar-loading")
    }

    this.updateState()
    this.dispatchStateChange()
  }

  // ============================================================================
  // Keyboard Shortcut Actions (Called by Stimulus declarative actions)
  // ============================================================================

  /**
   * Toggle sidebar via keyboard shortcut
   * Called by data-action keyboard bindings (Cmd/Ctrl+B by default)
   * @param {KeyboardEvent} event
   */
  toggleWithKeyboard(event) {
    this.toggle()
  }

  // ============================================================================
  // State Management
  // ============================================================================

  openValueChanged(new_value, old_value) {
    if (new_value === old_value) return

    this.updateState()
    this.persistState()
    this.dispatchStateChange()
  }

  updateState() {
    if (!this.hasSidebarTarget) return

    const isOpen = this.openValue
    const isMobile = this.isMobile()
    const state = isOpen ? "expanded" : "collapsed"

    // Update sidebar state
    this.sidebarTarget.setAttribute("data-state", state)

    const collapsible = isOpen
      ? "none"
      : !isMobile
        ? "icon"
        : "offcanvas";

    // Update sidebar visual state
    this.sidebarTarget.setAttribute("data-collapsible", collapsible)

    this.updateInert(state, collapsible)

    // Update backdrop (only visible on mobile when open)
    if (this.hasBackdropTarget) {
      const backdropState = (isOpen && isMobile) ? "visible" : "hidden"
      this.backdropTarget.setAttribute("data-state", backdropState)

      // Toggle hidden class for visibility
      if (backdropState === "visible") {
        this.backdropTarget.classList.remove("hidden")
      } else {
        // Wait for transition before hiding
        setTimeout(() => {
          if (this.backdropTarget.getAttribute("data-state") === "hidden") {
            this.backdropTarget.classList.add("hidden")
          }
        }, 300)
      }
    }

    // Lock/unlock scroll on mobile
    if (isMobile) {
      if (isOpen) {
        this.lockScroll()
      } else {
        this.unlockScroll()
      }
    }
  }

  // An offcanvas-collapsed sidebar is parked at `left: -(--sidebar-width)` with
  // visibility: visible, so without this every link in it stays a tab stop --
  // a keyboard user walks through a screenful of off-screen destinations that
  // no pointer can reach. `inert`, not `aria-hidden`: the latter hides the
  // subtree from the accessibility tree while leaving it focusable, which is
  // the worse outcome of a focused element the screen reader will not announce.
  //
  // Only the offcanvas-collapsed case. A `collapsible: "icon"` sidebar is a
  // visible rail and must stay reachable, and an open one obviously must.
  updateInert(state, collapsible) {
    if (!this.hasContainerTarget) return

    const offscreen = state === "collapsed" && collapsible === "offcanvas"

    if (offscreen) {
      this.containerTarget.setAttribute("inert", "")
    } else {
      this.containerTarget.removeAttribute("inert")
    }
  }

  updateStateImmediate() {
    // Update state without transitions (for initial render)
    if (!this.hasSidebarTarget) return

    this.updateState()

    requestAnimationFrame(() => {
      this.sidebarTarget.classList.remove("sidebar-loading")
    })
  }

  // ============================================================================
  // Public Actions (Called by triggers or other controllers)
  // ============================================================================

  /**
   * Toggle sidebar open/closed state
   */
  toggle() {
    this.openValue = !this.openValue
  }

  /**
   * Open the sidebar
   */
  open() {
    this.openValue = true
  }

  /**
   * Close the sidebar
   */
  close() {
    this.openValue = false
  }

  /**
   * Toggle only if on mobile (useful for touch gestures)
   */
  toggleMobile() {
    if (this.isMobile()) {
      this.toggle()
    }
  }

  /**
   * Handle backdrop click (close sidebar on mobile)
   * @param {MouseEvent} event
   */
  backdropClick(event) {
    if (this.isMobile() && this.openValue) {
      this.close()
    }
  }

  // ============================================================================
  // Responsive Behavior
  // ============================================================================

  checkScreenSize() {
    const wasMobile = this._isMobile
    this._isMobile = window.innerWidth < 768

    // First time detecting screen size
    if (wasMobile === null) {
      // On mobile, start closed; on desktop, use saved state
      if (this._isMobile) {
        this.openValue = false
      }
      return
    }

    // Screen size changed
    if (wasMobile !== this._isMobile) {
      this.handleScreenSizeChange(wasMobile, this._isMobile)
    }
  }

  // data-collapsible describes the current state ("none" just means open), so
  // only the direction of the crossing matters: entering mobile parks the
  // drawer closed, leaving it restores the saved desktop state.
  handleScreenSizeChange(wasMobile, isMobile) {
    if (wasMobile && !isMobile) {
      const cookieValue = this.getCookie(this.cookieNameValue)
      this.openValue = cookieValue !== null
        ? cookieValue === "true"
        : this.defaultOpenValue
    } else if (!wasMobile && isMobile) {
      this.openValue = false
    }

    // Crossing the breakpoint without an open-state change still moves the
    // drawer between offcanvas and icon rail, and drops a desktop scroll lock
    this.updateState()
    if (!isMobile) this.unlockScroll()
  }

  isMobile() {
    return this._isMobile ?? (window.innerWidth < 768)
  }

  // ============================================================================
  // Persistence (Cookie Management)
  // ============================================================================

  persistState() {
    // Only save desktop state to cookie
    if (!this.isMobile()) {
      this.setCookie(
        this.cookieNameValue,
        this.openValue.toString(),
        this.cookieMaxAgeValue
      )
    }
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
  // Scroll Lock (for mobile overlay)
  // ============================================================================

  // Styling lives in drawer.css (body[data-maquina-scroll-locked]); the
  // controller only records the scroll offset and flips the attribute.
  //
  // Idempotent: the offset is recorded once per lock. Re-locking after a morph
  // reset <body> must not record the locked page's offset of 0.
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
  // Events (Custom event dispatching)
  // ============================================================================

  dispatchStateChange() {
    this.dispatch("stateChanged", {
      detail: {
        open: this.openValue,
        mobile: this.isMobile(),
        state: this.openValue ? "expanded" : "collapsed",
        collapsible: this.sidebarTarget.getAttribute("data-collapsible")
      },
      bubbles: true
    })
  }

  // ============================================================================
  // Utilities
  // ============================================================================

  debounce(func, wait) {
    let timeout
    return function executedFunction(...args) {
      const later = () => {
        clearTimeout(timeout)
        func(...args)
      }
      clearTimeout(timeout)
      timeout = setTimeout(later, wait)
    }
  }
}
