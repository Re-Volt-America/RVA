import "@hotwired/turbo-rails"
import { Turbo } from "@hotwired/turbo-rails"

import "./controllers"
import "./channels"
import './cars'
import "./play"
import "./nav"

Turbo.session.drive = false
