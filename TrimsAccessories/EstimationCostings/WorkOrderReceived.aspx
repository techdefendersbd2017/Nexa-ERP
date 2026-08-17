<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="WorkOrderReceived.aspx.cs" Inherits="Nexa_ERP.TrimsAccessories.EstimationCostings.WorkOrderReceived" %>

<!DOCTYPE html>
<html>
<head runat="server">
    <title>Work Order Received</title>

    <!-- Bootstrap 5 CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet" />

    <!-- Select2 CSS -->
    <link href="https://cdn.jsdelivr.net/npm/select2@4.1.0-rc.0/dist/css/select2.min.css" rel="stylesheet" />

    <!-- Select2 Bootstrap 5 Theme -->
    <link href="https://cdn.jsdelivr.net/npm/select2-bootstrap-5-theme@1.3.0/dist/select2-bootstrap-5-theme.min.css" rel="stylesheet" />

    <!-- jQuery (Must be loaded before Select2 JS) -->
    <script src="https://cdnjs.cloudflare.com/ajax/libs/jquery/3.6.0/jquery.min.js"></script>

    <!-- Select2 JS -->
    <script src="https://cdn.jsdelivr.net/npm/select2@4.1.0-rc.0/dist/js/select2.min.js"></script>

    <style>
        body {
            background-color: #f4f6f9;
            font-size: 14px;
        }

        /* ================= CARD / HEADER ================= */
        .card-header-custom {
            background: linear-gradient(135deg, #1f4e78 0%, #2c6ca3 100%);
            color: #fff;
            font-weight: bold;
            letter-spacing: 0.3px;
        }
        .card {
            border: none;
            border-radius: 10px;
            overflow: hidden;
        }
        .card-body {
            background-color: #ffffff;
        }

        /* ================= TABLE / GRID ================= */
        .table-dark-custom {
            background-color: #1f4e78;
            color: white;
        }
        .grid {
            width: 100%;
            background: white;
            border: 1px solid #dee2e6;
            border-radius: 6px;
            overflow: hidden;
        }
        .grid th {
            background-color: #1f4e78;
            color: white;
            padding: 10px;
        }
        .grid td {
            padding: 8px;
            border-bottom: 1px solid #eef0f2;
            vertical-align: middle;
        }

        /* ================= PANEL SWITCH ================= */
        .panel {
            display: none;
        }
        .panel.active {
            display: block;
        }

        /* ================= LIST TOOLBAR ================= */
        .list-toolbar {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 18px;
        }
        .list-title {
            font-size: 1.3rem;
            font-weight: 700;
            color: #1f4e78;
        }

        /* ================= FIELDSET / SECTION CARDS ================= */
        fieldset.section-box {
            background-color: #fbfcfe;
            border: 1px solid #e1e6ec !important;
            border-radius: 10px !important;
            padding: 18px 20px !important;
            margin-bottom: 22px !important;
            box-shadow: 0 1px 3px rgba(0, 0, 0, 0.04);
        }
        fieldset.section-box legend {
            background-color: #eaf2fa;
            padding: 4px 14px !important;
            border-radius: 20px;
            color: #1f4e78 !important;
            font-size: 0.95rem !important;
        }

        /* ================= INLINE INPUT ROW (Item/Color/Size Entry) ================= */
        .entry-row {
            background: #f1f5fa;
            border: 1px dashed #c7d6e5;
            border-radius: 8px;
            padding: 14px 12px 10px 12px;
            margin-bottom: 12px;
        }
        .entry-row .form-label {
            color: #495057;
            margin-bottom: 3px;
        }

        .form-label.small.fw-bold {
            font-size: 0.78rem;
            text-transform: uppercase;
            letter-spacing: 0.3px;
            color: #495057;
        }

        .optional-tag {
            font-size: 0.7rem;
            font-weight: 500;
            text-transform: none;
            color: #8a97a6;
        }

        /* ================= SUMMARY BOX ================= */
        .summary-box .input-group-text {
            background-color: #eef2f7;
            color: #1f4e78;
        }
        .summary-box .input-group-text.grand-total {
            background-color: #1f4e78 !important;
            color: #fff !important;
        }
        .summary-box .form-control {
            font-weight: 600;
        }

        /* Custom Styling for Select2 to look like a Rounded Modern Textbox without Arrow */
        .select2-container--bootstrap-5 .select2-selection {
            border-radius: 0.375rem !important;
            min-height: calc(1.5em + 0.5rem + 2px);
            padding: 0.25rem 0.5rem;
            font-size: 0.875rem;
            border: 1px solid #ced4da;
            background-image: none !important;
        }

        /* ড্রপডাউন অ্যারো হাইড করা */
        .select2-container--bootstrap-5 .select2-selection .select2-selection__arrow {
            display: none !important;
        }

        .select2-container--bootstrap-5 .select2-dropdown {
            border-radius: 0.5rem !important;
            box-shadow: 0 0.5rem 1rem rgba(0, 0, 0, 0.15);
            border: 1px solid #86b7fe;
            padding: 6px;
        }

        /* ড্রপডাউনের ভেতরের সার্চ কন্টেইনার এবং ছোট ও আকর্ষণীয় সার্চ বক্স */
        .select2-container--bootstrap-5 .select2-search {
            padding: 4px;
        }
        .select2-container--bootstrap-5 .select2-search .select2-search__field {
            width: 85% !important; /* সার্চ বক্সের প্রস্থ ছোট করা হয়েছে */
            margin: 0 auto !important;
            display: block !important;
            border-radius: 50rem !important;
            padding: 0.25rem 0.75rem !important;
            font-size: 0.8rem !important;
            border: 1px solid #bce8f1 !important;
            background-color: #fdfdfe !important;
            outline: none;
            transition: all 0.2s ease-in-out;
        }
        .select2-container--bootstrap-5 .select2-search .select2-search__field:focus {
            border-color: #1f4e78 !important;
            box-shadow: 0 0 0 0.2rem rgba(31, 78, 120, 0.15) !important;
            background-color: #ffffff !important;
        }

        /* ================= AUTOCOMPLETE SUGGESTION DROPDOWN ================= */
        /* Buyer / Style / Order No textbox-এর জন্য custom autocomplete (jQuery UI ছাড়াই,
           Bootstrap 5 এর সাথে visually মিলে যায়) */
        .ac-wrapper {
            position: relative;
        }
        .ac-suggestion-list {
            list-style: none;
            margin: 0;
            padding: 0;
            position: absolute;
            top: 100%;
            left: 0;
            right: 0;
            z-index: 2000;
            background: #fff;
            border: 1px solid #86b7fe;
            border-radius: 0.375rem;
            box-shadow: 0 0.5rem 1rem rgba(0, 0, 0, 0.15);
            max-height: 220px;
            overflow-y: auto;
            display: none;
        }
        .ac-suggestion-list.show {
            display: block;
        }
        .ac-suggestion-item {
            padding: 6px 12px;
            font-size: 0.85rem;
            cursor: pointer;
            color: #212529;
        }
        .ac-suggestion-item:hover,
        .ac-suggestion-item.active {
            background-color: #1f4e78;
            color: #fff;
        }
        .ac-suggestion-empty {
            padding: 6px 12px;
            font-size: 0.8rem;
            color: #999;
        }

        /* Active color row highlight (used by gvColorList_RowDataBound) */
        .active-color-row {
            background-color: #d1e7ff !important;
        }

        /* ================= ACTION BUTTONS FOOTER ================= */
        .form-footer-actions {
            border-top: 1px solid #e9ecef;
            padding-top: 16px;
            margin-top: 8px;
        }

        /* ================= REFRESH ICON BUTTON (shared: Customer / Item / Color) ================= */
        .refresh-icon-btn {
            width: 34px;
            min-width: 34px;
            height: 34px;
            margin-left: 6px;
            border-radius: 8px !important;
            background-color: #eaf2fa !important;
            color: #1f4e78 !important;
            border: 1px solid #cfe0f0 !important;
            transition: all 0.2s ease-in-out;
            flex-shrink: 0; /* [FIX] বাটন যেন কখনো সংকুচিত না হয় */
        }
        .refresh-icon-btn:hover {
            background-color: #1f4e78 !important;
            color: #fff !important;
            transform: rotate(90deg);
        }

        /* [FIX] flex row-এ select2 কে সংকুচিত হতে দেওয়া, রিফ্রেশ বাটনের উপর overlap বন্ধ */
        .entry-row .d-flex,
        .col-md-3 > .d-flex {
            flex-wrap: nowrap;
        }
        .d-flex .select2-container,
        .d-flex select.form-select {
            min-width: 0;
            flex: 1 1 auto;
        }

        /* ================= VARIANT ENTRY - REDESIGN (single flowing row, no split boxes) ================= */
        .entry-row {
            background: linear-gradient(180deg, #f7fafd 0%, #eef3f9 100%);
            border: 1px solid #dbe6f2;
            border-radius: 10px;
            padding: 16px 14px 12px 14px;
            margin-bottom: 14px;
            box-shadow: 0 1px 3px rgba(31, 78, 120, 0.06);
        }
        .entry-row .form-control,
        .entry-row .form-select {
            border: 1px solid #d3dfec;
            transition: box-shadow 0.15s ease-in-out, border-color 0.15s ease-in-out;
        }
        .entry-row .form-control:focus,
        .entry-row .form-select:focus {
            border-color: #1f4e78;
            box-shadow: 0 0 0 0.15rem rgba(31, 78, 120, 0.15);
        }
        /* subtle vertical separators between logical field groups on wide screens */
        .entry-divider {
            border-left: 1px dashed #c7d6e5;
            padding-left: 14px !important;
        }
        /* [FIX] breakpoint 767.98px -> 991.98px, নতুন col-lg-1 breakpoint এর সাথে মিলিয়ে */
        @media (max-width: 991.98px) {
            .entry-divider {
                border-left: none;
                padding-left: 0.5rem !important;
            }
        }
        .readonly-total .form-control {
            background-color: #eef7ef !important;
            color: #1b5e20 !important;
            font-weight: 700;
            border: 1px solid #bfe3c4 !important;
        }
        .auto-calc-tag {
            font-size: 0.65rem;
            font-weight: 600;
            color: #2e7d32;
            background: #e6f4ea;
            border-radius: 20px;
            padding: 1px 8px;
            margin-left: 6px;
            text-transform: none;
            letter-spacing: 0;
        }
        .add-variant-btn {
            background: linear-gradient(135deg, #28a745 0%, #1e7e34 100%);
            border: none;
            font-weight: 600;
            letter-spacing: 0.3px;
            box-shadow: 0 2px 6px rgba(40, 167, 69, 0.35);
            transition: all 0.2s ease-in-out;
        }
        .add-variant-btn:hover {
            box-shadow: 0 4px 10px rgba(40, 167, 69, 0.45);
            transform: translateY(-1px);
        }
        .variant-grid-title {
            font-size: 0.95rem;
            font-weight: 700;
            color: #1f4e78;
            display: flex;
            align-items: center;
            gap: 6px;
            margin: 4px 0 10px 0;
        }

        /* [FIX] খুব ছোট স্ক্রিনে (ফোন) কন্টেইনার/এন্ট্রি-রো প্যাডিং কমানো, যাতে ফিল্ডগুলো বেশি জায়গা পায় */
        @media (max-width: 575.98px) {
            .container {
                padding-left: 10px;
                padding-right: 10px;
            }
            .entry-row {
                padding: 12px 8px 8px 8px;
            }
        }

        /* ================= [FIX] Item Rate → Add বাটন পর্যন্ত অংশটা CSS Grid দিয়ে re-build =================
           কারণ: Bootstrap-এর col-lg-1 (8.33%) খুবই সরু, ফলে "TOTAL REQ. QTY", "TOTAL AMOUNT" এর মতো
           লেবেল wrap করে পাশের কলামের উপর গিয়ে overlap করছিল। CSS Grid প্রতিটা row-এর height
           নিজে থেকেই সবচেয়ে লম্বা আইটেম অনুযায়ী রিজার্ভ করে রাখে — তাই কোনোভাবেই overlap হতে পারে না। */
        .variant-fields-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(105px, 1fr));
            gap: 12px 10px;
            margin-top: 2px;
        }
        .variant-fields-grid .vf-item .form-label {
            display: block;
            min-height: 2.3em; /* ছোট/লম্বা লেবেল যাই হোক, input বক্সগুলো একই লাইনে বসবে */
        }
        .variant-fields-grid .vf-add {
            display: flex;
            align-items: flex-end;
        }
        @media (max-width: 575.98px) {
            .variant-fields-grid {
                grid-template-columns: repeat(2, 1fr);
            }
            .variant-fields-grid .vf-add {
                grid-column: 1 / -1; /* ফোনে Add বাটন পুরো width জুড়ে */
            }
        }
    </style>

    <script type="text/javascript">
        // =====================================================================
        // PANEL (List / Form) SWITCHING — with state persisted in sessionStorage
        // =====================================================================
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

        // =====================================================================
        // RESTORE UI STATE (panel + scroll position) after ANY postback
        // (both full postback and UpdatePanel async postback)
        // =====================================================================
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

        // Continuously (debounced) remember the current scroll position
        var _woScrollSaveTimer = null;
        window.addEventListener('scroll', function () {
            if (_woScrollSaveTimer) { clearTimeout(_woScrollSaveTimer); }
            _woScrollSaveTimer = setTimeout(function () {
                try { sessionStorage.setItem('wo_scrollY', window.scrollY); } catch (e) { }
            }, 150);
        });

        // ★★★ CHANGED: আলাদা "Rate/Unit" ফিল্ড বাদ দেওয়া হয়েছে — এখন "Item Rate" (txtRate)
        // থেকেই ক্লায়েন্ট-সাইড প্রিভিউ ক্যালকুলেশন হবে।
        function calculateRowTotal() {
            var reqQty = parseFloat(document.getElementById('<%= txtReqQty.ClientID %>').value) || 0;
            var rateUnit = parseFloat(document.getElementById('<%= txtRate.ClientID %>').value) || 0;
            var extraPercent = parseFloat(document.getElementById('<%= txtExtraPercent.ClientID %>').value) || 0;

            var totalReqQty = reqQty + (reqQty * (extraPercent / 100));
            var totalAmount = totalReqQty * rateUnit;

            document.getElementById('<%= txtTotalReqQtyInput.ClientID %>').value = totalReqQty.toFixed(2);
            document.getElementById('<%= txtTotalAmountInput.ClientID %>').value = totalAmount.toFixed(2);
        }

        // Initialize Select2 + Autocomplete + restore UI state on first load
        $(document).ready(function () {
            initializeSelect2();
            initializeAutocompleteFields();
            restoreUIState();
        });

        // Initialize Select2 + Autocomplete + restore UI state for normal load AND
        // UpdatePanel partial postbacks (pageLoad is invoked by Microsoft Ajax after
        // EVERY postback when a ScriptManager is present)
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
            // বর্তমান রো (Row) টি খুঁজে বের করা
            var row = inputElement.closest('tr');

            // কন্ট্রোলগুলোর আইডি বা ক্লাস থেকে ইনপুট এবং লেবেলগুলো শনাক্ত করা
            var txtReqQty = row.querySelector("[id*='txtReqQty']");
            var txtRateUnit = row.querySelector("[id*='txtRateUnit']");
            var txtExtraPercent = row.querySelector("[id*='txtExtraPercent']");

            var lblTotalReqQty = row.querySelector("[id*='lblTotalReqQty']");
            var lblTotalAmount = row.querySelector("[id*='lblTotalAmount']");

            // মানগুলো সংখ্যায় রূপান্তর করা (খালি থাকলে ০ ধরে নেওয়া)
            var reqQty = parseFloat(txtReqQty.value) || 0;
            var rateUnit = parseFloat(txtRateUnit.value) || 0;
            var extraPercent = parseFloat(txtExtraPercent.value) || 0;

            // ক্যালকুলেশন: 
            // Total Req. Qty = ReqQty + (ReqQty * ExtraPercent / 100)
            var totalReqQty = reqQty + (reqQty * extraPercent / 100);

            // Total Amount = Total Req. Qty * RateUnit
            var totalAmount = totalReqQty * rateUnit;

            // ফলাফল লেবেলে বসানো (ডেসিমেল পয়েন্ট ২ ঘর পর্যন্ত ফিক্সড রাখা) — এটা শুধু
            // তাৎক্ষণিক ভিজ্যুয়াল প্রিভিউ; আসল সোর্স অফ ট্রুথ হলো সার্ভার-সাইড ক্যালকুলেশন
            // যেটা AutoPostBack (blur/TextChanged) এর মাধ্যমে txtSizeGridField_TextChanged এ হয়
            if (lblTotalReqQty) lblTotalReqQty.innerText = totalReqQty.toFixed(2);
            if (lblTotalAmount) lblTotalAmount.innerText = totalAmount.toFixed(2);
        }

        // =====================================================================
        // AUTOCOMPLETE (Buyer / Style / Order No) — calls ASP.NET PageMethods
        // (WebMethods defined in code-behind: GetBuyerSuggestions, GetStyleSuggestions,
        // GetOrderSuggestions). Requires ScriptManager1 EnablePageMethods="true".
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

            // একবার binding হয়ে গেলে দ্বিতীয়বার bind না হয়, তাই একটা data flag ব্যবহার করছি
            if ($input.data('ac-bound')) return;
            $input.data('ac-bound', true);

            $input.on('keyup', function (e) {
                // navigation keys (up/down/enter/escape) skip করে বাকি সব keystroke এ suggest করবে
                if ([13, 27, 38, 40].indexOf(e.keyCode) !== -1) return;

                var term = $input.val().trim();

                if (_acDebounceTimer) clearTimeout(_acDebounceTimer);

                if (term.length < 1) {
                    $list.removeClass('show').empty();
                    return;
                }

                _acDebounceTimer = setTimeout(function () {
                    fetchSuggestions(webMethodName, term, $list, $input);
                }, 250); // 250ms debounce — প্রতিটা কি-স্ট্রোকে সাথে সাথে সার্ভারে হিট করবে না
            });

            // Up/Down/Enter navigation
            $input.on('keydown', function (e) {
                var $items = $list.find('.ac-suggestion-item');
                if ($items.length === 0) return;

                var $active = $list.find('.ac-suggestion-item.active');
                var idx = $items.index($active);

                if (e.keyCode === 40) { // Down
                    e.preventDefault();
                    idx = (idx + 1) % $items.length;
                    $items.removeClass('active');
                    $items.eq(idx).addClass('active');
                } else if (e.keyCode === 38) { // Up
                    e.preventDefault();
                    idx = (idx <= 0) ? $items.length - 1 : idx - 1;
                    $items.removeClass('active');
                    $items.eq(idx).addClass('active');
                } else if (e.keyCode === 13) { // Enter
                    if ($active.length) {
                        e.preventDefault();
                        $input.val($active.text());
                        $list.removeClass('show').empty();
                    }
                } else if (e.keyCode === 27) { // Escape
                    $list.removeClass('show').empty();
                }
            });

            // বাইরে ক্লিক করলে suggestion বন্ধ হয়ে যাবে
            $(document).on('click', function (e) {
                if (!$(e.target).closest($input.parent()).length) {
                    $list.removeClass('show').empty();
                }
            });

            // Input থেকে focus চলে গেলেও একটু delay দিয়ে বন্ধ করা (item click কাজ করার জন্য)
            $input.on('blur', function () {
                setTimeout(function () { $list.removeClass('show').empty(); }, 150);
            });
        }

        function fetchSuggestions(webMethodName, term, $list, $input) {
            $.ajax({
                type: "POST",
                url: "WorkOrderReceive.aspx/" + webMethodName,
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
                    // mousedown ব্যবহার করা হয়েছে (click নয়), কারণ blur event mousedown এর
                    // আগেই ফায়ার হতে পারে — এতে click select কাজ করবে নিশ্চিতভাবে
                    e.preventDefault();
                    $input.val(val);
                    $list.removeClass('show').empty();
                });
                $list.append($li);
            });

            $list.addClass('show');
        }
    </script>

