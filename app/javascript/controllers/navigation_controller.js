import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="navigation"
export default class extends Controller {
  static targets = ["menuToggle", "navLinks"];

  connect() {

    // Optional: Close the menu when clicking outside
    document.addEventListener('click', function(event) {
      if (!this.navLinksTarget.contains(event.target) && !this.menuToggleTarget.contains(event.target)) {
        if (this.navLinksTarget.classList.contains('active')) {
          this.navLinksTarget.classList.remove('active');
          this.menuToggleTarget.classList.remove('active');
          this.menuToggleTarget.setAttribute('aria-expanded', 'false');
        }
      }
    }.bind(this));
  }

  toggleHamburger(_event) {
    const isActive = this.navLinksTarget.classList.toggle('active');
    this.menuToggleTarget.classList.toggle('active');
    // Update ARIA attribute for accessibility
    this.menuToggleTarget.setAttribute('aria-expanded', isActive);
  }
}

