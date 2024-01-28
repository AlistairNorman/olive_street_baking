# Pin npm packages by running ./bin/importmap

pin "application"
pin "@hotwired/turbo-rails", to: "turbo.min.js", preload: true
pin "@stripe/stripe-js", to: "https://ga.jspm.io/npm:@stripe/stripe-js@2.4.0/dist/stripe.esm.js"
