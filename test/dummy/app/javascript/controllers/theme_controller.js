import { Controller } from "@hotwired/stimulus"

// Theme controller for light/dark mode toggle with system preference fallback.
//
// Reads preference from cookie, falls back to system preference.
// Cycles through: light -> dark -> system -> light
//
// Cookie: "theme_preference" with values "light", "dark", or absent (system)
//
export default class extends Controller {
  static targets = ["icon"]
  static values = {
    preference: { type: String, default: "" }
  }

  connect() {
    // Read preference from cookie
    this.preferenceValue = this.getCookie("theme_preference") || ""

    // Listen for system preference changes
    this.mediaQuery = window.matchMedia("(prefers-color-scheme: dark)")
    this.boundHandleSystemChange = this.handleSystemChange.bind(this)
    this.mediaQuery.addEventListener("change", this.boundHandleSystemChange)

    // Apply initial theme
    this.applyTheme()
  }

  disconnect() {
    if (this.mediaQuery) {
      this.mediaQuery.removeEventListener("change", this.boundHandleSystemChange)
    }
  }

  toggle() {
    // Cycle: light -> dark -> system -> light
    switch (this.preferenceValue) {
      case "light":
        this.preferenceValue = "dark"
        break
      case "dark":
        this.preferenceValue = ""  // system
        break
      default:  // system or empty
        this.preferenceValue = "light"
    }

    this.saveCookie()
    this.applyTheme()
  }

  handleSystemChange() {
    // Only react to system changes when in system mode
    if (this.preferenceValue === "") {
      this.applyTheme()
    }
  }

  applyTheme() {
    const isDark = this.shouldBeDark()
    document.documentElement.classList.toggle("dark", isDark)
    this.updateIcon()
  }

  shouldBeDark() {
    if (this.preferenceValue === "dark") return true
    if (this.preferenceValue === "light") return false
    // System preference
    return this.mediaQuery.matches
  }

  updateIcon() {
    if (!this.hasIconTarget) return

    // Determine which icon to show based on preference
    let iconName
    switch (this.preferenceValue) {
      case "light":
        iconName = "sun"
        break
      case "dark":
        iconName = "moon"
        break
      default:
        iconName = "monitor"
    }

    // Update icon visibility
    this.iconTargets.forEach(icon => {
      const isActive = icon.dataset.themeIcon === iconName
      icon.classList.toggle("hidden", !isActive)
    })
  }

  saveCookie() {
    if (this.preferenceValue === "") {
      // Remove cookie to fall back to system
      document.cookie = "theme_preference=; path=/; max-age=0"
    } else {
      // Set cookie for 1 year
      document.cookie = `theme_preference=${this.preferenceValue}; path=/; max-age=31536000`
    }
  }

  getCookie(name) {
    const match = document.cookie.match(new RegExp("(^| )" + name + "=([^;]+)"))
    return match ? match[2] : null
  }
}
