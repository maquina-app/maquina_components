# Pin npm packages by running ./bin/importmap

pin "application"

# Hotwire
pin "@hotwired/turbo-rails", to: "turbo.min.js"
pin "@hotwired/stimulus", to: "stimulus.min.js"
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js"

# Application controllers
pin_all_from "app/javascript/controllers", under: "controllers"
