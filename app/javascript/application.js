import "@hotwired/turbo-rails"
import { Turbo } from "@hotwired/turbo-rails"

import "./controllers"
import "./channels"
import './cars'
import "./play"
import "./nav"
import "./weekly_schedule"

Turbo.session.drive = false
