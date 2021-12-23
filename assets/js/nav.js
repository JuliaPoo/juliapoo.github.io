
// Dynamically resizes the nav bar.
window.addEventListener('scroll', (event) => {

    // Reduce size of nav
    let icon = document.getElementsByClassName("nav-icon")[0];
    let em = parseFloat(getComputedStyle(icon).fontSize);
    let sz = Math.max(3*em, 5.5*em-window.scrollY*0.2);
    let sz_str = sz.toString() + "px";
    icon.style.height = sz_str; 
    icon.style.width = sz_str; 

    // Make it disappear
    let opacity = 4 - window.scrollY / (5*em);
    let nav = document.getElementsByClassName("nav-container")[0];
    nav.style.opacity = opacity.toString();
});