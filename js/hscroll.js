// http://www.dte.web.id/2013/02/event-mouse-wheel.html

(function() {
    function scrollHorizontally(e) {
        e = window.event || e;
        var delta = Math.max(-1, Math.min(1, (e.wheelDelta || -e.detail)));
        document.getElementById('hscroll').scrollLeft -= (delta*40); // Multiplied by 40
        e.preventDefault();
    }
    if (document.getElementById('hscroll').addEventListener) {
        // IE9, Chrome, Safari, Opera
        document.getElementById('hscroll').addEventListener("mousewheel", scrollHorizontally, false);
        // Firefox
        document.getElementById('hscroll').addEventListener("DOMMouseScroll", scrollHorizontally, false);
    } else {
        // IE 6/7/8
        document.getElementById('hscroll').attachEvent("onmousewheel", scrollHorizontally);
    }
})();


