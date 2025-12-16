import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["item", "ellipsis", "ellipsisSeparator"]

  connect() {
    this.windowResizeHandler = this.handleResize.bind(this)
    window.addEventListener('resize', this.windowResizeHandler)
    this.handleResize()
  }

  disconnect() {
    window.removeEventListener('resize', this.windowResizeHandler)
  }

  handleResize() {
    // Get visible width of container
    const containerWidth = this.element.clientWidth
    const items = this.itemTargets
    const ellipsis = this.hasEllipsisTarget ? this.ellipsisTarget : null
    const ellipsisSeparator = this.hasEllipsisSeparatorTarget ? this.ellipsisSeparatorTarget : null

    // Always show first and last items
    if (items.length < 3 || !ellipsis) {
      return; // Not enough items to collapse or no ellipsis element
    }

    // Reset visibility
    if (ellipsis) ellipsis.classList.add('hidden')
    if (ellipsisSeparator) ellipsisSeparator.classList.add('hidden')

    items.forEach(item => {
      item.classList.remove('hidden')
    })

    // Check if we need to collapse items
    let totalWidth = 0
    items.forEach(item => {
      totalWidth += item.offsetWidth
    })

    if (totalWidth > containerWidth) {
      // We need to collapse items - show ellipsis
      if (ellipsis) ellipsis.classList.remove('hidden')
      if (ellipsisSeparator) ellipsisSeparator.classList.remove('hidden')

      // Start hiding middle items until we fit
      for (let i = items.length - 2; i > 0; i--) {
        if (i !== 0 && i !== items.length - 1) {
          items[i].classList.add('hidden')

          // Recalculate total width
          totalWidth = 0

          if (ellipsis) totalWidth += ellipsis.offsetWidth
          if (ellipsisSeparator) totalWidth += ellipsisSeparator.offsetWidth

          items.forEach(item => {
            if (!item.classList.contains('hidden')) {
              totalWidth += item.offsetWidth
            }
          })

          if (totalWidth <= containerWidth) {
            break
          }
        }
      }
    }
  }
}
