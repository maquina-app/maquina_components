import { Controller } from "@hotwired/stimulus"

/**
 * Toast Controller
 *
 * Manages individual toast lifecycle:
 * - Auto-dismiss timer
 * - Pause on hover
 * - Dismiss animation
 * - Action button callback
 */
export default class extends Controller {
  static values = {
    duration: { type: Number, default: 5000 },
    dismissible: { type: Boolean, default: true },
    actionCallback: { type: Boolean, default: false }
  }

  connect() {
    this.timeoutId = null
    this.remainingTime = this.durationValue
    this.startTime = null

    // Bind event handlers
    this.handleMouseEnter = this.handleMouseEnter.bind(this)
    this.handleMouseLeave = this.handleMouseLeave.bind(this)

    // Add hover listeners
    this.element.addEventListener("mouseenter", this.handleMouseEnter)
    this.element.addEventListener("mouseleave", this.handleMouseLeave)

    // Start animation, then start timer
    requestAnimationFrame(() => {
      // Wait for enter animation to complete
      setTimeout(() => {
        this.element.dataset.state = "visible"
        this.startTimer()
      }, 200) // Match CSS animation duration
    })
  }

  disconnect() {
    this.clearTimer()
    this.element.removeEventListener("mouseenter", this.handleMouseEnter)
    this.element.removeEventListener("mouseleave", this.handleMouseLeave)
  }

  startTimer() {
    if (this.durationValue <= 0) return // No auto-dismiss

    this.startTime = Date.now()
    this.timeoutId = setTimeout(() => {
      this.dismiss()
    }, this.remainingTime)
  }

  clearTimer() {
    if (this.timeoutId) {
      clearTimeout(this.timeoutId)
      this.timeoutId = null
    }
  }

  pauseTimer() {
    if (this.durationValue <= 0) return

    this.clearTimer()

    // Calculate remaining time
    if (this.startTime) {
      const elapsed = Date.now() - this.startTime
      this.remainingTime = Math.max(0, this.remainingTime - elapsed)
    }
  }

  resumeTimer() {
    if (this.durationValue <= 0) return
    if (this.remainingTime <= 0) return

    this.startTimer()
  }

  handleMouseEnter() {
    this.pauseTimer()
  }

  handleMouseLeave() {
    this.resumeTimer()
  }

  dismiss() {
    this.clearTimer()

    // Start exit animation
    this.element.dataset.state = "exiting"

    // Remove after animation completes
    setTimeout(() => {
      this.element.remove()
    }, 150) // Match CSS animation duration
  }

  handleAction(event) {
    // If this toast was created via JS API with an action callback,
    // the callback is stored on the toaster controller or needs to be
    // dispatched as an event for the parent to handle
    this.dispatch("action", {
      detail: { toastId: this.element.id },
      bubbles: true
    })

    // Dismiss after action
    this.dismiss()
  }
}
