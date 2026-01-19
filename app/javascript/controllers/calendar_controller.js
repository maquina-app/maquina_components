import { Controller } from "@hotwired/stimulus"

/**
 * Calendar Controller
 *
 * Manages calendar navigation and date selection.
 * Supports single and range selection modes.
 *
 * @example Single selection
 *   <div data-controller="calendar"
 *        data-calendar-mode-value="single"
 *        data-calendar-selected-value="2025-01-15">
 *     ...
 *   </div>
 *
 * @example Range selection
 *   <div data-controller="calendar"
 *        data-calendar-mode-value="range"
 *        data-calendar-selected-value="2025-01-15"
 *        data-calendar-selected-end-value="2025-01-20">
 *     ...
 *   </div>
 */
export default class extends Controller {
  static targets = ["day", "input", "inputEnd", "prevButton", "nextButton"]

  static values = {
    month: Number,
    year: Number,
    selected: String,
    selectedEnd: String,
    minDate: String,
    maxDate: String,
    mode: { type: String, default: "single" },
    weekStartsOn: { type: String, default: "sunday" }
  }

  connect() {
    this.updateNavigationState()
  }

  /**
   * Navigate to previous month
   */
  previousMonth() {
    let newMonth = this.monthValue - 1
    let newYear = this.yearValue

    if (newMonth < 1) {
      newMonth = 12
      newYear -= 1
    }

    this.navigateToMonth(newMonth, newYear)
  }

  /**
   * Navigate to next month
   */
  nextMonth() {
    let newMonth = this.monthValue + 1
    let newYear = this.yearValue

    if (newMonth > 12) {
      newMonth = 1
      newYear += 1
    }

    this.navigateToMonth(newMonth, newYear)
  }

  /**
   * Navigate to specific month/year
   * Dispatches event for Turbo Frame reload or parent handling
   */
  navigateToMonth(month, year) {
    this.monthValue = month
    this.yearValue = year

    this.dispatch("navigate", {
      detail: {
        month,
        year,
        selected: this.selectedValue,
        selectedEnd: this.selectedEndValue
      }
    })

    this.updateNavigationState()
  }

  /**
   * Select a day
   * @param {Event} event - Click event from day button
   */
  selectDay(event) {
    const button = event.currentTarget
    if (button.disabled) return

    const dateStr = button.dataset.date

    if (this.modeValue === "range") {
      this.handleRangeSelection(dateStr)
    } else {
      this.handleSingleSelection(dateStr)
    }
  }

  /**
   * Handle single date selection
   */
  handleSingleSelection(dateStr) {
    if (this.selectedValue === dateStr) {
      this.selectedValue = ""
    } else {
      this.selectedValue = dateStr
    }

    this.updateDayStates()
    this.updateInputs()
    this.dispatchChange()
  }

  /**
   * Handle range date selection
   */
  handleRangeSelection(dateStr) {
    const clickedDate = new Date(dateStr)
    const selectedDate = this.selectedValue ? new Date(this.selectedValue) : null
    const selectedEndDate = this.selectedEndValue ? new Date(this.selectedEndValue) : null

    if (!selectedDate || (selectedDate && selectedEndDate)) {
      this.selectedValue = dateStr
      this.selectedEndValue = ""
    } else {
      if (clickedDate < selectedDate) {
        this.selectedEndValue = this.selectedValue
        this.selectedValue = dateStr
      } else if (clickedDate.getTime() === selectedDate.getTime()) {
        this.selectedValue = ""
        this.selectedEndValue = ""
      } else {
        this.selectedEndValue = dateStr
      }
    }

    this.updateDayStates()
    this.updateInputs()
    this.dispatchChange()
  }

  /**
   * Handle keyboard navigation
   * @param {KeyboardEvent} event
   */
  handleKeydown(event) {
    const currentButton = event.currentTarget
    const currentDate = new Date(currentButton.dataset.date)
    let targetDate = null

    switch (event.key) {
      case "ArrowRight":
        event.preventDefault()
        targetDate = new Date(currentDate)
        targetDate.setDate(targetDate.getDate() + 1)
        break
      case "ArrowLeft":
        event.preventDefault()
        targetDate = new Date(currentDate)
        targetDate.setDate(targetDate.getDate() - 1)
        break
      case "ArrowDown":
        event.preventDefault()
        targetDate = new Date(currentDate)
        targetDate.setDate(targetDate.getDate() + 7)
        break
      case "ArrowUp":
        event.preventDefault()
        targetDate = new Date(currentDate)
        targetDate.setDate(targetDate.getDate() - 7)
        break
      case "Home":
        event.preventDefault()
        targetDate = new Date(currentDate.getFullYear(), currentDate.getMonth(), 1)
        break
      case "End":
        event.preventDefault()
        targetDate = new Date(currentDate.getFullYear(), currentDate.getMonth() + 1, 0)
        break
      case "Enter":
      case " ":
        return
      default:
        return
    }

    if (targetDate) {
      this.focusDate(targetDate)
    }
  }

