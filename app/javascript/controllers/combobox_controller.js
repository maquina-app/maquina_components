import { Controller } from "@hotwired/stimulus"

/**
 * Combobox Controller
 *
 * Handles autocomplete/search functionality with:
 * - HTML5 Popover API for light-dismiss
 * - Type-ahead filtering
 * - Single selection with toggle
 * - Keyboard navigation
 * - Focus management
 */
export default class extends Controller {
  static targets = ["trigger", "content", "input", "option", "empty", "label"]

  static values = {
    value: { type: String, default: "" },
    name: String,
    placeholder: { type: String, default: "Select..." }
  }

  connect() {
    this.handlePopoverToggle = this.handlePopoverToggle.bind(this)
    this.handleContentKeydown = this.handleContentKeydown.bind(this)

    if (this.hasContentTarget) {
      this.contentTarget.addEventListener("toggle", this.handlePopoverToggle)
      this.contentTarget.addEventListener("keydown", this.handleContentKeydown)
    }

    // Set initial selection if value is provided
    if (this.valueValue) {
      this.updateSelectionFromValue()
    }

    // Update trigger state
    this.updateTriggerState()
  }

  disconnect() {
    if (this.hasContentTarget) {
      this.contentTarget.removeEventListener("toggle", this.handlePopoverToggle)
      this.contentTarget.removeEventListener("keydown", this.handleContentKeydown)
    }
  }

  // Popover toggle handling
  toggle(event) {
    // Popover API handles toggle via popovertarget attribute
    // This method is here for programmatic control if needed
  }

  handlePopoverToggle(event) {
    const isOpen = event.newState === "open"

    if (this.hasTriggerTarget) {
      this.triggerTarget.setAttribute("aria-expanded", isOpen)
    }

    if (isOpen) {
      // Position the popover relative to the trigger
      this.positionPopover()

      // Focus input when opened
      if (this.hasInputTarget) {
        requestAnimationFrame(() => {
          this.inputTarget.focus()
          this.inputTarget.value = ""
          this.resetFilter()
        })
      }
    }
  }

  positionPopover() {
    if (!this.hasTriggerTarget || !this.hasContentTarget) return

    const trigger = this.triggerTarget
    const content = this.contentTarget
    const triggerRect = trigger.getBoundingClientRect()

    // Get alignment from data attribute
    const align = content.dataset.align || "start"

    // Calculate position
    let left = triggerRect.left
    const top = triggerRect.bottom + 4 // 4px gap

    // Adjust for alignment
    if (align === "end") {
      left = triggerRect.right - content.offsetWidth
    } else if (align === "center") {
      left = triggerRect.left + (triggerRect.width / 2) - (content.offsetWidth / 2)
    }

    // Ensure popover doesn't go off-screen horizontally
    const viewportWidth = window.innerWidth
    if (left + content.offsetWidth > viewportWidth - 8) {
      left = viewportWidth - content.offsetWidth - 8
    }
    if (left < 8) {
      left = 8
    }

    // Apply position
    content.style.position = "fixed"
    content.style.top = `${top}px`
    content.style.left = `${left}px`
    content.style.margin = "0"

    // Set width to match trigger if content width is "default"
    const width = content.dataset.width
    if (width === "default" || !width) {
      content.style.minWidth = `${triggerRect.width}px`
    }
  }

  // Filtering
  filter() {
    if (!this.hasInputTarget) return

    const query = this.inputTarget.value.toLowerCase().trim()
    let visibleCount = 0

    this.optionTargets.forEach(option => {
      const text = option.textContent.toLowerCase()
      const matches = query === "" || text.includes(query)
      option.hidden = !matches
      if (matches) visibleCount++
    })

    // Show/hide empty state
    if (this.hasEmptyTarget) {
      this.emptyTarget.hidden = visibleCount > 0
    }
  }

  resetFilter() {
    this.optionTargets.forEach(option => {
      option.hidden = false
    })

    if (this.hasEmptyTarget) {
      this.emptyTarget.hidden = true
    }
  }

