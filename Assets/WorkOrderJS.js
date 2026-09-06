
    function applyPanel(panelId) {
        document.querySelectorAll('.panel').forEach(function (p) {
            p.classList.remove('active');
        });
        var el = document.getElementById(panelId);
        if (el) { el.classList.add('active'); }
    }

    function showPanel(panelId) {
        applyPanel(panelId);
        try { sessionStorage.setItem('wo_panel', panelId); } catch (e) { }
    }

    function restoreUIState() {
        try {
            var panel = sessionStorage.getItem('wo_panel') || 'pnlList';

            applyPanel(panel);

            var scrollY = sessionStorage.getItem('wo_scrollY');
            if (scrollY !== null) {
                setTimeout(function () {
                    window.scrollTo(0, parseInt(scrollY, 10) || 0);
                }, 0);
            }
        } catch (e) { }
    }

    var _woScrollSaveTimer = null;
    window.addEventListener('scroll', function () {
        if (_woScrollSaveTimer) { clearTimeout(_woScrollSaveTimer); }
        _woScrollSaveTimer = setTimeout(function () {
            try { sessionStorage.setItem('wo_scrollY', window.scrollY); } catch (e) { }
        }, 150);
    });

    function calculateRowTotal() {
        var reqQty = parseFloat(document.getElementById('<%= txtReqQty.ClientID %>').value) || 0;
        var rateUnit = parseFloat(document.getElementById('<%= txtRate.ClientID %>').value) || 0;
        var extraPercent = parseFloat(document.getElementById('<%= txtExtraPercent.ClientID %>').value) || 0;

        var totalReqQty = reqQty + (reqQty * (extraPercent / 100));
        var totalAmount = totalReqQty * rateUnit;

        document.getElementById('<%= txtTotalReqQtyInput.ClientID %>').value = totalReqQty.toFixed(2);
        document.getElementById('<%= txtTotalAmountInput.ClientID %>').value = totalAmount.toFixed(2);
    }

    $(document).ready(function () {
        initializeSelect2();
        initializeAutocompleteFields();
        restoreUIState();
    });

    function pageLoad(sender, args) {
        initializeSelect2();
        initializeAutocompleteFields();
        restoreUIState();
    }

    function initializeSelect2() {
        $('.searchable-dropdown').each(function () {
            if (!$(this).hasClass("select2-hidden-accessible")) {
                $(this).select2({
                    theme: "bootstrap-5",
                    placeholder: "Search",
                    allowClear: true,
                    width: '100%'
                });
            }
        });
    }
    function calculateRow(inputElement) {
        var row = inputElement.closest('tr');

        var txtReqQty = row.querySelector("[id*='txtReqQty']");
        var txtRateUnit = row.querySelector("[id*='txtRateUnit']");
        var txtExtraPercent = row.querySelector("[id*='txtExtraPercent']");

        var lblTotalReqQty = row.querySelector("[id*='lblTotalReqQty']");
        var lblTotalAmount = row.querySelector("[id*='lblTotalAmount']");

        var reqQty = parseFloat(txtReqQty.value) || 0;
        var rateUnit = parseFloat(txtRateUnit.value) || 0;
        var extraPercent = parseFloat(txtExtraPercent.value) || 0;

        var totalReqQty = reqQty + (reqQty * extraPercent / 100);
        var totalAmount = totalReqQty * rateUnit;

        if (lblTotalReqQty) lblTotalReqQty.innerText = totalReqQty.toFixed(2);
        if (lblTotalAmount) lblTotalAmount.innerText = totalAmount.toFixed(2);
    }

    // =====================================================================
    // SELECT ALL / UNSELECT ALL — gvSizeList হেডার চেকবক্স (chkHeaderView)
    // markup: onclick="toggleColumn(this, 'chkItemView');"
    // =====================================================================
    function toggleColumn(headerCheckbox, targetClass) {
        var checkboxes = document.querySelectorAll('.' + targetClass);
        checkboxes.forEach(function (cb) {
            cb.checked = headerCheckbox.checked;
        });

        // সব চেক/আনচেক হওয়ার পর টোটাল কোয়ান্টিটি বক্সও রিফ্রেশ করা হচ্ছে
        if (typeof calculateTotalQty === 'function') {
            calculateTotalQty();
        }
    }

    // =====================================================================
    // AUTOCOMPLETE (Buyer / Style / Order No)
    // =====================================================================
    var _acDebounceTimer = null;

    function initializeAutocompleteFields() {
        bindAutocomplete('<%= txtBuyer.ClientID %>', '<%= lstBuyerSuggest.ClientID %>', 'GetBuyerSuggestions');
        bindAutocomplete('<%= txtStyle.ClientID %>', '<%= lstStyleSuggest.ClientID %>', 'GetStyleSuggestions');
        bindAutocomplete('<%= txtOrderNo.ClientID %>', '<%= lstOrderSuggest.ClientID %>', 'GetOrderSuggestions');
    }

    function bindAutocomplete(inputId, listId, webMethodName) {
        var $input = $('#' + inputId);
        var $list = $('#' + listId);

        if ($input.length === 0 || $list.length === 0) return;

        if ($input.data('ac-bound')) return;
        $input.data('ac-bound', true);

        $input.on('keyup', function (e) {
            if ([13, 27, 38, 40].indexOf(e.keyCode) !== -1) return;

            var term = $input.val().trim();

            if (_acDebounceTimer) clearTimeout(_acDebounceTimer);

            if (term.length < 1) {
                $list.removeClass('show').empty();
                return;
            }

            _acDebounceTimer = setTimeout(function () {
                fetchSuggestions(webMethodName, term, $list, $input);
            }, 250);
        });

        $input.on('keydown', function (e) {
            var $items = $list.find('.ac-suggestion-item');
            if ($items.length === 0) return;

            var $active = $list.find('.ac-suggestion-item.active');
            var idx = $items.index($active);

            if (e.keyCode === 40) {
                e.preventDefault();
                idx = (idx + 1) % $items.length;
                $items.removeClass('active');
                $items.eq(idx).addClass('active');
            } else if (e.keyCode === 38) {
                e.preventDefault();
                idx = (idx <= 0) ? $items.length - 1 : idx - 1;
                $items.removeClass('active');
                $items.eq(idx).addClass('active');
            } else if (e.keyCode === 13) {
                if ($active.length) {
                    e.preventDefault();
                    $input.val($active.text());
                    $list.removeClass('show').empty();
                }
            } else if (e.keyCode === 27) {
                $list.removeClass('show').empty();
            }
        });

        $(document).on('click', function (e) {
            if (!$(e.target).closest($input.parent()).length) {
                $list.removeClass('show').empty();
            }
        });

        $input.on('blur', function () {
            setTimeout(function () { $list.removeClass('show').empty(); }, 150);
        });
    }

    function fetchSuggestions(webMethodName, term, $list, $input) {
        $.ajax({
            type: "POST",
            url: "WorkOrderReceived.aspx/" + webMethodName,
            data: JSON.stringify({ prefixText: term }),
            contentType: "application/json; charset=utf-8",
            dataType: "json",
            success: function (response) {
                renderSuggestions(response.d, $list, $input);
            },
            error: function () {
                $list.removeClass('show').empty();
            }
        });
    }

    function renderSuggestions(items, $list, $input) {
        $list.empty();

        if (!items || items.length === 0) {
            $list.removeClass('show');
            return;
        }

        items.forEach(function (val) {
            var $li = $('<li>').addClass('ac-suggestion-item').text(val);
            $li.on('mousedown', function (e) {
                e.preventDefault();
                $input.val(val);
                $list.removeClass('show').empty();
            });
            $list.append($li);
        });

        $list.addClass('show');
    }
