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

  static targets = ["drawer", "container", "backdrop", "panel"]

  initialize() {
    const cookieValue = this.getCookie(this.cookieNameValue)
    this.openValue = cookieValue !== null
      ? cookieValue === "true"
      : this.defaultOpenValue

    this._morphing = false
  }

  connect() {
    this.resizeHandler = this.debounce(this.checkScreenSize.bind(this), 150)
    window.addEventListener("resize", this.resizeHandler)

    this.boundTeardown = this.teardown.bind(this)
    this.boundBeforeMorphElement = this.beforeMorphElement.bind(this)
    this.boundHandleMorph = this.handleMorph.bind(this)
    document.addEventListener("turbo:before-cache", this.boundTeardown)
    document.addEventListener("turbo:before-morph-element", this.boundBeforeMorphElement)
    document.addEventListener("turbo:morph", this.boundHandleMorph)

    this.updateStateImmediate()
  }

  disconnect() {
    window.removeEventListener("resize", this.resizeHandler)
    document.removeEventListener("turbo:before-cache", this.boundTeardown)
    document.removeEventListener("turbo:before-morph-element", this.boundBeforeMorphElement)
    document.removeEventListener("turbo:morph", this.boundHandleMorph)
  }

  // ============================================================================
  // Turbo Cache Teardown
  // ============================================================================

  teardown() {
    this.openValue = false

    if (this.hasBackdropTarget) {
      this.backdropTarget.setAttribute("data-state", "hidden")
      this.backdropTarget.classList.add("hidden")
    }

    this.unlockScroll()
  }

  beforeMorphElement(event) {
    if (event.target === this.element) {
      this._morphing = true
    }
  }

  handleMorph() {
    const cookieValue = this.getCookie(this.cookieNameValue)

    if (cookieValue !== null) {
      this.openValue = cookieValue === "true"
    }

    if (this.hasDrawerTarget) {
      this.drawerTarget.classList.remove("drawer-loading")
    }

    this.updateState()
    this._morphing = false
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
    if (this._morphing) return

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
  lockScroll() {
    this.scrollPosition = window.pageYOffset
    document.body.style.setProperty("--maquina-scroll-lock-top", `-${this.scrollPosition}px`)
    document.body.setAttribute("data-maquina-scroll-locked", "")
  }

  unlockScroll() {
    document.body.removeAttribute("data-maquina-scroll-locked")
    document.body.style.removeProperty("--maquina-scroll-lock-top")
    if (this.scrollPosition !== undefined) {
      window.scrollTo(0, this.scrollPosition)
    }
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

  // ============================================================================
  // Utilities
  // ============================================================================

  checkScreenSize() {
  }

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