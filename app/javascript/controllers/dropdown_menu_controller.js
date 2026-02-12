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

    // Focus first item after animation
    requestAnimationFrame(() => {
      this.focusFirstItem()
    })
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
