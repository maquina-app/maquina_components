import { Controller } from "@hotwired/stimulus"

/**
 * Sidebar Trigger Controller
 *
 * Triggers sidebar toggle via Stimulus outlets and mirrors the sidebar's
 * state on the trigger (aria-expanded, aria-controls).
 * Can be placed anywhere on the page - finds sidebar via outlet selector.
 *
 * @example
 * <button
 *   data-controller="sidebar-trigger"
 *   data-action="click->sidebar-trigger#triggerClick"
 *   data-sidebar-trigger-sidebar-outlet="[data-outlet='sidebar']"
 * >
 *   Toggle
 * </button>
 */
export default class extends Controller {
  static outlets = ["sidebar"]

  connect() {
    this.handleStateChanged = this.handleStateChanged.bind(this)
    window.addEventListener("sidebar:stateChanged", this.handleStateChanged)
  }

  disconnect() {
    window.removeEventListener("sidebar:stateChanged", this.handleStateChanged)
  }

  sidebarOutletConnected(outlet) {
    this.syncExpanded(outlet.openValue)

    if (outlet.hasSidebarTarget && outlet.sidebarTarget.id) {
      this.element.setAttribute("aria-controls", outlet.sidebarTarget.id)
    }
  }

  /**
   * Toggle sidebar when trigger is clicked
   * Works with multiple sidebars if multiple outlets are connected
   */
  triggerClick() {
    if (this.hasSidebarOutlet) {
      this.sidebarOutlets.forEach(outlet => {
        outlet.toggle()
      })
    }
  }

  handleStateChanged(event) {
    if (!this.hasSidebarOutlet) return
    if (!this.sidebarOutletElements.includes(event.target)) return

    this.syncExpanded(event.detail.open)
  }

  syncExpanded(open) {
    this.element.setAttribute("aria-expanded", open ? "true" : "false")
  }
}
