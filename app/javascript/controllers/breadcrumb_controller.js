import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["item", "ellipsis", "ellipsisSeparator"]

  // Shared with breadcrumbs.css. While it is on the list, the last item is
  // pinned to its natural width; see _fits() for why that is the whole trick.
  // test/stylesheets/css_conventions_test.rb asserts the two agree.
  static MEASURING_CLASS = "breadcrumb-measuring"

  // Sub-pixel slack. scrollWidth and clientWidth are integer-rounded, so
  // content of 500.4px in a 500px box reports 501 > 500 and would collapse a
  // bar that visually fits.
  static FIT_TOLERANCE = 1

  // True when CSS anchor positioning (breadcrumbs.css) places the popover
  static supportsAnchorPositioning =
    typeof CSS !== "undefined" &&
    CSS.supports("anchor-name: --a") &&
    CSS.supports("position-area: block-end")

  connect() {
    this._dropdown = null
    this._fitting = false
    this._frame = null
    this._popoverToggleHandler = this._handlePopoverToggle.bind(this)
    this._teardownHandler = this._teardown.bind(this)
    this._morphHandler = this.fit.bind(this)

    document.addEventListener("turbo:before-cache", this._teardownHandler)
    // Morphing does not replace the element, so connect() never re-runs and the
    // bar would keep whatever collapsed state it had for different content.
    document.addEventListener("turbo:morph", this._morphHandler)

    // A ResizeObserver on the list, not a window resize listener. The container
    // changes width without the window doing anything -- most obviously when
    // this engine's own sidebar collapses -- and a window listener never sees it.
    const list = this._list()
    if (list && typeof ResizeObserver !== "undefined") {
      this._observer = new ResizeObserver(() => this._scheduleFit())
      this._observer.observe(list)
    }

    // Fallback metrics are wider than the real face often enough to matter, and
    // nothing else would re-measure once the swap lands.
    if (document.fonts && document.fonts.ready) {
      document.fonts.ready.then(() => this.fit())
    }

    this.fit()
  }

  disconnect() {
    if (this._observer) {
      this._observer.disconnect()
      this._observer = null
    }
    if (this._frame) cancelAnimationFrame(this._frame)
    this._teardown()
    document.removeEventListener("turbo:before-cache", this._teardownHandler)
    document.removeEventListener("turbo:morph", this._morphHandler)
  }

  // fit() writes classes, which resizes the list, which re-notifies the
  // observer. Coalescing into one frame and guarding re-entry keeps that from
  // becoming a "ResizeObserver loop completed with undelivered notifications".
  _scheduleFit() {
    if (this._fitting) return
    if (this._frame) cancelAnimationFrame(this._frame)
    this._frame = requestAnimationFrame(() => {
      this._frame = null
      this.fit()
    })
  }

  ellipsisTargetConnected(element) {
    const trigger = element.querySelector('[data-breadcrumb-part="ellipsis"]')
    if (trigger) {
      this._ellipsisTrigger = trigger
      this._toggleHandler = this._toggleDropdown.bind(this)
      trigger.addEventListener('click', this._toggleHandler)
    }
  }

  ellipsisTargetDisconnected(_element) {
    if (this._ellipsisTrigger && this._toggleHandler) {
      this._ellipsisTrigger.removeEventListener('click', this._toggleHandler)
      this._ellipsisTrigger = null
      this._toggleHandler = null
    }
  }

  // Collapse only when the bar genuinely does not fit, and re-expand when it
  // does. Both halves are the same pass: every run starts fully expanded and
  // re-derives the answer, so nothing is one-way.
  fit() {
    const list = this._list()
    if (!list) return

    const items = this.itemTargets
    const ellipsis = this.hasEllipsisTarget ? this.ellipsisTarget : null
    const ellipsisSeparator = this.hasEllipsisSeparatorTarget ? this.ellipsisSeparatorTarget : null

    if (items.length < 1 || !ellipsis) return

    // A zero-width container means "not laid out yet" -- inside a collapsing
    // sidebar, a Turbo Frame mid-swap, an unshown tab panel. Measuring there
    // reads as infinite overflow and hides every middle item, permanently,
    // because nothing used to schedule a re-measure. The observer will call us
    // back once it has a width.
    if (list.clientWidth === 0) return

    this._fitting = true

    try {
      // Reset to fully expanded before deciding anything.
      ellipsis.classList.add('hidden')
      if (ellipsisSeparator) ellipsisSeparator.classList.add('hidden')
      items.forEach(item => {
        item.classList.remove('hidden')
        const sep = this._adjacentSeparator(item)
        if (sep) sep.classList.remove('hidden')
      })

      list.classList.add(this.constructor.MEASURING_CLASS)

      if (this._fits(list)) return

      ellipsis.classList.remove('hidden')
      if (ellipsisSeparator) ellipsisSeparator.classList.remove('hidden')

      // Hide from the FRONT. The ellipsis is rendered immediately after the
      // first item, so it can only honestly stand for the items that follow it.
      // Hiding from the back put the "..." in front of items it did not
      // represent and listed the tail in its dropdown.
      for (let i = 0; i < items.length; i++) {
        items[i].classList.add('hidden')
        const sep = this._adjacentSeparator(items[i])
        if (sep) sep.classList.add('hidden')
        if (this._fits(list)) break
      }
    } finally {
      list.classList.remove(this.constructor.MEASURING_CLASS)
      this._fitting = false
      this._updateDropdown()
    }
  }

  // Only meaningful inside measuring mode. Outside it the last item is
  // flex-shrinkable, so the flex algorithm absorbs the whole deficit into the
  // current-page label rather than overflowing the line, and scrollWidth equals
  // clientWidth at every width -- which is why the old check never fired.
  _fits(list) {
    return list.scrollWidth <= list.clientWidth + this.constructor.FIT_TOLERANCE
  }

  _list() {
    return this.element.querySelector('[data-breadcrumb-part="list"]')
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

    if (this._dropdown && this._dropdown.matches(":popover-open")) {
      this._closeDropdown()
    } else {
      this._openDropdown()
    }
  }

  _openDropdown() {
    if (!this._hiddenLinks || this._hiddenLinks.length === 0) return

    if (!this._dropdown) {
      // popover="auto" gives top-layer rendering, light dismiss, and
      // Escape-to-close natively — no document listeners needed
      this._dropdown = document.createElement('div')
      this._dropdown.setAttribute('role', 'menu')
      this._dropdown.setAttribute('popover', 'auto')
      this._dropdown.dataset.dropdownMenuPart = 'content'
      this._dropdown.dataset.breadcrumbPart = 'dropdown'
      this._dropdown.addEventListener('beforetoggle', this._popoverToggleHandler)
      // Next to the trigger so CSS anchor positioning can resolve it
      this._ellipsisTrigger.insertAdjacentElement('afterend', this._dropdown)
    }

    this._buildDropdownContent()
    this._positionDropdown()
    this._dropdown.showPopover()
  }

  _closeDropdown() {
    if (this._dropdown && this._dropdown.matches(":popover-open")) {
      this._dropdown.hidePopover()
    }
  }

  // Mirrors the native popover state onto the data attributes the CSS
  // animations and the trigger styling key on
  _handlePopoverToggle(event) {
    const open = event.newState === 'open'

    this._dropdown.dataset.state = open ? 'open' : 'closed'

    if (this._ellipsisTrigger) {
      if (open) {
        this._ellipsisTrigger.dataset.state = 'open'
      } else {
        delete this._ellipsisTrigger.dataset.state
      }
    }
  }

  _removeDropdown() {
    this._closeDropdown()
    if (this._dropdown) {
      this._dropdown.removeEventListener('beforetoggle', this._popoverToggleHandler)
      this._dropdown.remove()
      this._dropdown = null
    }
    if (this._ellipsisTrigger) {
      delete this._ellipsisTrigger.dataset.state
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
    // Modern browsers position the popover declaratively via anchor CSS
    if (this.constructor.supportsAnchorPositioning) return
    if (!this._dropdown || !this._ellipsisTrigger) return

    const rect = this._ellipsisTrigger.getBoundingClientRect()
    this._dropdown.style.position = 'fixed'
    this._dropdown.style.top = `${rect.bottom + 4}px`
    this._dropdown.style.left = `${rect.left}px`
  }

  _teardown() {
    this._removeDropdown()
    this._hiddenLinks = null
  }
}
