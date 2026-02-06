import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["guestsContainer", "guestFields"]

  connect() {
    this.guestIndex = this.guestFieldsTargets.length
  }

  addGuest(event) {
    event.preventDefault()
    const template = this.createGuestTemplate()
    this.guestsContainerTarget.insertAdjacentHTML("beforeend", template)
    this.guestIndex++
  }

  removeGuest(event) {
    event.preventDefault()
    const guestFields = event.currentTarget.closest(".guest-fields")
    if (guestFields) {
      guestFields.remove()
    }
  }

  createGuestTemplate() {
    const index = this.guestIndex
    return `
      <div class="guest-fields border border-stone-200 rounded p-4 mb-4" data-household-form-target="guestFields">
        <div class="flex justify-between items-start mb-3">
          <h4 class="text-sm font-semibold text-stone-700">Guest</h4>
          <button type="button" class="text-sm text-red-600 hover:text-red-800" data-action="click->household-form#removeGuest">
            Remove
          </button>
        </div>
        <div class="grid grid-cols-2 gap-4">
          <div class="form-group">
            <label>First Name</label>
            <input type="text" name="household[guests_attributes][${index}][first_name]" class="form-control" required>
          </div>
          <div class="form-group">
            <label>Last Name</label>
            <input type="text" name="household[guests_attributes][${index}][last_name]" class="form-control" required>
          </div>
        </div>
        <div class="grid grid-cols-2 gap-4">
          <div class="form-group">
            <label>Email</label>
            <input type="email" name="household[guests_attributes][${index}][email]" class="form-control">
          </div>
          <div class="form-group">
            <label>Phone</label>
            <input type="text" name="household[guests_attributes][${index}][phone_number]" class="form-control">
          </div>
        </div>
        <div class="form-group">
          <label>Address</label>
          <textarea name="household[guests_attributes][${index}][address]" class="form-control" rows="2"></textarea>
        </div>
      </div>
    `
  }
}