  /**
   * Focus a specific date
   */
  focusDate(date) {
    const dateStr = this.formatDate(date)
    const targetButton = this.dayTargets.find(btn => btn.dataset.date === dateStr)

    if (targetButton && !targetButton.disabled) {
      targetButton.focus()
    } else {
      this.navigateToMonth(date.getMonth() + 1, date.getFullYear())
    }
  }

  /**
   * Update day button states
   */
  updateDayStates() {
    const selectedDate = this.selectedValue ? new Date(this.selectedValue) : null
    const selectedEndDate = this.selectedEndValue ? new Date(this.selectedEndValue) : null

    this.dayTargets.forEach(button => {
      const date = new Date(button.dataset.date)
      let state = null

      if (this.modeValue === "range" && selectedDate && selectedEndDate) {
        if (date.getTime() === selectedDate.getTime()) {
          state = "range-start"
        } else if (date.getTime() === selectedEndDate.getTime()) {
          state = "range-end"
        } else if (date > selectedDate && date < selectedEndDate) {
          state = "range-middle"
        }
      } else if (this.modeValue === "range" && selectedDate && !selectedEndDate) {
        if (date.getTime() === selectedDate.getTime()) {
          state = "range-start"
        }
      } else if (selectedDate && date.getTime() === selectedDate.getTime()) {
        state = "selected"
      }

      if (state) {
        button.dataset.state = state
        button.setAttribute("aria-selected", "true")
      } else {
        delete button.dataset.state
        button.removeAttribute("aria-selected")
      }
    })
  }

  /**
   * Update hidden inputs
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
   * Update navigation button states based on min/max dates
   */
  updateNavigationState() {
    if (this.minDateValue && this.hasPrevButtonTarget) {
      const minDate = new Date(this.minDateValue)
      const firstOfMonth = new Date(this.yearValue, this.monthValue - 1, 1)
      this.prevButtonTarget.disabled = firstOfMonth <= minDate
    }

    if (this.maxDateValue && this.hasNextButtonTarget) {
      const maxDate = new Date(this.maxDateValue)
      const lastOfMonth = new Date(this.yearValue, this.monthValue, 0)
      this.nextButtonTarget.disabled = lastOfMonth >= maxDate
    }
  }

  /**
   * Dispatch change event
   */
  dispatchChange() {
    const detail = {
      mode: this.modeValue,
      selected: this.selectedValue || null,
      selectedEnd: this.selectedEndValue || null
    }

    this.dispatch("change", { detail })

    this.element.dispatchEvent(new CustomEvent("calendar:change", {
      bubbles: true,
      detail
    }))
  }

  /**
   * Format date as ISO string (YYYY-MM-DD)
   */
  formatDate(date) {
    const year = date.getFullYear()
    const month = String(date.getMonth() + 1).padStart(2, "0")
    const day = String(date.getDate()).padStart(2, "0")
    return `${year}-${month}-${day}`
  }

  /**
   * Get current value(s)
   * @returns {Object}
   */
  getValue() {
    return {
      selected: this.selectedValue || null,
      selectedEnd: this.selectedEndValue || null
    }
  }

  /**
   * Programmatically select a date
   * @param {string|Date} date
   */
  select(date) {
    const dateStr = date instanceof Date ? this.formatDate(date) : date

    if (this.modeValue === "single") {
      this.selectedValue = dateStr
    } else {
      this.handleRangeSelection(dateStr)
      return
    }

    this.updateDayStates()
    this.updateInputs()
    this.dispatchChange()
  }

  /**
   * Clear selection
   */
  clear() {
    this.selectedValue = ""
    this.selectedEndValue = ""
    this.updateDayStates()
    this.updateInputs()
    this.dispatchChange()
  }
}
