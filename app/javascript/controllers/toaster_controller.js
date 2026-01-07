import { Controller } from "@hotwired/stimulus"

/**
 * Toaster Controller
 *
 * Manages the toast container and provides a global JavaScript API
 * for creating toasts programmatically.
 *
 * Usage:
 *   Toast.success("Message saved!")
 *   Toast.error("Something went wrong", { description: "Please try again" })
 *   Toast.info("New update available", { duration: 10000 })
 *   Toast.warning("Session expiring soon")
 *   Toast.show("Custom message", { variant: "default" })
 *   Toast.dismiss(toastId)
 *   Toast.dismissAll()
 */
export default class extends Controller {
  static targets = ["container"]

  static values = {
    maxVisible: { type: Number, default: 5 }
  }

  connect() {
    // Expose global Toast API
    this.setupGlobalApi()
  }

  disconnect() {
    // Clean up global API
    if (window.Toast && window.Toast._controller === this) {
      delete window.Toast
    }
  }

  setupGlobalApi() {
    const controller = this

    window.Toast = {
      _controller: controller,

      show(title, options = {}) {
        return controller.createToast({ title, ...options })
      },

      success(title, options = {}) {
        return controller.createToast({ title, variant: "success", ...options })
      },

      info(title, options = {}) {
        return controller.createToast({ title, variant: "info", ...options })
      },

      warning(title, options = {}) {
        return controller.createToast({ title, variant: "warning", ...options })
      },

      error(title, options = {}) {
        return controller.createToast({ title, variant: "error", ...options })
      },

      dismiss(toastId) {
        controller.dismissToast(toastId)
      },

      dismissAll() {
        controller.dismissAllToasts()
      }
    }
  }

  /**
   * Create a toast programmatically
   *
   * @param {Object} options
   * @param {string} options.title - Toast title
   * @param {string} options.description - Optional description
   * @param {string} options.variant - default, success, info, warning, error
   * @param {number} options.duration - Auto-dismiss in ms (0 = no auto-dismiss)
   * @param {boolean} options.dismissible - Show close button
   * @param {Object} options.action - { label: string, onClick: function }
   * @returns {string} Toast ID
   */
  createToast(options = {}) {
    const {
      title = "",
      description = "",
      variant = "default",
      duration = 5000,
      dismissible = true,
      action = null
    } = options

    const toastId = `toast-${Date.now()}-${Math.random().toString(36).substr(2, 9)}`

    // Build toast HTML
    const toastHtml = this.buildToastHtml({
      id: toastId,
      title,
      description,
      variant,
      duration,
      dismissible,
      action
    })

    // Insert into container
    this.element.insertAdjacentHTML("beforeend", toastHtml)

    // Enforce max visible
    this.enforceMaxVisible()

    return toastId
  }

  buildToastHtml({ id, title, description, variant, duration, dismissible, action }) {
    const icons = {
      default: "",
      success: this.getIconSvg("circle_check"),
      info: this.getIconSvg("info"),
      warning: this.getIconSvg("triangle_alert"),
      error: this.getIconSvg("circle_x")
    }

    const iconHtml = icons[variant]
      ? `<div data-toast-part="icon">${icons[variant]}</div>`
      : ""

    const titleHtml = title
      ? `<div data-toast-part="title">${this.escapeHtml(title)}</div>`
      : ""

    const descriptionHtml = description
      ? `<div data-toast-part="description">${this.escapeHtml(description)}</div>`
      : ""

    const actionHtml = action
      ? `<button type="button" data-toast-part="action" data-action="click->toast#handleAction">${this.escapeHtml(action.label)}</button>`
      : ""

    const closeHtml = dismissible
      ? `<button type="button" data-toast-part="close" data-action="toast#dismiss" aria-label="Dismiss notification">${this.getIconSvg("x")}</button>`
      : ""

    return `
      <div id="${id}"
           role="alert"
           data-component="toast"
           data-controller="toast"
           data-variant="${variant}"
           data-toast-duration-value="${duration}"
           data-toast-dismissible-value="${dismissible}"
           data-toast-action-callback="${action ? "true" : "false"}"
           data-state="entering">
        ${iconHtml}
        <div data-toast-part="content">
          ${titleHtml}
          ${descriptionHtml}
          ${actionHtml}
        </div>
        ${closeHtml}
      </div>
    `.trim()
  }

  getIconSvg(name) {
    const icons = {
      circle_check: '<svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><path d="m9 12 2 2 4-4"/></svg>',
      info: '<svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><path d="M12 16v-4"/><path d="M12 8h.01"/></svg>',
      triangle_alert: '<svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="m21.73 18-8-14a2 2 0 0 0-3.48 0l-8 14A2 2 0 0 0 4 21h16a2 2 0 0 0 1.73-3"/><path d="M12 9v4"/><path d="M12 17h.01"/></svg>',
      circle_x: '<svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><path d="m15 9-6 6"/><path d="m9 9 6 6"/></svg>',
      x: '<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M18 6 6 18"/><path d="m6 6 12 12"/></svg>'
    }
    return icons[name] || ""
  }

  escapeHtml(text) {
    const div = document.createElement("div")
    div.textContent = text
    return div.innerHTML
  }

  dismissToast(toastId) {
    const toast = document.getElementById(toastId)
    if (toast) {
      // Trigger the toast controller's dismiss method
      const toastController = this.application.getControllerForElementAndIdentifier(toast, "toast")
      if (toastController) {
        toastController.dismiss()
      } else {
        toast.remove()
      }
    }
  }

  dismissAllToasts() {
    const toasts = this.element.querySelectorAll('[data-component="toast"]')
    toasts.forEach(toast => {
      const toastController = this.application.getControllerForElementAndIdentifier(toast, "toast")
      if (toastController) {
        toastController.dismiss()
      } else {
        toast.remove()
      }
    })
  }

  enforceMaxVisible() {
    const toasts = this.element.querySelectorAll('[data-component="toast"]')
    const excess = toasts.length - this.maxVisibleValue

    if (excess > 0) {
      // Remove oldest toasts (first in DOM)
      for (let i = 0; i < excess; i++) {
        const toast = toasts[i]
        const toastController = this.application.getControllerForElementAndIdentifier(toast, "toast")
        if (toastController) {
          toastController.dismiss()
        } else {
          toast.remove()
        }
      }
    }
  }
}