</head>
<body>
    <form id="form1" runat="server">
        <!-- ScriptManager for UpdatePanel + PageMethods (autocomplete এর জন্য EnablePageMethods="true" আবশ্যক) -->
        <asp:ScriptManager ID="ScriptManager1" runat="server" EnablePageMethods="true"></asp:ScriptManager>

        <div class="container my-4">

            <!-- ================= 1. LIST PANEL ================= -->
            <div id="pnlList" class="panel active">
                <div class="list-toolbar">
                    <div class="list-title">Work Order Receive List</div>
                    <button type="button" class="btn btn-success btn-sm" onclick="showPanel('pnlForm')">+ Add New Work Order</button>
                </div>

                <asp:GridView ID="gvWorkOrderReceive" runat="server" AutoGenerateColumns="False" CssClass="grid" ShowHeaderWhenEmpty="True" OnRowCommand="gvWorkOrderReceive_RowCommand">
                    <EmptyDataTemplate>
                        <div style="color: #777; padding: 12px; font-size: 12px; text-align: center;">
                            No records found in list
                        </div>
                    </EmptyDataTemplate>
                    <Columns>
                        <asp:TemplateField HeaderText="SL">
                            <ItemTemplate>
                                <%# Container.DataItemIndex + 1 %>
                            </ItemTemplate>
                            <ItemStyle Width="40px" />
                        </asp:TemplateField>

                        <asp:BoundField DataField="WORcvNo" HeaderText="WO Rcv No" ItemStyle-Width="15%" />

                        <asp:BoundField DataField="WORcvDate" HeaderText="WO Rcv Date" DataFormatString="{0:dd-MM-yyyy}" HtmlEncode="false" ItemStyle-Width="15%" />

                        <asp:BoundField DataField="DeliveryDate" HeaderText="Delivery Date" DataFormatString="{0:dd-MM-yyyy}" HtmlEncode="false" ItemStyle-Width="15%" />

                        <asp:BoundField DataField="GrandTotal" HeaderText="Total Value" DataFormatString="{0:N2}" HtmlEncode="false" ItemStyle-Width="15%" />

                        <asp:TemplateField HeaderText="Action" ItemStyle-Width="40%">
                            <ItemTemplate>
                                <div style="display: flex; gap: 5px; align-items: center;">
                                    <asp:LinkButton ID="lnkEdit" runat="server" Text="Edit" CommandName="EditRow" CommandArgument='<%# Eval("WORcvNo") %>'
                                        Style="background-color: #e3f2fd; color: #1976d2; padding: 4px 10px; border-radius: 4px; font-size: 12px; font-weight: 600; text-decoration: none; border: 1px solid #90caf9;" />

                                    <asp:LinkButton ID="lnkDelete" runat="server" Text="Delete" CommandName="DeleteRow" CommandArgument='<%# Eval("WORcvNo") %>'
                                        Style="background-color: #ffebee; color: #c62828; padding: 4px 10px; border-radius: 4px; font-size: 12px; font-weight: 600; text-decoration: none; border: 1px solid #ef9a9a;"
                                        OnClientClick="return confirm('Are you sure you want to delete this item?');" />

                                    <asp:LinkButton ID="lnkPrintView" runat="server" Text="WO Report" CommandName="ReportView" CommandArgument='<%# Eval("WORcvID") %>'
                                        Style="background-color: #e8f5e9; color: #2e7d32; padding: 4px 10px; border-radius: 4px; font-size: 12px; font-weight: 600; text-decoration: none; border: 1px solid #a5d6a7;" />

                                    <asp:LinkButton ID="lnkRawMatrial" runat="server" Text="Raw Material Report" CommandName="RawMatrialView" CommandArgument='<%# Eval("WORcvID") %>'
                                        Style="background-color: #e8f5e9; color: #2e7d32; padding: 4px 10px; border-radius: 4px; font-size: 12px; font-weight: 600; text-decoration: none; border: 1px solid #a5d6a7;" />
                                </div>
                            </ItemTemplate>
                            <ItemStyle Width="180px" />
                        </asp:TemplateField>
                    </Columns>
                </asp:GridView>
            </div>

            <!-- ================= 2. FORM PANEL ================= -->
            <div id="pnlForm" class="panel">
                <div class="card shadow-sm">
                    <div class="card-header card-header-custom text-center py-2 d-flex justify-content-between align-items-center">
                        <span>Work Order Input Form (ERP Module)</span>
                        <button type="button" class="btn btn-light btn-sm text-dark fw-bold" onclick="showPanel('pnlList')">← Back to List</button>
                    </div>
                    <div class="card-body p-4">

                        <!-- UpdatePanel for Partial Postbacks -->
                        <asp:UpdatePanel ID="updFormContent" runat="server">
                            <ContentTemplate>

                                <asp:HiddenField ID="hdnWorkOrderNo" runat="server" />
                                <asp:HiddenField ID="hdnSelectedColorSlNo" runat="server" />

                                <!-- ============ SECTION 1: HEADER INFORMATION ============ -->
                                <fieldset class="section-box">
                                    <legend>[Company PAD Common] - Header Info</legend>
                                    <div class="row g-3">
                                        <div class="col-md-3">
                                            <label class="form-label fw-bold">1. Customer Name</label>
                                            <asp:UpdatePanel ID="UpdatePanelCustomer" runat="server">
                                                <ContentTemplate>
                                                    <div class="d-flex">
                                                        <asp:DropDownList ID="ddlCustomerName" runat="server" CssClass="form-select form-select-sm searchable-dropdown">
                                                            <asp:ListItem Text="--Select Customer--" Value="0" />
                                                        </asp:DropDownList>

                                                        <asp:LinkButton ID="btnRefreshCustomer" runat="server" CssClass="btn refresh-icon-btn d-flex align-items-center justify-content-center" ToolTip="Refresh Customer List" OnClick="btnRefreshCustomer_Click">
                                                            <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="currentColor" class="bi bi-arrow-clockwise" viewBox="0 0 16 16">
                                                                <path fill-rule="evenodd" d="M8 3a5 5 0 1 0 4.546 2.914.5.5 0 0 1 .908-.417A6 6 0 1 1 8 2z"/><path d="M8 4.466V.534a.25.25 0 0 1 .41-.192l2.36 1.966c.12.1.12.284 0 .384L8.41 4.658A.25.25 0 0 1 8 4.466"/>
                                                            </svg>
                                                        </asp:LinkButton>
                                                    </div>
                                                </ContentTemplate>
                                            </asp:UpdatePanel>
                                        </div>
                                        <div class="col-md-3">
                                            <label class="form-label fw-bold">2. Work Order No.[Auto]</label>
                                            <asp:TextBox ID="txtWoRef" runat="server" CssClass="form-control form-control-sm" Text="WO-2026-0001" ReadOnly="true"></asp:TextBox>
                                        </div>
                                        <div class="col-md-3">
                                            <label class="form-label fw-bold">3. Work Order Date</label>
                                            <asp:TextBox ID="txtWoDate" runat="server" CssClass="form-control form-control-sm" TextMode="Date"></asp:TextBox>
                                        </div>
                                        <div class="col-md-3">
                                            <label class="form-label fw-bold">4. Delivery Date</label>
                                            <asp:TextBox ID="txtDeliveryDate" runat="server" CssClass="form-control form-control-sm" TextMode="Date"></asp:TextBox>
                                        </div>
                                    </div>
                                </fieldset>

                                <!-- ============ SECTION 2: WO DETAILS HEADER (Branch, Ref No, Quotation, Description) ============ -->
                                <!-- ★★★ CHANGED: Customer Buyer / Style / Order এই তিনটা ফিল্ড এখান থেকে সরিয়ে
                                     নিচের "Item, Color & Size-wise Variant Entry" সেকশনে নেওয়া হয়েছে। -->
                                <fieldset class="section-box">
                                    <legend>WO Details Header (Branch, Ref No. &amp; Quotation)</legend>
                                    <div class="row g-3">
                                        <div class="col-md-4">
                                            <label class="form-label fw-bold">5. Receiving Branch</label>
                                            <asp:DropDownList ID="ddlReceivingBranch" runat="server" CssClass="form-select form-select-sm searchable-dropdown">
                                                <asp:ListItem Text="--Select Receiving Branch--" Value="0" />
                                            </asp:DropDownList>
                                        </div>
                                        <div class="col-md-4">
                                            <label class="form-label fw-bold">Ref. Work Order No</label>
                                            <asp:TextBox ID="txtWoNoDetails" runat="server" CssClass="form-control form-control-sm" placeholder="e.g. WO-001"></asp:TextBox>
                                        </div>
                                        <div class="col-md-4">
                                            <label class="form-label fw-bold">Quotation No</label>
                                            <asp:TextBox ID="txtQuotationNo" runat="server" CssClass="form-control form-control-sm" placeholder="Enter Quotation No"></asp:TextBox>
                                        </div>
                                    </div>
                                </fieldset>

                                <!-- ============ SECTION 3: ITEM / COLOR / SIZE ENTRY & GRID ============ -->
                                <fieldset class="section-box">
                                    <legend>Item, Color &amp; Size-wise Variant Entry</legend>

                                    <!-- Entry Row 1: Buyer / Style / Order / Item / Color / Rate / Size / Qty / Unit / Extra% / Totals / Measurement / Remarks / Add -->
                                    <div class="row g-2 align-items-end entry-row">
                                        <div class="col-md-3">
                                            <label class="form-label small fw-bold">Customer Buyer</label>
                                            <div class="ac-wrapper">
                                                <asp:TextBox ID="txtBuyer" runat="server" CssClass="form-control form-control-sm" placeholder="Enter Buyer Name" autocomplete="off"></asp:TextBox>
                                                <ul id="lstBuyerSuggest" runat="server" class="ac-suggestion-list"></ul>
                                            </div>
                                        </div>
                                        <div class="col-md-3">
                                            <label class="form-label small fw-bold">Style</label>
                                            <div class="ac-wrapper">
                                                <asp:TextBox ID="txtStyle" runat="server" CssClass="form-control form-control-sm" placeholder="Enter Style No/Name" autocomplete="off"></asp:TextBox>
                                                <ul id="lstStyleSuggest" runat="server" class="ac-suggestion-list"></ul>
                                            </div>
                                        </div>
                                        <div class="col-md-3">
                                            <label class="form-label small fw-bold">Order</label>
                                            <div class="ac-wrapper">
                                                <asp:TextBox ID="txtOrderNo" runat="server" CssClass="form-control form-control-sm" placeholder="Enter Order No" autocomplete="off"></asp:TextBox>
                                                <ul id="lstOrderSuggest" runat="server" class="ac-suggestion-list"></ul>
                                            </div>
                                        </div>

                                        <div class="col-md-3">
                                            <asp:UpdatePanel ID="UpdatePanel1" runat="server">
                                                <ContentTemplate>
                                                    <label class="form-label small fw-bold">Item Name</label>
                                                    <div class="d-flex">
                                                        <asp:DropDownList ID="ddlItemNameDetails" runat="server" AutoPostBack="true" CssClass="form-select form-select-sm searchable-dropdown" OnSelectedIndexChanged="ddlItemNameDetails_SelectedIndexChanged">
                                                            <asp:ListItem Text="--Select Item--" Value="0" />
                                                        </asp:DropDownList>

                                                        <asp:LinkButton ID="Button1" runat="server" CssClass="btn refresh-icon-btn d-flex align-items-center justify-content-center" ToolTip="Refresh" OnClick="Button1_Click">
                                                            <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="currentColor" class="bi bi-arrow-clockwise" viewBox="0 0 16 16">
                                                                <path fill-rule="evenodd" d="M8 3a5 5 0 1 0 4.546 2.914.5.5 0 0 1 .908-.417A6 6 0 1 1 8 2z"/><path d="M8 4.466V.534a.25.25 0 0 1 .41-.192l2.36 1.966c.12.1.12.284 0 .384L8.41 4.658A.25.25 0 0 1 8 4.466"/>
                                                            </svg>
                                                        </asp:LinkButton>
                                                    </div>
                                                </ContentTemplate>
                                            </asp:UpdatePanel>
                                        </div>

                                        <div class="col-md-3">
                                            <label class="form-label fw-bold">Items Discription</label>
                                            <asp:TextBox ID="TextBox1" runat="server" CssClass="form-control form-control-sm" placeholder="Enter Items Description"></asp:TextBox>
                                        </div>

                                        <div class="col-md-3">
                                            <asp:UpdatePanel ID="UpdatePanel2" runat="server">
                                                <ContentTemplate>
                                                    <label class="form-label small fw-bold">Color Name</label>
                                                    <div class="d-flex">
                                                        <asp:DropDownList ID="DropDownList1" runat="server" CssClass="form-select form-select-sm searchable-dropdown">
                                                            <asp:ListItem Text="--Select Color--" Value="0" />
                                                        </asp:DropDownList>

                                                        <asp:LinkButton ID="LinkButton1" runat="server" CssClass="btn refresh-icon-btn d-flex align-items-center justify-content-center" ToolTip="Refresh" OnClick="LinkButton1_Click">
                                                            <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="currentColor" class="bi bi-arrow-clockwise" viewBox="0 0 16 16">
                                                                <path fill-rule="evenodd" d="M8 3a5 5 0 1 0 4.546 2.914.5.5 0 0 1 .908-.417A6 6 0 1 1 8 2z"/><path d="M8 4.466V.534a.25.25 0 0 1 .41-.192l2.36 1.966c.12.1.12.284 0 .384L8.41 4.658A.25.25 0 0 1 8 4.466"/>
                                                            </svg>
                                                        </asp:LinkButton>
                                                    </div>
                                                </ContentTemplate>
                                            </asp:UpdatePanel>
                                        </div>

                                        <div class="col-md-3">
                                            <label class="form-label small fw-bold">Item Rate</label>
                                            <asp:TextBox ID="txtRate" runat="server" CssClass="form-control form-control-sm" placeholder="Item Rate" onkeyup="calculateRowTotal()"></asp:TextBox>
                                        </div>
                                        <div class="col-md-3">
                                            <label class="form-label small fw-bold">Size</label>
                                            <asp:TextBox ID="txtSize" runat="server" CssClass="form-control form-control-sm" placeholder="e.g. S / 10x12"></asp:TextBox>
                                        </div>
                                        <div class="col-md-3">
                                            <label class="form-label small fw-bold">Req. Qty</label>
                                            <asp:TextBox ID="txtReqQty" runat="server" CssClass="form-control form-control-sm" Text="0" onkeyup="calculateRowTotal()"></asp:TextBox>
                                        </div>
                                        <div class="col-md-3">
                                            <label class="form-label small fw-bold">Unit</label>
                                            <asp:DropDownList ID="ddlUnit" runat="server" CssClass="form-select form-select-sm searchable-dropdown">
                                            </asp:DropDownList>
                                        </div>
                                        <div class="col-md-3">
                                            <label class="form-label small fw-bold">Extra %</label>
                                            <asp:TextBox ID="txtExtraPercent" runat="server" CssClass="form-control form-control-sm" Text="0" onkeyup="calculateRowTotal()"></asp:TextBox>
                                        </div>
                                        <div class="col-md-3">
                                            <label class="form-label small fw-bold">Total Req. Qty</label>
                                            <asp:TextBox ID="txtTotalReqQtyInput" runat="server" CssClass="form-control form-control-sm" Text="0.00" ReadOnly="true"></asp:TextBox>
                                        </div>
                                        <div class="col-md-3">
                                            <label class="form-label small fw-bold">Total Amount</label>
                                            <asp:TextBox ID="txtTotalAmountInput" runat="server" CssClass="form-control form-control-sm" Text="0.00" ReadOnly="true"></asp:TextBox>
                                        </div>
                                        <div class="col-md-3">
                                            <label class="form-label small fw-bold">Measurement</label>
                                            <asp:TextBox ID="txtMeasurement" runat="server" CssClass="form-control form-control-sm" placeholder="Measurement"></asp:TextBox>
                                        </div>
                                        <div class="col-md-3">
                                            <label class="form-label small fw-bold">Item Spec / Remarks</label>
                                            <asp:TextBox ID="txtSizeRemarks" runat="server" CssClass="form-control form-control-sm" placeholder="Remarks"></asp:TextBox>
                                        </div>
                                        <div class="col-md-2">
                                            <asp:Button ID="btnAddSize" runat="server" CssClass="btn add-variant-btn btn-sm w-100 text-white" Text="+ Add" OnClick="btnAddSize_Click" />
                                        </div>
                                    </div>

                                    <!-- Entry Row 2: Size Group Bulk Add -->
                                    <div class="row g-2 align-items-end entry-row">
                                        <div class="col-md-3">
                                            <label class="form-label small fw-bold">Size Group</label>
                                            <asp:DropDownList ID="ddlsizeGroup" runat="server" CssClass="form-select form-select-sm searchable-dropdown">
                                                <asp:ListItem Text="--Select size--" Value="0" />
                                            </asp:DropDownList>
                                        </div>
                                        <div class="col-md-2">
                                            <asp:Button ID="btnAddAllsize" runat="server" CssClass="btn btn-success btn-sm w-100" Text="Add All Size" OnClick="btnAddAllsize_Click" />
                                        </div>
                                    </div>

                                    <!-- Data Table: Size Variants -->
                                    <div class="variant-grid-title">
                                        <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="currentColor" viewBox="0 0 16 16"><path d="M0 2a2 2 0 0 1 2-2h12a2 2 0 0 1 2 2v12a2 2 0 0 1-2 2H2a2 2 0 0 1-2-2zm15 2H1v9a1 1 0 0 0 1 1h12a1 1 0 0 0 1-1zM1 3h14V2a1 1 0 0 0-1-1H2a1 1 0 0 0-1 1z"/></svg>
                                        Added Item / Color / Size List
                                    </div>
                                    <div class="table-responsive mt-2">
                                        <asp:GridView ID="gvSizeDetails" runat="server" CssClass="table table-bordered table-striped table-sm text-center align-middle" AutoGenerateColumns="False" DataKeyNames="SlNo" EmptyDataText="No size variant added yet." OnRowCommand="gvSizeDetails_RowCommand">
                                            <HeaderStyle CssClass="table-dark-custom" />
                                            <Columns>
                                                <asp:BoundField DataField="SlNo" HeaderText="Sl No" />
                                                <asp:BoundField DataField="ItemName" HeaderText="Item Name" />
                                                <asp:BoundField DataField="Buyer" HeaderText="Buyer Name" />
                                                <asp:BoundField DataField="Style" HeaderText="Style Name" />
                                                <asp:BoundField DataField="PO" HeaderText="PO Name" />
                                                <asp:BoundField DataField="ColorName" HeaderText="Color" />
                                                <asp:BoundField DataField="Size" HeaderText="Size" />

                                                <asp:TemplateField HeaderText="Measurement">
                                                    <ItemTemplate>
                                                        <asp:TextBox ID="txtMeasurement" runat="server" CssClass="form-control form-control-sm text-center" Text='<%# Eval("Measurement") %>'></asp:TextBox>
                                                    </ItemTemplate>
                                                </asp:TemplateField>
                                                <asp:TemplateField HeaderText="Required Qty">
                                                    <ItemTemplate>
                                                        <asp:TextBox ID="txtReqQty" runat="server" CssClass="form-control form-control-sm text-center"
                                                            Text='<%# Eval("ReqQty") %>' AutoPostBack="true" OnTextChanged="txtSizeGridField_TextChanged"
                                                            onkeyup="calculateRow(this);" onchange="calculateRow(this);"></asp:TextBox>
                                                    </ItemTemplate>
                                                </asp:TemplateField>

                                                <asp:TemplateField HeaderText="Unit">
                                                    <ItemTemplate>
                                                        <asp:TextBox ID="txtUnit" runat="server" CssClass="form-control form-control-sm text-center" Text='<%# Eval("Unit") %>'></asp:TextBox>
                                                    </ItemTemplate>
                                                </asp:TemplateField>

                                                <asp:TemplateField HeaderText="Rate/Unit">
                                                    <ItemTemplate>
                                                        <asp:TextBox ID="txtRateUnit" runat="server" CssClass="form-control form-control-sm text-center"
                                                            Text='<%# Eval("RateUnit") %>' AutoPostBack="true" OnTextChanged="txtSizeGridField_TextChanged"
                                                            onkeyup="calculateRow(this);" onchange="calculateRow(this);"></asp:TextBox>
                                                    </ItemTemplate>
                                                </asp:TemplateField>

                                                <asp:TemplateField HeaderText="Extra %">
                                                    <ItemTemplate>
                                                        <asp:TextBox ID="txtExtraPercent" runat="server" CssClass="form-control form-control-sm text-center"
                                                            Text='<%# Eval("ExtraPercent") %>' AutoPostBack="true" OnTextChanged="txtSizeGridField_TextChanged"
                                                            onkeyup="calculateRow(this);" onchange="calculateRow(this);"></asp:TextBox>
                                                    </ItemTemplate>
                                                </asp:TemplateField>

                                                <asp:TemplateField HeaderText="Total Req. Qty">
                                                    <ItemTemplate>
                                                        <asp:Label ID="lblTotalReqQty" runat="server" Text='<%# Eval("TotalReqQty") %>' CssClass="fw-bold text-success"></asp:Label>
                                                    </ItemTemplate>
                                                </asp:TemplateField>

                                                <asp:TemplateField HeaderText="Total Amount">
                                                    <ItemTemplate>
                                                        <asp:Label ID="lblTotalAmount" runat="server" Text='<%# Eval("TotalAmount") %>' CssClass="fw-bold text-primary"></asp:Label>
                                                    </ItemTemplate>
                                                </asp:TemplateField>

                                                <asp:TemplateField HeaderText="Item Specification/Remarks">
                                                    <ItemTemplate>
                                                        <asp:TextBox ID="txtRemarks" runat="server" CssClass="form-control form-control-sm text-center" Text='<%# Eval("Remarks") %>'></asp:TextBox>
                                                    </ItemTemplate>
                                                </asp:TemplateField>

                                                <asp:TemplateField HeaderText="Action">
                                                    <ItemTemplate>
                                                        <asp:Button ID="btnUpdateSize" runat="server" CssClass="btn btn-warning btn-sm px-2 py-0"
                                                            Text="Update" CommandName="UpdateSize" CommandArgument='<%# Eval("SlNo") %>' CausesValidation="false" />
                                                        <asp:Button ID="btnEditSize" runat="server" CssClass="btn btn-primary btn-sm px-2 py-0"
                                                            Text="Edit" CommandName="EditSize" CommandArgument='<%# Eval("SlNo") %>' CausesValidation="false" />
                                                        <asp:Button ID="btnDeleteSize" runat="server" CssClass="btn btn-danger btn-sm px-2 py-0"
                                                            Text="X" CommandName="DeleteSize" CommandArgument='<%# Eval("SlNo") %>' CausesValidation="false" />
                                                    </ItemTemplate>
                                                </asp:TemplateField>
                                            </Columns>
                                        </asp:GridView>
                                    </div>

                                    <!-- Running Total -->
                                    <div class="row justify-content-end mt-3">
                                        <div class="col-md-4">
                                            <div class="input-group input-group-sm summary-box">
                                                <span class="input-group-text fw-bold w-50">Items Total Amount</span>
                                                <asp:TextBox ID="txtColorTotalAmount" runat="server" CssClass="form-control text-end" Text="0.00" ReadOnly="true"></asp:TextBox>
                                            </div>
                                        </div>
                                    </div>
                                </fieldset>

                                <!-- ============ SECTION 4: OTHER COSTS & GRAND TOTAL ============ -->
                                <fieldset class="section-box">
                                    <legend>Other Costs &amp; Grand Total Summary</legend>
                                    <div class="row justify-content-end">
                                        <div class="col-md-4 summary-box">
                                            <div class="input-group input-group-sm mb-2">
                                                <span class="input-group-text fw-bold w-50">Sub Total Amount</span>
                                                <asp:TextBox ID="txtSubTotalAmount" runat="server" CssClass="form-control text-end" Text="0.00" ReadOnly="true"></asp:TextBox>
                                            </div>
                                            <div class="input-group input-group-sm mb-2">
                                                <span class="input-group-text fw-bold w-50">Transport / Carrying Cost</span>
                                                <asp:TextBox ID="txtTransportCost" runat="server" CssClass="form-control text-end"
                                                    Text="0.00" AutoPostBack="true" OnTextChanged="txtTransportCost_TextChanged"></asp:TextBox>
                                            </div>
                                            <div class="input-group input-group-sm mb-2">
                                                <span class="input-group-text fw-bold w-50">VAT / Tax (%)</span>
                                                <asp:TextBox ID="txtVatPercent" runat="server" CssClass="form-control text-end"
                                                    Text="0.00" AutoPostBack="true" OnTextChanged="txtVatPercent_TextChanged"></asp:TextBox>
                                            </div>
                                            <div class="input-group input-group-sm">
                                                <span class="input-group-text fw-bold w-50 grand-total">Grand Total Amount</span>
                                                <asp:TextBox ID="txtGrandTotalAmount" runat="server" CssClass="form-control text-end fw-bold" Text="0.00" ReadOnly="true"></asp:TextBox>
                                            </div>
                                        </div>
                                    </div>
                                </fieldset>

                            </ContentTemplate>
                        </asp:UpdatePanel>

                        <!-- Bottom Action Buttons -->
                        <div class="d-flex gap-2 form-footer-actions">
                            <asp:Button ID="btnSave" runat="server" CssClass="btn btn-success px-4" Text="Save &amp; Print Work Order" OnClick="btnSave_Click" />
                            <asp:Button ID="btnCancel" runat="server" CssClass="btn btn-secondary px-4" Text="Cancel" OnClick="btnCancel_Click" />
                            <button type="button" class="btn btn-info px-4 text-white" onclick="showPanel('pnlList')">Back to List</button>
                        </div>

                    </div>
                </div>
            </div>

        </div>
    </form>
</body>
</html>
