
var dY = 0;
var time = 0;
var init_position = NaN;
var move_feather = NaN;

function featherfall() {
    
    let feather = document.getElementById("site-feather");

    if (isNaN(init_position)) {
        init_position = feather.getBoundingClientRect().bottom + window.scrollY;
        console.log(init_position);
    }

    function getTransform() {
        let x1 = Math.cos(time);
        return "translateX(calc(50% + 50px + "+ (x1 * 50).toString() + "px))" + 
            " translateY(" + (dY + 30).toString() + "px) " + 
            " rotate(" + (-x1*20).toString() + "deg)";
    }

    if (!isNaN(move_feather)) return

    move_feather = setInterval(function() {

        time += 0.05;
        dY += 2;
        feather.style.transform = getTransform();

        let bottom = feather.getBoundingClientRect().bottom + 10;
        if (bottom >= window.innerHeight) {

            let pdY = dY;
            dY = window.innerHeight + window.scrollY - init_position - 10;

            if (pdY > dY) {

                let v = pdY - dY;
                let puff_feather = setInterval(function() {

                    feather.style.transform = getTransform();
                    if (v > 0 || dY < v) {
                        dY -= v;
                        v -= 0.4;
                        return;
                    }

                    dY = Math.max(0, dY);
                    if (dY == 0)
                        feather.style.transform = getTransform();
                    clearInterval(puff_feather);

                }, 15);
            } 
            else {
                clearInterval(move_feather);
                move_feather = NaN;
            }
        }

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