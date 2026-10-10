function selectAllGrid(v) {
    document.querySelectorAll('input[name="rowChk"]').forEach(function (c) { c.checked = v; });
    var h = document.getElementById('chkSelectAll');
    if (h) h.checked = v;
}