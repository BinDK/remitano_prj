# Pin npm packages by running ./bin/importmap

pin "application"
pin "@hotwired/turbo-rails", to: "turbo.min.js"
pin "@hotwired/stimulus", to: "stimulus.min.js"
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js"
pin_all_from "app/javascript/controllers", under: "controllers"
pin "@rails/actioncable", to: "actioncable.esm.js"
pin "channels", to: "channels.js"
pin "channels/consumer", to: "channels/consumer.js"
pin "channels/index", to: "channels/index.js"
pin "channels/video_notifications_channel", to: "channels/video_notifications_channel.js"
