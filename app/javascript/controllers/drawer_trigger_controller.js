import { Controller } from "@hotwired/stimulus";

/**
 * Drawer Trigger Controller
 *
 * Triggers drawer toggle via Stimulus outlets and mirrors the drawer's
 * state on the trigger (aria-expanded, aria-controls).
 * Can be placed anywhere on the page - finds drawer via outlet selector.
 *
 * @example
 * <button
 *   data-controller="drawer-trigger"
 *   data-action="click->drawer-trigger#triggerClick"
 *   data-drawer-trigger-drawer-outlet="[data-outlet='drawer']"
 * >
 *   Toggle
 * </button>
 */
export default class extends Controller {
  static outlets = ["drawer"]

  connect() {
    this.handleStateChanged = this.handleStateChanged.bind(this)
    window.addEventListener("drawer:stateChanged", this.handleStateChanged)
  }

  disconnect() {
    window.removeEventListener("drawer:stateChanged", this.handleStateChanged)
  }

  drawerOutletConnected(outlet) {
    this.element.setAttribute("aria-haspopup", "dialog")
    this.syncExpanded(outlet.openValue)

    if (outlet.hasPanelTarget && outlet.panelTarget.id) {
      this.element.setAttribute("aria-controls", outlet.panelTarget.id)
    }
  }

  triggerClick() {
    if (this.hasDrawerOutlet) {
      this.drawerOutlets.forEach(outlet => {
        outlet.toggle()
      })
    }
  }

  handleStateChanged(event) {
    if (!this.hasDrawerOutlet) return
    if (!this.drawerOutletElements.includes(event.target)) return

    this.syncExpanded(event.detail.open)
  }

  syncExpanded(open) {
    this.element.setAttribute("aria-expanded", open ? "true" : "false")
  }
}
