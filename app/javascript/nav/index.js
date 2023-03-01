//
// §NOTE: This solution only works for one dropdown-submenu on screen. A way to
//       differentiate them via aria-labelled-by or IDs would be required in
//       order to allow multiple of these at the same time. Bootstrap 4...
//

$(document).on('turbo:load', function () {
    var submenus = document.getElementsByClassName('dropdown-submenu');

    for (var i = 0; i < submenus.length; i++) {
        submenu = submenus.item(0)
        dropdownMenu = submenu.querySelector('.dropdown-menu');
        submenu.addEventListener("click", onSubmenuClick(dropdownMenu))
        window.addEventListener("click", function (e) {
            if (!outsideClick(e, dropdownMenu)) return
            dropdownMenu.classList.remove("show")
        })
    }
})

const onSubmenuClick = function (dropdownMenu) {
    return function onSubmenuClickEvent(e) {
        e.stopPropagation()

        if (dropdownMenu == null) return;
        if (!dropdownMenu.classList.contains("show")) {
            dropdownMenu.classList.add("show")
            return
        }

        dropdownMenu.classList.remove("show")
    }
}

function outsideClick(event, notelem)	{
    notelem = $(notelem); // jquerize (optional)
    // check outside click for multiple elements
    var clickedOut = true, i, len = notelem.length;
    for (i = 0;i < len;i++)  {
        if (event.target == notelem[i] || notelem[i].contains(event.target)) {
            clickedOut = false;
        }
    }
    if (clickedOut) return true;
    else return false;
}
