import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["container", "template"]

  add(event) {
    event.preventDefault()
    
    // Replace the 'NEW_RECORD' placeholder with a unique timestamp to prevent ID collisions
    const content = this.templateTarget.innerHTML.replace(/NEW_RECORD/g, new Date().getTime())
    this.containerTarget.insertAdjacentHTML('beforeend', content)
  }

  remove(event) {
    event.preventDefault()
    const wrapper = event.target.closest('.nested-form-wrapper')
    
    if (wrapper.dataset.newRecord === "true") {
      wrapper.remove() // If it's a new row, just delete it from DOM
    } else {
      // If it exists in DB, check the _destroy checkbox and hide the row
      wrapper.querySelector("input[name*='_destroy']").value = "1"
      wrapper.style.display = "none"
    }
  }
}