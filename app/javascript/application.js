// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"

// Load selects
document.addEventListener("turbo:load", function (e) {
    const elems = document.querySelectorAll('select');
    M.FormSelect.init(elems);
})