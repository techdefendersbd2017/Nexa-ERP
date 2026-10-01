function toggleColumn(headerChk, itemChkId) {
    var grid = document.getElementById('<%= gvModule.ClientID %>');
    var inputs = grid.getElementsByTagName("input");

    for (var i = 0; i < inputs.length; i++) {
        if (inputs[i].id.indexOf(itemChkId) !== -1) {
            inputs[i].checked = headerChk.checked;
        }
    }
}