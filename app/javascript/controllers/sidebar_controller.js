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
  }

  connect() {
    // Detect initial screen size
    this.checkScreenSize()

    // Setup resize handler with debounce
    this.resizeHandler = this.debounce(this.checkScreenSize.bind(this), 150)
    window.addEventListener("resize", this.resizeHandler)

    // Apply initial state without animation
    this.updateStateImmediate()
  }

  disconnect() {
    window.removeEventListener("resize", this.resizeHandler)
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

  handleScreenSizeChange(wasMobile, isMobile) {
    if (this.sidebarTarget.getAttribute("data-collapsible") === "offcanvas") {
      // Mobile to desktop: restore saved state
      if (wasMobile && !isMobile) {
        const cookieValue = this.getCookie(this.cookieNameValue)
        this.openValue = cookieValue !== null
          ? cookieValue === "true"
          : this.defaultOpenValue
      }
      // Desktop to mobile: close sidebar
      else if (!wasMobile && isMobile) {
        this.openValue = false
      }
    } else if (this.sidebarTarget.getAttribute("data-collapsible") === "icon") {
      // Icon mode is always visible, just changes width
      // Desktop to mobile: might want to close
      if (!wasMobile && isMobile) {
        this.openValue = false
      }
    } else if (this.sidebarTarget.getAttribute("data-collapsible") === "none") {
      // Non-collapsible sidebars stay open
      this.openValue = true
    }

    this.updateState()
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

  lockScroll() {
    this.scrollPosition = window.pageYOffset
    document.body.style.overflow = "hidden"
    document.body.style.position = "fixed"
    document.body.style.top = `-${this.scrollPosition}px`
    document.body.style.width = "100%"
  }

  unlockScroll() {
    document.body.style.overflow = ""
    document.body.style.position = ""
    document.body.style.top = ""
    document.body.style.width = ""
    if (this.scrollPosition !== undefined) {
      window.scrollTo(0, this.scrollPosition)
    }
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
