import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["button", "content"]

  connect() {
    if (!this.hasContentTarget) {
      return
    }

    this.clickOutside = this.clickOutside.bind(this)
    this.isOpen = this.buttonTarget.dataset.state === "open"

    if (this.isOpen) {
      this.addClickOutsideListener()
    }
  }

  disconnect() {
    this.removeClickOutsideListener()
  }

  toggle() {
    if (!this.hasContentTarget) {
      return
    }

    this.contentTarget.classList.remove("hidden")

    this.isOpen = !this.isOpen
    this.buttonTarget.dataset.state = this.isOpen ? "open" : "closed"

    if (this.isOpen) {
      // Add a small delay before adding the click outside listener
      setTimeout(() => {
        this.addClickOutsideListener()
      }, 100)
    } else {
      this.removeClickOutsideListener()
    }
  }

  clickOutside(event) {
    if (!this.isOpen) return
    if (event.target === this.element) return

    if (!this.contentTarget.contains(event.target)) {
      this.toggle()
    }
  }

  addClickOutsideListener() {
    document.addEventListener('click', this.clickOutside)
  }

  removeClickOutsideListener() {
    document.removeEventListener('click', this.clickOutside)
  }
}
