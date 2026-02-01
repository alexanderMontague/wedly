import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["flap", "seal", "card", "bottom", "instruction", "form", "container"]

  connect() {
    this.isOpen = false
  }

  open(event) {
    if (this.isOpen) return

    this.isOpen = true

    this.flapTarget.classList.add('open')
    this.sealTarget.classList.add('hidden')

    setTimeout(() => {
      this.bottomTarget.style.opacity = '0'
    }, 300)

    setTimeout(() => {
      this.cardTarget.classList.add('visible')
    }, 400)

    this.instructionTarget.style.opacity = '0'
  }

  showForm(event) {
    event.stopPropagation()

    this.containerTarget.style.transition = 'opacity 0.4s ease, transform 0.4s ease'
    this.containerTarget.style.opacity = '0'
    this.containerTarget.style.transform = 'translateY(-20px)'

    setTimeout(() => {
      this.containerTarget.classList.add('hidden')
      this.formTarget.classList.remove('hidden')
      this.formTarget.scrollIntoView({ behavior: 'smooth', block: 'start' })
    }, 400)
  }
}
