import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    targetTime: String,
  }

  static targets = ["days", "hours", "minutes", "seconds"]

  connect() {
    this.update()
    this.timer = window.setInterval(() => this.update(), 1000)
  }

  disconnect() {
    if (this.timer) window.clearInterval(this.timer)
  }

  update() {
    const target = new Date(this.targetTimeValue)
    const diff = target - Date.now()

    if (diff <= 0) {
      this.setValues(0, 0, 0, 0)
      return
    }

    const totalSeconds = Math.floor(diff / 1000)
    const days = Math.floor(totalSeconds / 86400)
    const hours = Math.floor((totalSeconds % 86400) / 3600)
    const minutes = Math.floor((totalSeconds % 3600) / 60)
    const seconds = totalSeconds % 60

    this.setValues(days, hours, minutes, seconds)
  }

  setValues(days, hours, minutes, seconds) {
    this.daysTarget.textContent = String(days)
    this.hoursTarget.textContent = String(hours).padStart(2, "0")
    this.minutesTarget.textContent = String(minutes).padStart(2, "0")
    this.secondsTarget.textContent = String(seconds).padStart(2, "0")
  }
}
