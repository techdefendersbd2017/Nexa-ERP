window.onload = function () {
    var hf = document.getElementById('<%= hfScrollPosition.ClientID %>');
    if (hf && hf.value && parseInt(hf.value) > 0) {
        window.scrollTo(0, parseInt(hf.value));
    }
};

function saveScrollPos() {
    document.getElementById('<%= hfScrollPosition.ClientID %>').value =
        (window.pageYOffset || document.documentElement.scrollTop);
}