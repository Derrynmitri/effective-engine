import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["modal", "itemName", "deleteForm"];
  static values = {
    deleteUrl: String,
    itemName: String,
  };

  connect() {
    this.boundCloseOnOutsideClick = this.closeOnOutsideClick.bind(this);
    this.boundCloseOnEscape = this.closeOnEscape.bind(this);
  }

  disconnect() {
    document.removeEventListener("click", this.boundCloseOnOutsideClick);
    document.removeEventListener("keydown", this.boundCloseOnEscape);
  }

  show(event) {
    event.preventDefault();
    event.stopPropagation();

    this.itemNameTarget.textContent = this.itemNameValue;
    this.deleteFormTarget.action = this.deleteUrlValue;

    this.modalTarget.classList.remove("hidden");
    this.modalTarget.classList.add("flex");

    document.addEventListener("click", this.boundCloseOnOutsideClick);
    document.addEventListener("keydown", this.boundCloseOnEscape);
  }

  hide() {
    this.modalTarget.classList.add("hidden");
    this.modalTarget.classList.remove("flex");

    document.removeEventListener("click", this.boundCloseOnOutsideClick);
    document.removeEventListener("keydown", this.boundCloseOnEscape);
  }

  cancel(event) {
    event.preventDefault();
    this.hide();
  }

  confirm(event) {
    event.preventDefault();
    this.deleteFormTarget.submit();
  }

  closeOnOutsideClick(event) {
    if (event.target === this.modalTarget) {
      this.hide();
    }
  }

  closeOnEscape(event) {
    if (event.key === "Escape") {
      this.hide();
    }
  }
}
