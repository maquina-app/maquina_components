import { Controller } from "@hotwired/stimulus"

/**
 * DatePicker Controller
 *
 * Coordinates the trigger button, popover, and calendar.
 * Uses native Popover API - minimal JS needed.
 *
 * @example Single date
 *   <div data-controller="date-picker"
 *        data-date-picker-mode-value="single">
 *     <button popovertarget="popover-id">Pick date</button>
 *     <div id="popover-id" popover>
 *       <!-- Calendar component -->
 *     </div>
 *   </div>
 */
export default class extends Controller {
  static targets = ["trigger", "popover", "calendar", "input", "inputEnd", "display"]

  static values = {
    mode: { type: String, default: "single" },
    selected: String,
    selectedEnd: String,
    format: { type: String, default: "long" },
    placeholder: String,
    placeholderRange: String,
    // I18n date data from date_picker_locale_data: strftime patterns and
    // localized names, so the display matches the server-rendered text
    locale: Object
  }

  connect() {
    this.boundTeardown = this.teardown.bind(this)

    this.setupPopoverEvents()
    this.updateDisplay()
    document.addEventListener("turbo:before-cache", this.boundTeardown)
  }

  disconnect() {
    this.teardownPopoverEvents()
    document.removeEventListener("turbo:before-cache", this.boundTeardown)
  }

  /**
   * Reset to closed state before Turbo caches the page
   */
  teardown() {
    if (this.hasPopoverTarget) {
      try {
        if (this.popoverTarget.matches(":popover-open")) {
          this.popoverTarget.hidePopover()
        }
      } catch {
        // Popover API not supported
      }
    }

    if (this.hasTriggerTarget) {
      this.triggerTarget.setAttribute("aria-expanded", "false")
    }
  }

  /**
   * Setup popover toggle events for aria-expanded
   */
  setupPopoverEvents() {
    if (this.hasPopoverTarget) {
      this.boundHandleToggle = this.handlePopoverToggle.bind(this)
      this.popoverTarget.addEventListener("toggle", this.boundHandleToggle)
    }
  }

  teardownPopoverEvents() {
    if (this.hasPopoverTarget && this.boundHandleToggle) {
      this.popoverTarget.removeEventListener("toggle", this.boundHandleToggle)
    }
  }

  /**
   * Handle popover toggle event
   * Updates aria-expanded on trigger
   */
  handlePopoverToggle(event) {
    const isOpen = event.newState === "open"

    if (this.hasTriggerTarget) {
      this.triggerTarget.setAttribute("aria-expanded", isOpen.toString())
    }

    if (isOpen && this.hasCalendarTarget) {
      // Focus first focusable element in calendar after opening
      requestAnimationFrame(() => {
        const focusable = this.calendarTarget.querySelector("[data-today], [data-calendar-part='day']")
        focusable?.focus()
      })
    }
  }

  /**
   * Handle calendar change event
   * @param {CustomEvent} event - calendar:change event
   */
  handleChange(event) {
    const { selected, selectedEnd } = event.detail

    this.selectedValue = selected || ""
    this.selectedEndValue = selectedEnd || ""

    this.updateInputs()
    this.updateDisplay()

    // Close popover after selection in single mode
    // In range mode, close after both dates selected
    if (this.modeValue === "single" && selected) {
      this.closePopover()
    } else if (this.modeValue === "range" && selected && selectedEnd) {
      this.closePopover()
    }

    // Dispatch change event
    this.dispatch("change", {
      detail: {
        selected: this.selectedValue || null,
        selectedEnd: this.selectedEndValue || null
      }
    })
  }

  /**
   * Handle calendar navigate event
   * Can be used to fetch events for the new month
   */
  handleNavigate(event) {
    this.dispatch("navigate", { detail: event.detail })
  }

  /**
   * Update hidden input values
   */
  updateInputs() {
    if (this.hasInputTarget) {
      this.inputTarget.value = this.selectedValue || ""
    }
    if (this.hasInputEndTarget) {
      this.inputEndTarget.value = this.selectedEndValue || ""
    }
  }

