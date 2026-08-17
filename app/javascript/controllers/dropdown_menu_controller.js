import { Controller } from "@hotwired/stimulus"

/**
 * DropdownMenu Controller
 * 
 * Handles opening/closing dropdown menus with:
 * - Click to toggle
 * - Click outside to close
 * - Escape key to close
 * - Keyboard navigation within menu
 * - Focus management
 * - Animation states
 */
export default class extends Controller {
  static targets = ["trigger", "content", "chevron"]

  static values = {
    open: { type: Boolean, default: false },
    autoClose: { type: Boolean, default: false }
  }

  connect() {
    this.handleClickOutside = this.handleClickOutside.bind(this)
    this.handleKeydown = this.handleKeydown.bind(this)
    this.boundTeardown = this.teardown.bind(this)

    // Set initial state on root element
    this.element.dataset.state = "closed"
    this.element.addEventListener("click", this.handleItemClick)
    document.addEventListener("turbo:before-cache", this.boundTeardown)
  }

  disconnect() {
    this.removeEventListeners()
    this.element.removeEventListener("click", this.handleItemClick)
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
    this.element.dataset.state = "open"
    this.contentTarget.dataset.state = "open"
    this.contentTarget.hidden = false

    // Update trigger aria
    if (this.hasTriggerTarget) {
      this.triggerTarget.setAttribute("aria-expanded", "true")
    }

    // Add event listeners
    this.addEventListeners()

    // Measure after the paint, not here: dataset.state was just set and the
    // content is still laid out at its pre-open box in this tick.
    requestAnimationFrame(() => {
      this.positionContent()
      this.focusFirstItem()
    })
  }

  // The placement the author asked for, captured before we ever overwrite it.
  // Memoised on first read, which happens on the first open() -- i.e. while
  // data-side is still whatever the partial rendered.
  get authoredSide() {
    if (this._authoredSide === undefined) {
      this._authoredSide = (this.hasContentTarget && this.contentTarget.dataset.side) || "bottom"
    }

    return this._authoredSide
  }

  // Flip the menu above the trigger when it would otherwise open past the
  // bottom of the viewport. CSS already styles every side; nothing was ever
  // choosing one from geometry.
  positionContent() {
    if (!this.hasContentTarget) return

    const content = this.contentTarget
    const side = this.authoredSide

    // Always re-measure from the authored placement. Without this reset a menu
    // flipped once in a short window stays flipped after the window grows.
    content.dataset.side = side

    // Only the block axis flips; left/right placements are deliberate.
    if (side !== "bottom" && side !== "top") return

    const trigger = this.hasTriggerTarget ? this.triggerTarget : this.element
    const triggerRect = trigger.getBoundingClientRect()
    const gap = 4 // matches the mt-1 / mb-1 in dropdown_menu.css
    const needed = content.getBoundingClientRect().height + gap
    const roomBelow = window.innerHeight - triggerRect.bottom
    const roomAbove = triggerRect.top

    // Flip only when the other side genuinely fits. Flipping into a space that
    // is also too small trades one clipped menu for another.
    if (side === "bottom" && needed > roomBelow && needed <= roomAbove) {
      content.dataset.side = "top"
    } else if (side === "top" && needed > roomAbove && needed <= roomBelow) {
      content.dataset.side = "bottom"
    }
  }

  close() {
    if (!this.openValue || !this.hasContentTarget) return

    // Start closing animation
    this.contentTarget.dataset.state = "closing"

    // Wait for animation to complete
    const animationDuration = 100 // matches CSS animation duration

    this._closeTimeout = setTimeout(() => {
      this._closeTimeout = null
      this.openValue = false
      this.element.dataset.state = "closed"
      this.contentTarget.dataset.state = "closed"
      this.contentTarget.hidden = true

      // Update trigger aria
      if (this.hasTriggerTarget) {
        this.triggerTarget.setAttribute("aria-expanded", "false")
      }

      // Remove event listeners
      this.removeEventListeners()

      // Return focus to trigger
      if (this.hasTriggerTarget) {
        this.triggerTarget.focus()
      }
    }, animationDuration)
  }

  // Turbo Cache Teardown

  teardown() {
    if (this._closeTimeout) {
      clearTimeout(this._closeTimeout)
      this._closeTimeout = null
    }

    this.openValue = false
    this.element.dataset.state = "closed"

    if (this.hasContentTarget) {
      this.contentTarget.dataset.state = "closed"
      this.contentTarget.hidden = true
    }

    if (this.hasTriggerTarget) {
      this.triggerTarget.setAttribute("aria-expanded", "false")
    }

    this.removeEventListeners()
  }

  handleItemClick = (event) => {
    if (!this.autoCloseValue || !this.openValue) return

    const item = event.target.closest('[data-dropdown-menu-part="item"]')
    if (!item) return
    if (item.disabled || item.getAttribute("aria-disabled") === "true") return

    this.teardown()
  }

  // Event Handlers

  handleClickOutside(event) {
    if (!this.openValue) return
    if (this.element.contains(event.target)) return

    this.close()
  }

  handleKeydown(event) {
    if (!this.openValue) return

    switch (event.key) {
      case "Escape":
        event.preventDefault()
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

      case "Tab":
        // Close menu and let focus move naturally
        this.close()
        break
    }
  }

  // Focus Management

  get menuItems() {
    if (!this.hasContentTarget) return []

    return Array.from(
      this.contentTarget.querySelectorAll('[data-dropdown-menu-part="item"]:not([disabled]):not([aria-disabled="true"])')
    )
  }

  get focusedItemIndex() {
    const items = this.menuItems
    const focused = document.activeElement
    return items.indexOf(focused)
  }

  focusFirstItem() {
    const items = this.menuItems
    if (items.length > 0) {
      items[0].focus()
    }
  }

  focusLastItem() {
    const items = this.menuItems
    if (items.length > 0) {
      items[items.length - 1].focus()
    }
  }

  focusNextItem() {
    const items = this.menuItems
    if (items.length === 0) return

    const currentIndex = this.focusedItemIndex
    const nextIndex = currentIndex < items.length - 1 ? currentIndex + 1 : 0
    items[nextIndex].focus()
  }

  focusPreviousItem() {
    const items = this.menuItems
    if (items.length === 0) return

    const currentIndex = this.focusedItemIndex
    const prevIndex = currentIndex > 0 ? currentIndex - 1 : items.length - 1
    items[prevIndex].focus()
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
