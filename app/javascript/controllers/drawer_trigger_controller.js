import { Controller } from "@hotwired/stimulus";

/**
 * Drawer Trigger Controller
 *
 * Triggers drawer toggle via Stimulus outlets and mirrors the drawer's
 * state on the trigger (aria-expanded, aria-controls).
 * Can be placed anywhere on the page - finds drawer via outlet selector.
 *
 * The outlet selector decides which drawer(s) a trigger controls. The default
 * document-wide marker targets every drawer on the page; scope it to one
 * provider's id when a page has more than one drawer (the drawer/trigger
 * partial does this via its for_id: local).
 *
 * @example
 * <button
 *   data-controller="drawer-trigger"
 *   data-action="click->drawer-trigger#triggerClick"
 *   data-drawer-trigger-drawer-outlet="#drawer-provider-filters"
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
    this.syncControls()
  }

  drawerOutletDisconnected() {
    this.syncControls()
  }

  // aria-controls takes a space-separated id list, so a trigger wired to more
  // than one drawer stays accurate instead of pointing at whichever outlet
  // connected last.
  syncControls() {
    const ids = this.drawerOutlets
      .filter(outlet => outlet.hasPanelTarget && outlet.panelTarget.id)
      .map(outlet => outlet.panelTarget.id)

    if (ids.length) {
      this.element.setAttribute("aria-controls", ids.join(" "))
    } else {
      this.element.removeAttribute("aria-controls")
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
