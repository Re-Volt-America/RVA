import { Turbo } from "@hotwired/turbo-rails"

import "./controllers"
import "./channels"
import "./play"
import "./nav"

Turbo.session.drive = false