  // Selection
  select(event) {
    const option = event.currentTarget
    const value = option.dataset.value
    const label = this.getOptionLabel(option)

    // Toggle selection (clicking selected item deselects)
    if (this.valueValue === value) {
      this.valueValue = ""
      this.updateLabel(this.placeholderValue)
    } else {
      this.valueValue = value
      this.updateLabel(label)
    }

    this.updateSelection()
    this.updateTriggerState()

    // Close popover
    if (this.hasContentTarget) {
      this.contentTarget.hidePopover()
    }

    // Dispatch change event for external listeners
    this.dispatch("change", {
      detail: {
        value: this.valueValue,
        label: this.valueValue ? label : null
      }
    })
  }

  getOptionLabel(option) {
    // Get text content excluding the check icon
    const clone = option.cloneNode(true)
    const check = clone.querySelector('[data-combobox-part="check"]')
    if (check) check.remove()
    return clone.textContent.trim()
  }

  updateSelection() {
    this.optionTargets.forEach(option => {
      const isSelected = option.dataset.value === this.valueValue
      option.dataset.selected = isSelected
      option.setAttribute("aria-selected", isSelected)

      const check = option.querySelector('[data-combobox-part="check"]')
      if (check) {
        check.classList.toggle("invisible", !isSelected)
      }
    })
  }

  updateSelectionFromValue() {
    const selectedOption = this.optionTargets.find(
      option => option.dataset.value === this.valueValue
    )

    if (selectedOption) {
      const label = this.getOptionLabel(selectedOption)
      this.updateLabel(label)
      this.updateSelection()
    }
  }

  updateLabel(text) {
    if (this.hasLabelTarget) {
      this.labelTarget.textContent = text || this.placeholderValue
    }
  }

  updateTriggerState() {
    if (this.hasTriggerTarget) {
      this.triggerTarget.dataset.hasValue = this.valueValue !== ""
    }
  }

  // Keyboard navigation from input field
  keydown(event) {
    this.handleKeyboardNavigation(event)
  }

  // Keyboard navigation from content (options)
  handleContentKeydown(event) {
    this.handleKeyboardNavigation(event)
  }

  handleKeyboardNavigation(event) {
    switch (event.key) {
      case "ArrowDown":
        event.preventDefault()
        this.focusNextOption()
        break

      case "ArrowUp":
        event.preventDefault()
        this.focusPreviousOption()
        break

      case "Enter":
        event.preventDefault()
        this.selectFocusedOption()
        break

      case "Home":
        event.preventDefault()
        this.focusFirstOption()
        break

      case "End":
        event.preventDefault()
        this.focusLastOption()
        break

      case "Escape":
        event.preventDefault()
        if (this.hasContentTarget) {
          this.contentTarget.hidePopover()
        }
        break
    }
  }

  get visibleOptions() {
    return this.optionTargets.filter(opt => !opt.hidden && !opt.hasAttribute("aria-disabled"))
  }

  get focusedOptionIndex() {
    const options = this.visibleOptions
    const focused = document.activeElement
    return options.indexOf(focused)
  }

  focusFirstOption() {
    const options = this.visibleOptions
    if (options.length > 0) {
      options[0].focus()
    }
  }

  focusLastOption() {
    const options = this.visibleOptions
    if (options.length > 0) {
      options[options.length - 1].focus()
    }
  }

  focusNextOption() {
    const options = this.visibleOptions
    if (options.length === 0) return

    const currentIndex = this.focusedOptionIndex
    const nextIndex = currentIndex < options.length - 1 ? currentIndex + 1 : 0
    options[nextIndex].focus()
  }

  focusPreviousOption() {
    const options = this.visibleOptions
    if (options.length === 0) return

    const currentIndex = this.focusedOptionIndex
    const prevIndex = currentIndex > 0 ? currentIndex - 1 : options.length - 1
    options[prevIndex].focus()
  }

  selectFocusedOption() {
    const focused = document.activeElement
    if (this.optionTargets.includes(focused)) {
      this.select({ currentTarget: focused })
    }
  }

  // Value change callback
  valueValueChanged() {
    this.updateSelection()
    this.updateTriggerState()
  }
}
