import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = [
    "drawCheckbox",
    "winnerLoserFields",
    "winnerSelect",
    "loserSelect",
  ];

  connect() {
    console.log("MatchResultController connected");
    this.toggleWinnerLoserFields();
  }

  toggleWinnerLoserFields() {
    const isDraw = this.drawCheckboxTarget.checked;

    if (isDraw) {
      this.winnerLoserFieldsTarget.style.display = "none";
      this.winnerSelectTarget.disabled = true;
      this.loserSelectTarget.disabled = true;

      this.winnerSelectTarget.value = "";
      this.loserSelectTarget.value = "";
    } else {
      this.winnerLoserFieldsTarget.style.display = "block";
      this.winnerSelectTarget.disabled = false;
      this.loserSelectTarget.disabled = false;
    }
  }
}
