import "@hotwired/turbo-rails"
import { Turbo } from "@hotwired/turbo-rails"
import "chartkick/chart.js"

import "./controllers"
import "./channels"
import './cars'
import "./play"
import "./nav"
import './session'
import "./weekly_schedule"

Turbo.session.drive = false
