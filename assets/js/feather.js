
var dY = 0;
var time = 0;
var init_position = NaN;
var move_feather;

function featherfall() {
    
    let feather = document.getElementById("site-left-feather");
    if (isNaN(init_position)) {
        init_position = feather.getBoundingClientRect().bottom + window.scrollY;
        console.log(init_position);
    }

    function getTransform() {
        let x1 = Math.cos(time);
        return "translateX(calc(50% + 50px + "+ (x1 * 50).toString() + "px))" + 
            " translateY(" + dY.toString() + "px) " + 
            " rotate(" + (-x1*20).toString() + "deg)";
    }

    clearInterval(move_feather);
    move_feather = setInterval(function() {
        let bottom = feather.getBoundingClientRect().bottom;
        if (bottom >= window.innerHeight) {
            dY = window.innerHeight + window.scrollY - init_position;
            feather.style.transform = getTransform();
            clearInterval(move_feather);
        }
        time += 0.05;
        dY += 2;
        feather.style.transform = getTransform();
    }, 15);
}

window.addEventListener('load', (event) => {
    featherfall();
});

window.addEventListener('scroll', (event) => {
    featherfall();
});

window.addEventListener('resize', (event) => {
    featherfall();
});