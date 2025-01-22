import { Controller } from "@hotwired/stimulus"

/**
 * Toggle Group Controller
 * 
 * Manages a group of toggle buttons with single or multiple selection.
 * 
 * @example Single selection
 *   <div data-controller="toggle-group" 
 *        data-toggle-group-type-value="single"
 *        data-toggle-group-selected-value='["bold"]'>
 *     <button data-toggle-group-target="item" data-value="bold">Bold</button>
 *     <button data-toggle-group-target="item" data-value="italic">Italic</button>
 *   </div>
 * 
 * @example Multiple selection
 *   <div data-controller="toggle-group" 
 *        data-toggle-group-type-value="multiple"
 *        data-toggle-group-selected-value='["bold", "italic"]'>
 *     ...
 *   </div>
 */
export default class extends Controller {
  static targets = ["item"]

  static values = {
    type: { type: String, default: "single" },
    selected: { type: Array, default: [] }
  }

  connect() {
    this.syncItemStates()
  }

  /**
   * Toggle an item's state
   * @param {Event} event - Click event from toggle item
   */
  toggle(event) {
    const item = event.currentTarget
    if (item.disabled) return

    const value = item.dataset.value
    const isPressed = item.dataset.state === "on"

    if (this.typeValue === "single") {
      if (isPressed) {
        this.selectedValue = []
      } else {
        this.selectedValue = [value]
      }
    } else {
      if (isPressed) {
        this.selectedValue = this.selectedValue.filter(v => v !== value)
      } else {
        this.selectedValue = [...this.selectedValue, value]
      }
    }

    this.syncItemStates()
    this.dispatchChange()
  }

  /**
   * Handle keyboard navigation
   * @param {KeyboardEvent} event
   */
  handleKeydown(event) {
    const item = event.currentTarget
    const items = this.itemTargets.filter(i => !i.disabled)
    const currentIndex = items.indexOf(item)

    let nextIndex = currentIndex

    switch (event.key) {
      case "ArrowRight":
      case "ArrowDown":
        event.preventDefault()
        nextIndex = (currentIndex + 1) % items.length
        break
      case "ArrowLeft":
      case "ArrowUp":
        event.preventDefault()
        nextIndex = (currentIndex - 1 + items.length) % items.length
        break
      case "Home":
        event.preventDefault()
        nextIndex = 0
        break
      case "End":
        event.preventDefault()
        nextIndex = items.length - 1
        break
      case " ":
      case "Enter":
        return
      default:
        return
    }

    items[nextIndex]?.focus()
  }

  /**
   * Sync visual states with selectedValue
   */
  syncItemStates() {
    this.itemTargets.forEach(item => {
      const value = item.dataset.value
      const isSelected = this.selectedValue.includes(value)

      item.dataset.state = isSelected ? "on" : "off"
      item.setAttribute("aria-pressed", isSelected)
    })
  }

  /**
   * Dispatch change event
   */
  dispatchChange() {
    const detail = {
      type: this.typeValue,
      value: this.typeValue === "single"
        ? (this.selectedValue[0] || null)
        : this.selectedValue
    }

    this.dispatch("change", { detail })

    this.element.dispatchEvent(new CustomEvent("toggle-group:change", {
      bubbles: true,
      detail
    }))
  }

  /**
   * Programmatically select a value
   * @param {string} value - Value to select
   */
  select(value) {
    if (this.typeValue === "single") {
      this.selectedValue = [value]
    } else if (!this.selectedValue.includes(value)) {
      this.selectedValue = [...this.selectedValue, value]
    }
    this.syncItemStates()
    this.dispatchChange()
  }

  /**
   * Programmatically deselect a value
   * @param {string} value - Value to deselect
   */
  deselect(value) {
    this.selectedValue = this.selectedValue.filter(v => v !== value)
    this.syncItemStates()
    this.dispatchChange()
  }

  /**
   * Clear all selections
   */
  clear() {
    this.selectedValue = []
    this.syncItemStates()
    this.dispatchChange()
  }

  /**
   * Get current value(s)
   * @returns {string|string[]|null}
   */
  getValue() {
    return this.typeValue === "single"
      ? (this.selectedValue[0] || null)
      : this.selectedValue
  }
}
