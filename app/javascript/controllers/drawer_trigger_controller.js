import { Controller } from "@hotwired/stimulus";

/**
 * Drawer Trigger Controller
 *
 * Triggers drawer toggle via Stimulus outlets.
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

  triggerClick() {
    if (this.hasDrawerOutlet) {
      this.drawerOutlets.forEach(outlet => {
        outlet.toggle()
      })
    }
  }
}