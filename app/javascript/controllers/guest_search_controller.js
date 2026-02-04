import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "results", "noResults", "searching"]
  static values = { url: String }

  connect() {
    this.timeout = null
  }

  search() {
    const query = this.inputTarget.value.trim()

    if (this.timeout) {
      clearTimeout(this.timeout)
    }

    if (query.length < 2) {
      this.hideResults()
      return
    }

    this.showSearching()

    this.timeout = setTimeout(() => {
      this.performSearch(query)
    }, 300)
  }

  async performSearch(query) {
    try {
      const response = await fetch(`${this.urlValue}?q=${encodeURIComponent(query)}`, {
        headers: {
          "Accept": "application/json"
        }
      })

      if (!response.ok) throw new Error("Search failed")

      const results = await response.json()
      this.displayResults(results)
    } catch (error) {
      console.error("Search error:", error)
      this.hideResults()
    }
  }

  displayResults(results) {
    this.hideSearching()

    if (results.length === 0) {
      this.resultsTarget.classList.add("hidden")
      this.noResultsTarget.classList.remove("hidden")
      return
    }

    this.noResultsTarget.classList.add("hidden")
    this.resultsTarget.innerHTML = results.map(guest => `
      <a href="/rsvp/${guest.invite_code}"
         class="block p-6 border-b transition-colors"
         style="border-color: #e7e5e4; text-decoration: none;"
         onmouseover="this.style.backgroundColor='#fafaf9'"
         onmouseout="this.style.backgroundColor='transparent'">
        <div class="flex justify-between items-center">
          <div>
            <p class="text-xl mb-1" style="font-family: 'Cormorant Garamond', serif; color: #292524;">
              ${this.escapeHtml(guest.name)}
            </p>
            <p class="text-sm" style="color: #78716c; font-weight: 300;">
              ${this.escapeHtml(guest.household)}
            </p>
          </div>
          <svg class="w-5 h-5" style="color: #a8a29e;" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="1.5">
            <path stroke-linecap="round" stroke-linejoin="round" d="M8.25 4.5l7.5 7.5-7.5 7.5" />
          </svg>
        </div>
      </a>
    `).join("")

    this.resultsTarget.classList.remove("hidden")
  }

  hideResults() {
    this.resultsTarget.classList.add("hidden")
    this.noResultsTarget.classList.add("hidden")
    this.hideSearching()
  }

  showSearching() {
    if (this.hasSearchingTarget) {
      this.searchingTarget.classList.remove("hidden")
    }
  }

  hideSearching() {
    if (this.hasSearchingTarget) {
      this.searchingTarget.classList.add("hidden")
    }
  }

  escapeHtml(text) {
    const div = document.createElement("div")
    div.textContent = text
    return div.innerHTML
  }

  clear() {
    this.inputTarget.value = ""
    this.hideResults()
  }
}
