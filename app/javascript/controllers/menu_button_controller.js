import { Controller } from "@hotwired/stimulus"

/**
 * MenuButton Controller
 *
 * Sidebar-flavored button that toggles a dropdown panel with:
 * - Click to toggle
 * - Click outside to close
 * - Escape key to close
 * - aria-expanded state on the trigger
 * - Animation states via data-state
 */
export default class extends Controller {
  static targets = ["button", "content"]

  static values = {
    open: { type: Boolean, default: false }
  }

  connect() {
    this.handleClickOutside = this.handleClickOutside.bind(this)
    this.handleKeydown = this.handleKeydown.bind(this)
    this.boundTeardown = this.teardown.bind(this)

    document.addEventListener("turbo:before-cache", this.boundTeardown)

    if (this.hasContentTarget) {
      this.contentTarget.hidden = !this.openValue
    }
  }

  disconnect() {
    this.removeEventListeners()
    document.removeEventListener("turbo:before-cache", this.boundTeardown)
  }

  toggle(event) {
    event?.preventDefault()

    if (this.openValue) {
      this.close()
    } else {
      this.open()
    }
  }

  open() {
    if (this.openValue || !this.hasContentTarget) return

    this.openValue = true
    this.buttonTarget.dataset.state = "open"
    this.buttonTarget.setAttribute("aria-expanded", "true")
    this.contentTarget.dataset.state = "open"
    this.contentTarget.classList.remove("hidden")
    this.contentTarget.hidden = false

    this.addEventListeners()

    // Measure after the paint: the content is still at its pre-open box here.
    requestAnimationFrame(() => this.positionContent())
  }

  // The placement the author asked for, read before we ever overwrite it.
  get authoredSide() {
    if (this._authoredSide === undefined) {
      this._authoredSide = (this.hasContentTarget && this.contentTarget.dataset.side) || "bottom"
    }

    return this._authoredSide
  }

  // Flip above the button when the menu would open past the bottom of the
  // viewport and there is room above. Mirrors dropdown_menu_controller.
  positionContent() {
    if (!this.hasContentTarget || !this.hasButtonTarget) return

    const content = this.contentTarget
    const side = this.authoredSide

    // Reset first, so a menu flipped in a short window unflips once it grows.
    content.dataset.side = side

    if (side !== "bottom" && side !== "top") return

    const buttonRect = this.buttonTarget.getBoundingClientRect()
    const gap = 4 // matches the calc(100% + 4px) offsets in menu_button.css
    const needed = content.getBoundingClientRect().height + gap
    const roomBelow = window.innerHeight - buttonRect.bottom
    const roomAbove = buttonRect.top

    if (side === "bottom" && needed > roomBelow && needed <= roomAbove) {
      content.dataset.side = "top"
    } else if (side === "top" && needed > roomAbove && needed <= roomBelow) {
      content.dataset.side = "bottom"
    }
  }

  close() {
    if (!this.openValue || !this.hasContentTarget) return

    // Start closing animation, then hide once it finishes
    this.contentTarget.dataset.state = "closing"

    const animationDuration = 100 // matches CSS animation duration

    this._closeTimeout = setTimeout(() => {
      this._closeTimeout = null
      this.openValue = false
      this.buttonTarget.dataset.state = "closed"
      this.buttonTarget.setAttribute("aria-expanded", "false")
      this.contentTarget.dataset.state = "closed"
      this.contentTarget.hidden = true

      this.removeEventListeners()
      this.buttonTarget.focus()
    }, animationDuration)
  }

  // Turbo Cache Teardown

  teardown() {
    if (this._closeTimeout) {
      clearTimeout(this._closeTimeout)
      this._closeTimeout = null
    }

    this.openValue = false

    if (this.hasButtonTarget) {
      this.buttonTarget.dataset.state = "closed"
      this.buttonTarget.setAttribute("aria-expanded", "false")
    }

    if (this.hasContentTarget) {
      this.contentTarget.dataset.state = "closed"
      this.contentTarget.hidden = true
    }

    this.removeEventListeners()
  }

  // Event Handlers

  handleClickOutside(event) {
    if (!this.openValue) return
    if (this.element.contains(event.target)) return

    this.close()
  }

  handleKeydown(event) {
    if (!this.openValue) return

    if (event.key === "Escape") {
      event.preventDefault()
      this.close()
    }
  }

  // Event Listener Management

  addEventListeners() {
    // Delay adding click outside listener to prevent immediate close
    setTimeout(() => {
      document.addEventListener("click", this.handleClickOutside)
    }, 0)

    document.addEventListener("keydown", this.handleKeydown)
  }

  removeEventListeners() {
    document.removeEventListener("click", this.handleClickOutside)
    document.removeEventListener("keydown", this.handleKeydown)
  }
}
