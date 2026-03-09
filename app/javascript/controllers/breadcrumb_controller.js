import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["item", "ellipsis", "ellipsisSeparator"]
  static values = { collapseAfter: { type: Number, default: 0 } }

  connect() {
    this._dropdown = null
    this._clickOutsideHandler = this._closeDropdown.bind(this)
    this._escapeHandler = this._handleEscape.bind(this)
    this._teardownHandler = this._teardown.bind(this)

    document.addEventListener("turbo:before-cache", this._teardownHandler)

    this.windowResizeHandler = this.handleResize.bind(this)
    window.addEventListener('resize', this.windowResizeHandler)
    this.handleResize()
  }

  disconnect() {
    window.removeEventListener('resize', this.windowResizeHandler)
    this._teardown()
    document.removeEventListener("turbo:before-cache", this._teardownHandler)
  }

  ellipsisTargetConnected(element) {
    const trigger = element.querySelector('[data-breadcrumb-part="ellipsis"]')
    if (trigger) {
      this._ellipsisTrigger = trigger
      this._toggleHandler = this._toggleDropdown.bind(this)
      trigger.addEventListener('click', this._toggleHandler)
      trigger.style.cursor = 'pointer'
    }
  }

  ellipsisTargetDisconnected(_element) {
    if (this._ellipsisTrigger && this._toggleHandler) {
      this._ellipsisTrigger.removeEventListener('click', this._toggleHandler)
      this._ellipsisTrigger = null
      this._toggleHandler = null
    }
  }

  handleResize() {
    const list = this.element.querySelector('[data-breadcrumb-part="list"]')
    if (!list) return

    const items = this.itemTargets
    const ellipsis = this.hasEllipsisTarget ? this.ellipsisTarget : null
    const ellipsisSeparator = this.hasEllipsisSeparatorTarget ? this.ellipsisSeparatorTarget : null

    if (items.length < 1 || !ellipsis) return

    // Reset all items and their adjacent separators to visible
    ellipsis.classList.add('hidden')
    if (ellipsisSeparator) ellipsisSeparator.classList.add('hidden')
    items.forEach(item => {
      item.classList.remove('hidden')
      const sep = this._adjacentSeparator(item)
      if (sep) sep.classList.remove('hidden')
    })

    // Count-based collapsing: force-collapse when total items exceed threshold
    // items are middle targets only; total visible = middle targets + first + last (2)
    const totalItems = items.length + 2
    if (this.collapseAfterValue > 0 && totalItems > this.collapseAfterValue) {
      ellipsis.classList.remove('hidden')
      if (ellipsisSeparator) ellipsisSeparator.classList.remove('hidden')

      // collapseAfterValue includes first + last, so middle budget = collapseAfterValue - 2
      const maxMiddleVisible = Math.max(this.collapseAfterValue - 2, 0)
      let visibleMiddle = items.length

      for (let i = items.length - 1; i >= 0 && visibleMiddle > maxMiddleVisible; i--) {
        items[i].classList.add('hidden')
        const sep = this._adjacentSeparator(items[i])
        if (sep) sep.classList.add('hidden')
        visibleMiddle--
      }
    }

    // Check overflow using scrollWidth vs clientWidth
    if (list.scrollWidth > list.clientWidth) {
      ellipsis.classList.remove('hidden')
      if (ellipsisSeparator) ellipsisSeparator.classList.remove('hidden')

      // Hide middle items one at a time until it fits
      const visibleItems = items.filter(item => !item.classList.contains('hidden'))
      for (let i = visibleItems.length - 1; i >= 0; i--) {
        visibleItems[i].classList.add('hidden')
        const sep = this._adjacentSeparator(visibleItems[i])
        if (sep) sep.classList.add('hidden')
        if (list.scrollWidth <= list.clientWidth) break
      }
    }

    this._updateDropdown()
  }

  // Find the next sibling separator <li> (not the managed ellipsisSeparator)
  _adjacentSeparator(item) {
    const next = item.nextElementSibling
    if (next && next.dataset.breadcrumbPart === "separator" && !next.dataset.breadcrumbTarget) {
      return next
    }
    return null
  }

  // Collect hidden items and update dropdown content
  _updateDropdown() {
    const hiddenItems = this.itemTargets.filter(item => item.classList.contains('hidden'))

    if (hiddenItems.length === 0) {
      this._removeDropdown()
      return
    }

    // Build list of links from hidden items
    this._hiddenLinks = hiddenItems.map(item => {
      const link = item.querySelector('[data-breadcrumb-part="link"]')
      if (link) {
        return { href: link.getAttribute('href'), text: link.textContent.trim() }
      }
      return null
    }).filter(Boolean)

    // If dropdown is currently open, rebuild its content
    if (this._dropdown && this._dropdown.dataset.state === "open") {
      this._buildDropdownContent()
    }
  }

  _toggleDropdown(event) {
    event.stopPropagation()

    if (this._dropdown && this._dropdown.dataset.state === "open") {
      this._closeDropdown()
    } else {
      this._openDropdown()
    }
  }

  _openDropdown() {
    if (!this._hiddenLinks || this._hiddenLinks.length === 0) return

    if (!this._dropdown) {
      this._dropdown = document.createElement('div')
      this._dropdown.setAttribute('role', 'menu')
      this._dropdown.dataset.dropdownMenuPart = 'content'
      this._dropdown.style.position = 'fixed'
      this._dropdown.style.zIndex = '50'
      document.body.appendChild(this._dropdown)
    }

    this._buildDropdownContent()
    this._positionDropdown()
    this._dropdown.dataset.state = 'open'

    if (this._ellipsisTrigger) {
      this._ellipsisTrigger.dataset.state = 'open'
    }

    // Defer listeners so the current click doesn't immediately close
    requestAnimationFrame(() => {
      document.addEventListener('click', this._clickOutsideHandler)
      document.addEventListener('keydown', this._escapeHandler)
    })
  }

  _closeDropdown() {
    if (this._dropdown) {
      this._dropdown.dataset.state = 'closed'
    }
    if (this._ellipsisTrigger) {
      delete this._ellipsisTrigger.dataset.state
    }

    document.removeEventListener('click', this._clickOutsideHandler)
    document.removeEventListener('keydown', this._escapeHandler)
  }

  _removeDropdown() {
    this._closeDropdown()
    if (this._dropdown) {
      this._dropdown.remove()
      this._dropdown = null
    }
  }

  _buildDropdownContent() {
    if (!this._dropdown || !this._hiddenLinks) return

    this._dropdown.innerHTML = ''
    this._hiddenLinks.forEach(({ href, text }) => {
      const link = document.createElement('a')
      link.setAttribute('href', href)
      link.setAttribute('role', 'menuitem')
      link.dataset.dropdownMenuPart = 'item'
      link.setAttribute('tabindex', '-1')
      link.textContent = text
      this._dropdown.appendChild(link)
    })
  }

  _positionDropdown() {
    if (!this._dropdown || !this._ellipsisTrigger) return

    const rect = this._ellipsisTrigger.getBoundingClientRect()
    this._dropdown.style.top = `${rect.bottom + 4}px`
    this._dropdown.style.left = `${rect.left}px`
  }

  _handleEscape(event) {
    if (event.key === 'Escape') {
      this._closeDropdown()
    }
  }

  _teardown() {
    this._removeDropdown()
    this._hiddenLinks = null
  }
}
