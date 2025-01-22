import { Controller } from "@hotwired/stimulus"

// Theme Color controller for switching color themes (neutral, green, rose, blue).
//
// Works alongside the theme controller (light/dark mode).
// Applies data-theme attribute to <html> element.
// Persists preference in cookie.
//
// Cookie: "color_theme" with values "neutral", "green", "rose", "blue"
//
export default class extends Controller {
  static targets = ["item"]
  static values = {
    current: { type: String, default: "neutral" }
  }

  connect() {
    // Read preference from cookie
    const saved = this.getCookie("color_theme")
    this.currentValue = saved || "neutral"

    // Apply theme immediately
    this.applyTheme()

    // Update toggle group state
    this.updateToggleState()
  }

  // Called when toggle group emits change event
  change(event) {
    const newTheme = event.detail?.value
    if (newTheme && newTheme !== this.currentValue) {
      this.currentValue = newTheme
      this.saveCookie()
      this.applyTheme()
    }
  }

  // Called when clicking an item directly
  select(event) {
    const newTheme = event.currentTarget.dataset.themeColorValue
    if (newTheme && newTheme !== this.currentValue) {
      this.currentValue = newTheme
      this.saveCookie()
      this.applyTheme()
      this.updateToggleState()
    }
  }

  applyTheme() {
    const html = document.documentElement

    // Remove all theme attributes first
    if (this.currentValue === "neutral") {
      html.removeAttribute("data-theme")
    } else {
      html.setAttribute("data-theme", this.currentValue)
    }
  }

  updateToggleState() {
    // Update aria-pressed on toggle items
    this.itemTargets.forEach(item => {
      const isSelected = item.dataset.themeColorValue === this.currentValue
      item.setAttribute("aria-pressed", isSelected.toString())
      item.setAttribute("data-state", isSelected ? "on" : "off")
    })
  }

  saveCookie() {
    if (this.currentValue === "neutral") {
      // Remove cookie to use default
      document.cookie = "color_theme=; path=/; max-age=0"
    } else {
      // Set cookie for 1 year
      document.cookie = `color_theme=${this.currentValue}; path=/; max-age=31536000`
    }
  }

  getCookie(name) {
    const match = document.cookie.match(new RegExp("(^| )" + name + "=([^;]+)"))
    return match ? match[2] : null
  }
}
