import { Controller } from "@hotwired/stimulus"

/**
 * Sidebar Trigger Controller
 * 
 * Triggers sidebar toggle via Stimulus outlets.
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
}
