import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["overlay", "image"];

  connect() {
    this.boundHandleKeydown = this.handleKeydown.bind(this);
  }

  disconnect() {
    document.removeEventListener("keydown", this.boundHandleKeydown);
  }

  open(event) {
    const img = event.currentTarget.querySelector("img");
    if (!img) return;

    this.imageTarget.src = img.src;
    this.imageTarget.alt = img.alt;
    this.overlayTarget.classList.add("is-open");
    document.addEventListener("keydown", this.boundHandleKeydown);
  }

  close() {
    this.overlayTarget.classList.remove("is-open");
    document.removeEventListener("keydown", this.boundHandleKeydown);
  }

  closeOnBackdrop(event) {
    if (event.target === this.overlayTarget) this.close();
  }

  handleKeydown(event) {
    if (event.key === "Escape") this.close();
  }
}
