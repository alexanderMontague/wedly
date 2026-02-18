import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = [
    "video",
    "canvas",
    "flashPop",
    "flashButton",
    "shutterButton",
    "status",
    "orientationWarning",
  ];

  static values = {
    uploadUrl: String,
  };

  async connect() {
    this.flashEnabled = false;
    this.torchSupported = false;
    this.orientationMediaQuery = window.matchMedia("(orientation: portrait)");
    this.orientationHandler = () => this.updateOrientationState();
    this.resizeHandler = () => this.updateOrientationState();

    this.orientationMediaQuery.addEventListener("change", this.orientationHandler);
    window.addEventListener("resize", this.resizeHandler);
    this.updateOrientationState();
    await this.startCamera();
  }

  disconnect() {
    this.orientationMediaQuery?.removeEventListener("change", this.orientationHandler);
    window.removeEventListener("resize", this.resizeHandler);
    this.stopCamera();
  }

  async toggleFlash() {
    if (!this.torchSupported || !this.track) return;

    this.flashEnabled = !this.flashEnabled;

    try {
      await this.track.applyConstraints({
        advanced: [{ torch: this.flashEnabled }],
      });
      this.renderFlashButton();
    } catch (error) {
      this.flashEnabled = false;
      this.setStatus("Flash control is not available on this device.");
      this.renderFlashButton();
    }
  }

  async takePhoto() {
    if (!this.stream) {
      this.setStatus("Camera is not ready yet.");
      return;
    }

    if (this.isPortrait()) {
      this.setStatus("Rotate your device horizontally first.");
      return;
    }

    this.shutterButtonTarget.disabled = true;
    this.shutterButtonTarget.textContent = "Saving...";

    try {
      this.showFlashPop();
      const blob = await this.captureFrame();
      await this.uploadPhoto(blob);
      this.setStatus("Photo saved. Keep snapping.");
    } catch (error) {
      this.setStatus(error.message || "Could not upload photo.");
    } finally {
      this.shutterButtonTarget.disabled = false;
      this.shutterButtonTarget.textContent = "Snap";
    }
  }

  async startCamera() {
    try {
      this.stream = await navigator.mediaDevices.getUserMedia({
        audio: false,
        video: {
          facingMode: { ideal: "environment" },
          width: { ideal: 1920 },
          height: { ideal: 1080 },
        },
      });

      this.videoTarget.srcObject = this.stream;
      await this.videoTarget.play();
      this.track = this.stream.getVideoTracks()[0];
      this.setupTorchSupport();
      this.setStatus("Camera ready.");
    } catch (error) {
      this.setStatus("Camera access denied. Allow access and refresh.");
    }
  }

  stopCamera() {
    if (!this.stream) return;

    this.stream.getTracks().forEach((track) => track.stop());
    this.stream = null;
    this.track = null;
  }

  setupTorchSupport() {
    if (!this.track || typeof this.track.getCapabilities !== "function") {
      this.torchSupported = false;
      this.renderFlashButton();
      return;
    }

    const capabilities = this.track.getCapabilities();
    this.torchSupported = Boolean(capabilities.torch);
    this.renderFlashButton();
  }

  renderFlashButton() {
    if (!this.flashButtonTarget) return;

    if (!this.torchSupported) {
      this.flashButtonTarget.textContent = "Flash: Unsupported";
      this.flashButtonTarget.disabled = true;
      return;
    }

    this.flashButtonTarget.disabled = false;
    this.flashButtonTarget.textContent = this.flashEnabled ? "Flash: On" : "Flash: Off";
  }

  updateOrientationState() {
    const portrait = this.isPortrait();
    this.orientationWarningTarget.classList.toggle("hidden", !portrait);
    this.shutterButtonTarget.disabled = portrait;
  }

  isPortrait() {
    return this.orientationMediaQuery.matches || window.innerHeight > window.innerWidth;
  }

  captureFrame() {
    return new Promise((resolve, reject) => {
      const width = this.videoTarget.videoWidth;
      const height = this.videoTarget.videoHeight;

      if (!width || !height) {
        reject(new Error("Video feed is not ready."));
        return;
      }

      this.canvasTarget.width = width;
      this.canvasTarget.height = height;
      const context = this.canvasTarget.getContext("2d");
      context.drawImage(this.videoTarget, 0, 0, width, height);
      this.canvasTarget.toBlob(
        (blob) => {
          if (blob) {
            resolve(blob);
          } else {
            reject(new Error("Failed to capture image."));
          }
        },
        "image/jpeg",
        0.9,
      );
    });
  }

  async uploadPhoto(blob) {
    const formData = new FormData();
    formData.append("photo", blob, `disposable-${Date.now()}.jpg`);
    formData.append("flash_enabled", String(this.flashEnabled));
    formData.append("captured_at", new Date().toISOString());

    const csrfToken = document.querySelector("meta[name='csrf-token']")?.content;
    const response = await fetch(this.uploadUrlValue, {
      method: "POST",
      headers: {
        "X-CSRF-Token": csrfToken || "",
      },
      body: formData,
      credentials: "same-origin",
    });

    if (!response.ok) {
      const errorPayload = await response.json().catch(() => ({}));
      throw new Error(errorPayload.error || "Upload failed.");
    }
  }

  showFlashPop() {
    this.flashPopTarget.classList.remove("hidden");
    this.flashPopTarget.classList.add("is-active");

    window.setTimeout(() => {
      this.flashPopTarget.classList.remove("is-active");
      this.flashPopTarget.classList.add("hidden");
    }, 180);
  }

  setStatus(message) {
    this.statusTarget.textContent = message;
  }
}