  /**
   * Update display text
   */
  updateDisplay() {
    if (!this.hasDisplayTarget) return

    const selected = this.selectedValue
    const selectedEnd = this.selectedEndValue

    let displayText = ""

    if (this.modeValue === "range") {
      if (selected && selectedEnd) {
        displayText = `${this.formatDate(selected, "short")} - ${this.formatDate(selectedEnd, "short")}`
      } else if (selected) {
        displayText = `${this.formatDate(selected, "short")} - ...`
      } else {
        displayText = this.placeholderRangeValue || "Select date range"
      }
    } else {
      if (selected) {
        displayText = this.formatDate(selected, this.formatValue)
      } else {
        displayText = this.placeholderValue || "Select date"
      }
    }

    this.displayTarget.textContent = displayText

    // Toggle placeholder styling
    const placeholderIndicator = this.triggerTarget?.querySelector("[data-date-picker-part='placeholder-indicator']")
    if (placeholderIndicator) {
      placeholderIndicator.remove()
    }

    if (!selected) {
      const indicator = document.createElement("span")
      indicator.setAttribute("data-date-picker-part", "placeholder-indicator")
      this.displayTarget.after(indicator)
    }
  }

  /**
   * Format date for display, mirroring the server's date_picker_format:
   * the locale's strftime pattern when there is one, Intl otherwise.
   */
  formatDate(dateStr, format = "long") {
    if (!dateStr) return ""

    const date = new Date(dateStr + "T00:00:00")
    if (isNaN(date)) return dateStr

    const pattern = this.localeValue.formats?.[format === "short" ? "short" : "long"]
    if (pattern) return this.strftime(date, pattern)

    const options = format === "short"
      ? { month: "short", day: "numeric", year: "numeric" }
      : { month: "long", day: "numeric", year: "numeric" }

    return date.toLocaleDateString(document.documentElement.lang || undefined, options)
  }

  /**
   * The strftime subset Rails locale date formats use. "%-d" drops padding.
   */
  strftime(date, pattern) {
    const locale = this.localeValue
    const pad = (number, width = 2) => String(number).padStart(width, "0")

    return pattern.replace(/%(-?)([a-zA-Z%])/g, (match, noPad, directive) => {
      const padded = (number) => noPad ? String(number) : pad(number)

      switch (directive) {
        case "Y": return String(date.getFullYear())
        case "y": return pad(date.getFullYear() % 100)
        case "m": return padded(date.getMonth() + 1)
        case "d": return padded(date.getDate())
        case "e": return noPad ? String(date.getDate()) : String(date.getDate()).padStart(2, " ")
        case "j": {
          const start = new Date(date.getFullYear(), 0, 1)
          const day = Math.round((date - start) / 86400000) + 1
          return noPad ? String(day) : pad(day, 3)
        }
        case "B": return locale.month_names?.[date.getMonth() + 1] ?? match
        case "b": return locale.abbr_month_names?.[date.getMonth() + 1] ?? match
        case "A": return locale.day_names?.[date.getDay()] ?? match
        case "a": return locale.abbr_day_names?.[date.getDay()] ?? match
        case "%": return "%"
        default: return match
      }
    })
  }

  /**
   * Close the popover
   */
  closePopover() {
    if (this.hasPopoverTarget) {
      this.popoverTarget.hidePopover()
    }
  }

  /**
   * Open the popover
   */
  openPopover() {
    if (this.hasPopoverTarget) {
      this.popoverTarget.showPopover()
    }
  }

  /**
   * Toggle the popover
   */
  toggle() {
    if (this.hasPopoverTarget) {
      this.popoverTarget.togglePopover()
    }
  }

  /**
   * Clear the selection
   */
  clear() {
    const calendarController = this.hasCalendarTarget &&
      this.application.getControllerForElementAndIdentifier(this.calendarTarget, "calendar")

    // The calendar's own calendar:change runs handleChange, which updates the
    // inputs and display and dispatches date-picker:change exactly once
    if (calendarController) {
      calendarController.clear()
      return
    }

    this.selectedValue = ""
    this.selectedEndValue = ""
    this.updateInputs()
    this.updateDisplay()

    this.dispatch("change", {
      detail: { selected: null, selectedEnd: null }
    })
  }

  /**
   * Get current value(s)
   */
  getValue() {
    return {
      selected: this.selectedValue || null,
      selectedEnd: this.selectedEndValue || null
    }
  }

  /**
   * Programmatically set value
   */
  setValue(selected, selectedEnd = null) {
    this.selectedValue = selected || ""
    this.selectedEndValue = selectedEnd || ""
    this.updateInputs()
    this.updateDisplay()

    this.dispatch("change", {
      detail: {
        selected: this.selectedValue || null,
        selectedEnd: this.selectedEndValue || null
      }
    })
  }
}
