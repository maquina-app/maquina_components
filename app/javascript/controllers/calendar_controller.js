import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["day", "input", "inputEnd", "prevButton", "nextButton", "grid", "caption", "monthSelect", "yearSelect"]

  static values = {
    month: Number,
    year: Number,
    selected: String,
    selectedEnd: String,
    minDate: String,
    maxDate: String,
    mode: { type: String, default: "single" },
    weekStartsOn: { type: String, default: "sunday" },
    disabledDates: Array,
    showOutsideDays: { type: Boolean, default: true },
    // Bounds of the caption's year select (caption_layout: :dropdown only)
    startYear: Number,
    endYear: Number
  }

  connect() {
    this.updateNavigationState()
    this.updateDayStates()

    // Inside a popover (date picker or a caller's own), track which side of
    // the trigger it opened on, so the header can sit next to the trigger
    this.popover = this.element.closest("[popover]")
    if (this.popover) {
      this.boundUpdateSide = this.updateSide.bind(this)
      this.popover.addEventListener("toggle", this.boundUpdateSide)
    }
  }

  disconnect() {
    this.popover?.removeEventListener("toggle", this.boundUpdateSide)
  }

  /**
   * Sets data-side="top|bottom" when the popover is open. A popover flipped
   * above its trigger is pinned at its bottom edge, so CSS moves the header
   * there: month heights differ, and the arrows must not move under the cursor.
   */
  updateSide() {
    if (!this.popover?.matches(":popover-open")) return

    const trigger = this.popover.id &&
      document.querySelector(`[popovertarget="${CSS.escape(this.popover.id)}"]`)
    if (!trigger) return

    const above = this.popover.getBoundingClientRect().top < trigger.getBoundingClientRect().top
    this.element.dataset.side = above ? "top" : "bottom"
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

  // Caption dropdowns (caption_layout: :dropdown)
  selectMonth() {
    this.navigateToMonth(Number(this.monthSelectTarget.value), this.yearValue)
  }

  selectYear() {
    const year = Number(this.yearSelectTarget.value)
    this.navigateToMonth(this.clampMonth(this.monthValue, year), year)
  }

  // A year change keeps the month, unless min/max date rule it out that year
  clampMonth(month, year) {
    const [minYear, minMonth] = (this.minDateValue || "").split("-").map(Number)
    const [maxYear, maxMonth] = (this.maxDateValue || "").split("-").map(Number)

    if (year === minYear && month < minMonth) return minMonth
    if (year === maxYear && month > maxMonth) return maxMonth
    return month
  }

  navigateToMonth(month, year) {
    // The year select lists only startYear..endYear; never show a month it can't
    if ((this.hasStartYearValue && year < this.startYearValue) ||
        (this.hasEndYearValue && year > this.endYearValue)) return

    this.monthValue = month
    this.yearValue = year

    this.rebuildCalendar()
    this.syncDropdowns()
    this.updateNavigationState()
    this.updateSide()

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
      const locale = document.documentElement.lang || undefined
      caption.textContent = firstOfMonth.toLocaleDateString(locale, { month: 'long', year: 'numeric' })
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

    // Rebuild grid HTML
    grid.innerHTML = weeks.map(week => this.buildWeekHTML(week, month)).join('')
  }

  // Mirrors calendar/_week.html.erb. Dates compare as ISO strings, which sort
  // lexicographically and avoid the UTC shift of new Date("YYYY-MM-DD").
  buildWeekHTML(days, displayMonth) {
    const selectedStr = this.selectedValue || ""
    const selectedEndStr = this.selectedEndValue || ""
    const minStr = this.minDateValue || ""
    const maxStr = this.maxDateValue || ""
    const disabledDates = new Set(this.disabledDatesValue)

    const daysHTML = days.map(day => {
      const dateStr = this.formatDate(day)
      const isOutside = day.getMonth() + 1 !== displayMonth

      // A hidden outside day keeps its grid column
      if (isOutside && !this.showOutsideDaysValue) {
        return '<span aria-hidden="true" data-calendar-part="outside-day"></span>'
      }
      const isToday = this.isSameDate(day, new Date())
      const isSelected = selectedStr && dateStr === selectedStr
      const isRangeEnd = selectedEndStr && dateStr === selectedEndStr
      // ISO date strings are lexicographically sortable
      const isRangeMiddle = selectedStr && selectedEndStr && dateStr > selectedStr && dateStr < selectedEndStr
      const isDisabled = (minStr && dateStr < minStr) ||
                         (maxStr && dateStr > maxStr) ||
                         disabledDates.has(dateStr)

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
    // Local midnight: a bare "YYYY-MM-DD" parses as UTC and shifts a day west of it
    const currentDate = new Date(currentButton.dataset.date + "T00:00:00")
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

    if (targetButton) {
      // A disabled day in the visible month is not focusable; stay put
      if (!targetButton.disabled) targetButton.focus()
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
    const firstOfMonth = this.formatDate(new Date(this.yearValue, this.monthValue - 1, 1))
    const lastOfMonth = this.formatDate(new Date(this.yearValue, this.monthValue, 0))

    if (this.hasPrevButtonTarget) {
      this.prevButtonTarget.disabled = Boolean(
        (this.minDateValue && firstOfMonth <= this.minDateValue) ||
        (this.hasStartYearValue && this.monthValue === 1 && this.yearValue <= this.startYearValue)
      )
    }

    if (this.hasNextButtonTarget) {
      this.nextButtonTarget.disabled = Boolean(
        (this.maxDateValue && lastOfMonth >= this.maxDateValue) ||
        (this.hasEndYearValue && this.monthValue === 12 && this.yearValue >= this.endYearValue)
      )
    }
  }

  // Mirrors calendar_month_options: a month wholly outside min/max is disabled
  syncDropdowns() {
    if (this.hasMonthSelectTarget) {
      for (const option of this.monthSelectTarget.options) {
        const month = Number(option.value)
        const first = this.formatDate(new Date(this.yearValue, month - 1, 1))
        const last = this.formatDate(new Date(this.yearValue, month, 0))

        option.disabled = Boolean((this.minDateValue && last < this.minDateValue) ||
          (this.maxDateValue && first > this.maxDateValue))
      }
      this.monthSelectTarget.value = String(this.monthValue)
    }

    if (this.hasYearSelectTarget) {
      this.yearSelectTarget.value = String(this.yearValue)
    }
  }

  dispatchChange() {
    const detail = {
      mode: this.modeValue,
      selected: this.selectedValue || null,
      selectedEnd: this.selectedEndValue || null
    }

    // Stimulus dispatches a bubbling "calendar:change" — once
    this.dispatch("change", { detail })
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
