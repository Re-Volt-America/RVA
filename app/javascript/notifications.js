const NOTIFICATION_DURATION = 5000

function dismissNotification(notification) {
  if (notification.classList.contains("leaving")) return
  notification.classList.add("leaving")
  notification.addEventListener("animationend", () => notification.remove())
}

function initNotifications() {
  document.querySelectorAll(".notification").forEach((notification) => {
    const closeBtn = notification.querySelector(".notification-close")
    if (closeBtn) {
      closeBtn.addEventListener("click", () => dismissNotification(notification))
    }

    notification.addEventListener("mouseenter", () => {
      const bar = notification.querySelector(".notification-progress-bar")
      if (bar) bar.style.animationPlayState = "paused"
    })

    notification.addEventListener("mouseleave", () => {
      const bar = notification.querySelector(".notification-progress-bar")
      if (bar) bar.style.animationPlayState = "running"
    })

    setTimeout(() => dismissNotification(notification), NOTIFICATION_DURATION)
  })
}

document.addEventListener("DOMContentLoaded", initNotifications)
document.addEventListener("turbo:load", initNotifications)
document.addEventListener("turbo:render", initNotifications)
