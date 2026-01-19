import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["day", "input", "inputEnd", "prevButton", "nextButton", "grid", "caption"]

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

  previousMonth() {
    let newMonth = this.monthValue - 1
    let newYear = this.yearValue

    if (newMonth < 1) {
      newMonth = 12
      newYear -= 1
    }

    this.navigateToMonth(newMonth, newYear)
  }

  nextMonth() {
    let newMonth = this.monthValue + 1
    let newYear = this.yearValue

    if (newMonth > 12) {
      newMonth = 1
      newYear += 1
    }

    this.navigateToMonth(newMonth, newYear)
  }

  navigateToMonth(month, year) {
    this.monthValue = month
    this.yearValue = year

    this.rebuildCalendar()
    this.updateNavigationState()

    this.dispatch("navigate", {
      detail: {
        month,
        year,
        selected: this.selectedValue,
        selectedEnd: this.selectedEndValue
      }
    })
  }

  rebuildCalendar() {
    const grid = this.element.querySelector("[data-calendar-part='grid']")
    const caption = this.element.querySelector("[data-calendar-part='caption']")
    if (!grid) return

    const year = this.yearValue
    const month = this.monthValue
    const firstOfMonth = new Date(year, month - 1, 1)
    const lastOfMonth = new Date(year, month, 0)

    // Update caption
    if (caption) {
      caption.textContent = firstOfMonth.toLocaleDateString(undefined, { month: 'long', year: 'numeric' })
    }

    // Calculate start of calendar grid
    const weekStart = this.weekStartsOnValue === "monday" ? 1 : 0
    const daysBefore = (firstOfMonth.getDay() - weekStart + 7) % 7
    const calendarStart = new Date(firstOfMonth)
    calendarStart.setDate(calendarStart.getDate() - daysBefore)

    // Calculate weeks needed
    const totalDays = daysBefore + lastOfMonth.getDate()
    const weeksNeeded = Math.min(Math.ceil(totalDays / 7), 6)

    // Build weeks
    const weeks = []
    const currentDate = new Date(calendarStart)
    for (let w = 0; w < weeksNeeded; w++) {
      const week = []
      for (let d = 0; d < 7; d++) {
        week.push(new Date(currentDate))
        currentDate.setDate(currentDate.getDate() + 1)
      }
      weeks.push(week)
    }

    // Parse dates for comparison
    const selectedDate = this.selectedValue ? new Date(this.selectedValue) : null
    const selectedEndDate = this.selectedEndValue ? new Date(this.selectedEndValue) : null
    const minDate = this.minDateValue ? new Date(this.minDateValue) : null
    const maxDate = this.maxDateValue ? new Date(this.maxDateValue) : null

    // Rebuild grid HTML
    grid.innerHTML = weeks.map(week => this.buildWeekHTML(week, month, selectedDate, selectedEndDate, minDate, maxDate)).join('')
  }

  buildWeekHTML(days, displayMonth, selectedDate, selectedEndDate, minDate, maxDate) {
    // Use string comparisons for range to avoid timezone issues
    const selectedStr = this.selectedValue || ""
    const selectedEndStr = this.selectedEndValue || ""

    const daysHTML = days.map(day => {
      const dateStr = this.formatDate(day)
      const isOutside = day.getMonth() + 1 !== displayMonth
      const isToday = this.isSameDate(day, new Date())
      const isSelected = selectedStr && dateStr === selectedStr
      const isRangeEnd = selectedEndStr && dateStr === selectedEndStr
      // ISO date strings are lexicographically sortable
      const isRangeMiddle = selectedStr && selectedEndStr && dateStr > selectedStr && dateStr < selectedEndStr
      const isDisabled = (minDate && day < minDate) || (maxDate && day > maxDate)

      let dayState = null
      if (isSelected && this.modeValue === "range" && selectedEndStr) {
        dayState = "range-start"
      } else if (isRangeEnd) {
        dayState = "range-end"
      } else if (isRangeMiddle) {
        dayState = "range-middle"
      } else if (isSelected) {
        dayState = "selected"
      }

      const attrs = [
        'type="button"',
        'data-calendar-part="day"',
        'data-calendar-target="day"',
        `data-date="${dateStr}"`,
        `data-action="click->calendar#selectDay keydown->calendar#handleKeydown"`,
        `tabindex="${isToday ? '0' : '-1'}"`,
      ]

      if (dayState) {
        attrs.push(`data-state="${dayState}"`)
        attrs.push('aria-selected="true"')
      }
      if (isOutside) attrs.push('data-outside')
      if (isToday) attrs.push('data-today aria-current="date"')
      if (isDisabled) attrs.push('disabled')

      return `<button ${attrs.join(' ')}>${day.getDate()}</button>`
    }).join('')

    return `<div data-calendar-part="week" role="row">${daysHTML}</div>`
  }

  isSameDate(date1, date2) {
    return date1.getFullYear() === date2.getFullYear() &&
           date1.getMonth() === date2.getMonth() &&
           date1.getDate() === date2.getDate()
  }

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

  handleRangeSelection(dateStr) {
    // Use string comparisons to avoid timezone issues
    // ISO date strings are lexicographically sortable
    const selectedStr = this.selectedValue || ""
    const selectedEndStr = this.selectedEndValue || ""

    if (!selectedStr || (selectedStr && selectedEndStr)) {
      // No selection or complete range - start new selection
      this.selectedValue = dateStr
      this.selectedEndValue = ""
    } else {
      // Have start but no end
      if (dateStr < selectedStr) {
        // Clicked before start - swap
        this.selectedEndValue = this.selectedValue
        this.selectedValue = dateStr
      } else if (dateStr === selectedStr) {
        // Clicked same date - clear
        this.selectedValue = ""
        this.selectedEndValue = ""
      } else {
        // Clicked after start - set end
        this.selectedEndValue = dateStr
      }
    }

    this.updateDayStates()
    this.updateInputs()
    this.dispatchChange()
  }

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

  focusDate(date) {
    const dateStr = this.formatDate(date)
    const targetButton = this.dayTargets.find(btn => btn.dataset.date === dateStr)

    if (targetButton && !targetButton.disabled) {
      targetButton.focus()
    } else {
      this.navigateToMonth(date.getMonth() + 1, date.getFullYear())
      requestAnimationFrame(() => {
        const newButton = this.dayTargets.find(btn => btn.dataset.date === dateStr)
        if (newButton && !newButton.disabled) {
          newButton.focus()
        }
      })
    }
  }

  updateDayStates() {
    // Use string comparisons to avoid timezone issues
    const selectedStr = this.selectedValue || ""
    const selectedEndStr = this.selectedEndValue || ""

    this.dayTargets.forEach(button => {
      const dateStr = button.dataset.date
      let state = null

      if (this.modeValue === "range" && selectedStr && selectedEndStr) {
        if (dateStr === selectedStr) {
          state = "range-start"
        } else if (dateStr === selectedEndStr) {
          state = "range-end"
        } else if (dateStr > selectedStr && dateStr < selectedEndStr) {
          // ISO date strings are lexicographically sortable
          state = "range-middle"
        }
      } else if (this.modeValue === "range" && selectedStr && !selectedEndStr) {
        if (dateStr === selectedStr) {
          state = "range-start"
        }
      } else if (selectedStr && dateStr === selectedStr) {
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

  updateInputs() {
    if (this.hasInputTarget) {
      this.inputTarget.value = this.selectedValue || ""
    }
    if (this.hasInputEndTarget) {
      this.inputEndTarget.value = this.selectedEndValue || ""
    }
  }

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

  formatDate(date) {
    const year = date.getFullYear()
    const month = String(date.getMonth() + 1).padStart(2, "0")
    const day = String(date.getDate()).padStart(2, "0")
    return `${year}-${month}-${day}`
  }

  getValue() {
    return {
      selected: this.selectedValue || null,
      selectedEnd: this.selectedEndValue || null
    }
  }

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

  clear() {
    this.selectedValue = ""
    this.selectedEndValue = ""
    this.updateDayStates()
    this.updateInputs()
    this.dispatchChange()
  }
}
