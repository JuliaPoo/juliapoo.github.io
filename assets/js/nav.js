window.addEventListener('scroll', (event) => {
    let icon = document.getElementsByClassName("nav-icon")[0];
    let em = parseFloat(getComputedStyle(icon).fontSize);
    let sz = Math.max(2.5*em, 5*em-window.scrollY) + 10;
    let sz_str = sz.toString() + "px";
    icon.style.height = sz_str; 
    icon.style.width = sz_str; 
});