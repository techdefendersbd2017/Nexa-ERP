<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="WorkOrderReceiveByQuotation.aspx.cs" Inherits="Nexa_ERP.TrimsAccessories.EstimationCostings.WorkOrderReceiveByQuotation" %>


<!DOCTYPE html>
<html>
<head runat="server">
    <title>Work Order Receive - Master Details</title>
    <style>
        :root{
            --brand-900:#0f3352;
            --brand-800:#123a5c;
            --brand-700:#1f4e78;
            --brand-100:#e7eef5;
            --ink:#1e293b;
            --muted:#64748b;
            --line:#dbe2ea;
            --bg:#eef1f5;
            --card:#ffffff;
            --ok:#2e7d32;
            --ok-dark:#256428;
            --danger:#c62828;
            --danger-dark:#a92222;
            --neutral:#455163;
            --neutral-dark:#37404d;
            --info:#0277bd;
            --info-dark:#02669f;
            --radius:8px;
            --radius-sm:5px;
            --shadow:0 1px 2px rgba(15,51,82,.06), 0 4px 14px rgba(15,51,82,.06);
        }

        *{ box-sizing:border-box; }

        body{
            font-family:"Segoe UI", Arial, sans-serif;
            font-size:13px;
            color:var(--ink);
            background:var(--bg);
            margin:0;
            padding:24px 16px;
        }

        .container{
            background:var(--card);
            padding:0;
            border:1px solid var(--line);
            border-radius:var(--radius);
            max-width:1200px;
            margin:auto;
            box-shadow:var(--shadow);
            overflow:hidden;
        }

        .header-title{
            background:linear-gradient(135deg, var(--brand-900), var(--brand-700));
            color:#fff;
            text-align:left;
            padding:16px 22px;
            font-weight:600;
            font-size:16px;
            letter-spacing:.2px;
        }

        .body-pad{ padding:20px 22px 24px; }

        /* Panel Controls */
        .panel{ display:none; }
        .panel.active{ display:block; }

        /* Tab Navigation Styling */
        .tab-headers{
            display:flex;
            gap:4px;
            border-bottom:2px solid var(--brand-700);
            margin-bottom:20px;
        }
        .tab-btn{
            background:var(--brand-100);
            border:1px solid var(--line);
            border-bottom:none;
            padding:10px 20px;
            font-weight:600;
            cursor:pointer;
            font-size:13px;
            color:var(--muted);
            border-top-left-radius:6px;
            border-top-right-radius:6px;
            transition:background .15s ease, color .15s ease;
        }
        .tab-btn:hover{ background:#dce7f2; }
        .tab-btn.active{
            background:var(--brand-700);
            color:#fff;
            border-color:var(--brand-700);
        }

        .tab-content{ display:none; }
        .tab-content.active{ display:block; animation:fadeIn .15s ease; }

        @keyframes fadeIn{
            from{ opacity:0; transform:translateY(2px); }
            to{ opacity:1; transform:translateY(0); }
        }

        /* Section headings inside tabs */
        .section-label{
            font-weight:700;
            color:var(--brand-700);
            text-transform:uppercase;
            letter-spacing:.4px;
            font-size:11.5px;
            border-bottom:2px solid var(--brand-700);
            padding-bottom:6px;
            margin-bottom:14px;
        }

        /* Form Grid Layout (replaces the old form-table for field rows) */
        .form-grid{
            display:grid;
            grid-template-columns:repeat(3, 1fr);
            gap:14px 22px;
            margin-bottom:18px;
        }
        .form-grid.cols-2{ grid-template-columns:repeat(2, 1fr); }
        .form-grid.cols-4{ grid-template-columns:repeat(4, 1fr); }
        .field{ display:flex; flex-direction:column; gap:5px; }
        .field.span-2{ grid-column:span 2; }
        .field.span-3{ grid-column:span 3; }
        .field label{
            font-weight:600;
            font-size:12px;
            color:var(--muted);
        }

        .form-control{
            padding:8px 10px;
            border:1px solid #cbd5e1;
            border-radius:var(--radius-sm);
            font-size:13px;
            width:100%;
            background:#fff;
            color:var(--ink);
            transition:border-color .15s ease, box-shadow .15s ease;
        }
        .form-control:focus{
            outline:none;
            border-color:var(--brand-700);
            box-shadow:0 0 0 3px rgba(31,78,120,.12);
        }
        textarea.form-control{ resize:vertical; min-height:60px; font-family:inherit; }

        /* Searchable dropdown (combo box) */
        .search-select{
            position:relative;
        }
        .search-select .search-select-input{
            cursor:text;
            background-image:url("data:image/svg+xml;utf8,<svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 24 24' fill='none' stroke='%2364748b' stroke-width='2'><circle cx='11' cy='11' r='7'/><line x1='21' y1='21' x2='16.65' y2='16.65'/></svg>");
            background-repeat:no-repeat;
            background-position:right 10px center;
            background-size:15px 15px;
            padding-right:32px;
        }
        .search-select-dropdown{
            display:none;
            position:absolute;
            top:calc(100% + 4px);
            left:0;
            right:0;
            background:#fff;
            border:1px solid #cbd5e1;
            border-radius:var(--radius-sm);
            box-shadow:0 6px 18px rgba(15,51,82,.14);
            max-height:220px;
            overflow-y:auto;
            z-index:50;
        }
        .search-select-dropdown.open{ display:block; }
        .search-select-option{
            padding:8px 10px;
            font-size:12.5px;
            cursor:pointer;
            color:var(--ink);
        }
        .search-select-option:hover,
        .search-select-option.highlighted{
            background:var(--brand-100);
        }
        .search-select-option.selected{
            font-weight:600;
            color:var(--brand-700);
        }
        .search-select-empty{
            padding:8px 10px;
            font-size:12.5px;
            color:var(--muted);
            font-style:italic;
        }

        /* Legacy compatibility: keep old .form-table/.lbl/.val selectors working
           for any markup left in table form, but restyle to match new system */
        .form-table{ width:100%; border-collapse:collapse; margin-bottom:10px; }
        .form-table td{ padding:7px 8px; vertical-align:middle; }
        .lbl{ text-align:right; font-weight:600; width:150px; white-space:nowrap; color:var(--muted); font-size:12px; }
        .val{ text-align:left; }

        /* Inline filter / search bar above a grid */
        .filter-panel{
            background:#f8fafc;
            border:1px solid var(--line);
            border-radius:var(--radius-sm);
            padding:14px 16px 6px;
            margin-bottom:16px;
        }

        /* Grid / GridView styling */
        table.grid, .grid{
            width:100%;
            border-collapse:collapse;
            margin-top:10px;
            border-radius:var(--radius-sm);
            overflow:hidden;
        }
        table.grid th, table.grid td, .grid th, .grid td{
            border:1px solid var(--line);
            padding:9px 8px;
            text-align:center;
            font-size:12.5px;
        }
        table.grid th, .grid th{
            background:var(--brand-700);
            color:#fff;
            font-size:12.5px;
            font-weight:600;
            text-transform:uppercase;
            letter-spacing:.3px;
        }
        table.grid tr:nth-child(even) td,
        .grid tr:nth-child(even) td{ background:#f8fafc; }
        table.grid tr:hover td,
        .grid tr:hover td{ background:var(--brand-100); }

        /* Row visually dimmed when the user unchecks "Include" for it */
        table.grid tr.row-excluded td, .grid tr.row-excluded td{
            opacity:.45;
        }

        .totals-section{
            width:340px;
            max-width:100%;
            float:right;
            margin-top:16px;
            background:#f8fafc;
            border:1px solid var(--line);
            border-radius:var(--radius-sm);
            padding:6px 14px;
        }
        .totals-row td{ padding:6px 4px; }
        .totals-row .val .form-control{ text-align:right; }
        .totals-row.grand-total{ border-top:1px solid var(--line); }
        .totals-row.grand-total .lbl,
        .totals-row.grand-total .val{ padding-top:10px; }

        /* Buttons */
        .btn{
            padding:8px 18px;
            border:none;
            border-radius:var(--radius-sm);
            color:#fff;
            font-weight:600;
            cursor:pointer;
            font-size:13px;
            transition:filter .15s ease, transform .05s ease;
        }
        .btn:hover{ filter:brightness(1.08); }
        .btn:active{ transform:translateY(1px); }

        .btn-save{ background:var(--ok); }
        .btn-save:hover{ background:var(--ok-dark); }
        .btn-cancel{ background:var(--neutral); }
        .btn-cancel:hover{ background:var(--neutral-dark); }
        .btn-delete{ background:var(--danger); }
        .btn-delete:hover{ background:var(--danger-dark); }
        .btn-back{ background:var(--info); }
        .btn-back:hover{ background:var(--info-dark); }
        .btn-new{ background:var(--ok); margin-bottom:0; font-size:13px; padding:9px 18px; }
        .btn-next, .btn-prev{ background:var(--brand-700); padding:8px 18px; font-size:13px; }
        .btn-next:hover, .btn-prev:hover{ background:var(--brand-800); }
        .btn-add{ background:var(--ok); padding:7px 14px; font-size:13px; }
        .btn-clear{ background:var(--danger); padding:7px 14px; font-size:13px; }
        .btn-search{ background:var(--brand-700); padding:9px 14px; font-size:13px; width:100%; }
        .btn-search:hover{ background:var(--brand-800); }

        .clearfix::after{ content:""; clear:both; display:table; }

        .nav-buttons{
            margin-top:20px;
            display:flex;
            justify-content:space-between;
            align-items:center;
        }

        .list-toolbar{
            display:flex;
            justify-content:space-between;
            align-items:center;
            margin-bottom:14px;
        }
        .list-title{ font-weight:700; color:var(--brand-700); font-size:14.5px; }

        .action-bar{
            margin-top:22px;
            border-top:1px solid var(--line);
            padding-top:16px;
            display:flex;
            gap:10px;
        }

        @media (max-width:900px){
            .form-grid{ grid-template-columns:repeat(2,1fr); }
            .form-grid.cols-4{ grid-template-columns:repeat(2,1fr); }
            .totals-section{ float:none; width:100%; }
        }
        @media (max-width:600px){
            .form-grid{ grid-template-columns:1fr; }
            .form-grid.cols-4{ grid-template-columns:1fr; }
            .field.span-2, .field.span-3{ grid-column:span 1; }
            .tab-headers{ flex-wrap:wrap; }
        }
    </style>
    <script type="text/javascript">
        function showPanel(panelId, skipStateSave) {
            document.getElementById("pnlList").classList.remove("active");
            document.getElementById("pnlForm").classList.remove("active");
            if (!skipStateSave) {
                var hdn = document.getElementById("<%= hdnActivePanel.ClientID %>");
                if (hdn) hdn.value = panelId;
            }
            document.getElementById(panelId).classList.add("active");
        }

        function openTab(evt, tabName, skipStateSave) {
            var i, tabcontent, tablinks;
            tabcontent = document.getElementsByClassName("tab-content");
            for (i = 0; i < tabcontent.length; i++) {
                tabcontent[i].classList.remove("active");
            }
            tablinks = document.getElementsByClassName("tab-btn");
            for (i = 0; i < tablinks.length; i++) {
                tablinks[i].classList.remove("active");
            }
            document.getElementById(tabName).classList.add("active");
            if (evt && evt.currentTarget) evt.currentTarget.classList.add("active");
            if (!skipStateSave) {
                var hdn = document.getElementById("<%= hdnActiveTab.ClientID %>");
                if (hdn) hdn.value = tabName;
            }
        }

        /* Restore which panel/tab was open before this postback happened.
           Any postback (e.g. a dropdown with AutoPostBack, like Customer
           or Quotation No) reloads the whole page from the server, which
           would otherwise always land back on the List panel / first tab. */
        function restorePanelTabState() {
            var hdnPanel = document.getElementById("<%= hdnActivePanel.ClientID %>");
            var hdnTab = document.getElementById("<%= hdnActiveTab.ClientID %>");
            var panelId = hdnPanel && hdnPanel.value ? hdnPanel.value : "pnlList";
            var tabName = hdnTab && hdnTab.value ? hdnTab.value : "tabMasterInfo";

            showPanel(panelId, true);

            if (panelId === "pnlForm") {
                var tabIndex = { tabMasterInfo: 0, tabPaymentInfo: 1, tabOrderInfo: 2 }[tabName] || 0;
                var tabButtons = document.querySelectorAll(".tab-headers .tab-btn");
                tabButtons.forEach(function (btn) { btn.classList.remove("active"); });
                if (tabButtons[tabIndex]) tabButtons[tabIndex].classList.add("active");
                openTab({ currentTarget: tabButtons[tabIndex] }, tabName, true);
            }
        }

        /* ============ Searchable Dropdown (Combo Box) ============
           Wraps any <select> marked with class "search-select-source":
           - Reads its <option> list
           - Shows a text input + filterable list on top of it
           - Keeps the real <select> in sync (hidden) so postback / server
             code behind that reads SelectedValue keeps working unchanged
        */
        function initSearchSelects(root) {
            var scope = root || document;
            var selects = scope.querySelectorAll("select.search-select-source");

            selects.forEach(function (select) {
                if (select.dataset.searchSelectInit === "1") return;
                select.dataset.searchSelectInit = "1";
                select.style.display = "none";

                var wrapper = document.createElement("div");
                wrapper.className = "search-select";

                var input = document.createElement("input");
                input.type = "text";
                input.className = "form-control search-select-input";
                input.autocomplete = "off";
                input.placeholder = select.dataset.placeholder || "Search...";

                var panel = document.createElement("div");
                panel.className = "search-select-dropdown";

                select.parentNode.insertBefore(wrapper, select);
                wrapper.appendChild(input);
                wrapper.appendChild(panel);
                wrapper.appendChild(select);

                var options = Array.prototype.map.call(select.options, function (opt) {
                    return { value: opt.value, text: opt.text };
                });

                var highlightedIndex = -1;

                function setInputFromSelect() {
                    var opt = select.options[select.selectedIndex];
                    input.value = opt ? opt.text : "";
                }

                function renderList(filterText) {
                    panel.innerHTML = "";
                    highlightedIndex = -1;
                    var term = (filterText || "").trim().toLowerCase();
                    var matches = options.filter(function (o) {
                        return o.text.toLowerCase().indexOf(term) !== -1;
                    });

                    if (matches.length === 0) {
                        var empty = document.createElement("div");
                        empty.className = "search-select-empty";
                        empty.textContent = "No matching results";
                        panel.appendChild(empty);
                        return;
                    }

                    matches.forEach(function (o) {
                        var item = document.createElement("div");
                        item.className = "search-select-option";
                        if (o.value === select.value) item.classList.add("selected");
                        item.textContent = o.text;
                        item.dataset.value = o.value;
                        item.addEventListener("mousedown", function (e) {
                            e.preventDefault();
                            select.value = o.value;
                            input.value = o.text;
                            closePanel();
                            var evt = document.createEvent("HTMLEvents");
                            evt.initEvent("change", true, false);
                            select.dispatchEvent(evt);
                        });
                        panel.appendChild(item);
                    });
                }

                function openPanel() {
                    renderList(input.value === (select.options[select.selectedIndex] ? select.options[select.selectedIndex].text : "") ? "" : input.value);
                    panel.classList.add("open");
                }

                function closePanel() {
                    panel.classList.remove("open");
                }

                function moveHighlight(delta) {
                    var items = panel.querySelectorAll(".search-select-option");
                    if (!items.length) return;
                    if (highlightedIndex >= 0) items[highlightedIndex].classList.remove("highlighted");
                    highlightedIndex += delta;
                    if (highlightedIndex < 0) highlightedIndex = items.length - 1;
                    if (highlightedIndex >= items.length) highlightedIndex = 0;
                    items[highlightedIndex].classList.add("highlighted");
                    items[highlightedIndex].scrollIntoView({ block: "nearest" });
                }

                input.addEventListener("focus", openPanel);
                input.addEventListener("click", openPanel);
                input.addEventListener("input", function () {
                    renderList(input.value);
                    panel.classList.add("open");
                });
                input.addEventListener("keydown", function (e) {
                    if (e.key === "ArrowDown") { e.preventDefault(); openPanel(); moveHighlight(1); }
                    else if (e.key === "ArrowUp") { e.preventDefault(); openPanel(); moveHighlight(-1); }
                    else if (e.key === "Enter") {
                        e.preventDefault();
                        var items = panel.querySelectorAll(".search-select-option");
                        if (highlightedIndex >= 0 && items[highlightedIndex]) {
                            items[highlightedIndex].dispatchEvent(new Event("mousedown"));
                        }
                    } else if (e.key === "Escape") {
                        closePanel();
                        setInputFromSelect();
                    }
                });
                input.addEventListener("blur", function () {
                    setTimeout(function () {
                        closePanel();
                        setInputFromSelect();
                    }, 120);
                });

                setInputFromSelect();
            });
        }

        /* ============ Recalculate one row's Amount when Order Qty changes ============
           Amount = Rate (aggregated cost to make 1 unit of this item, summed from
           tbl_PriceQuotationDetails) x Order Qty entered by the user.
        */
        function calculateItemAmount(qtyInput) {
            var row = qtyInput.closest("tr");
            if (!row) return;

            var rateField = row.querySelector("input[id*='hdnRate']");
            var amountLabel = row.querySelector(".lblAmount");

            var orderQtyPcs = parseFloat(qtyInput.value) || 0;
            var rate = rateField ? (parseFloat(rateField.value) || 0) : 0;

            var amount = rate * orderQtyPcs;

            if (amountLabel) amountLabel.textContent = amount.toFixed(2);

            recalcGrandTotal();
        }

        /* Toggle a row's "included in this Work Order" state (dim it out visually
           when unchecked; excluded rows are skipped when the total is recalculated) */
        function toggleItemInclude(checkbox) {
            var row = checkbox.closest("tr");
            if (!row) return;
            row.classList.toggle("row-excluded", !checkbox.checked);
            recalcGrandTotal();
        }

        /* Recomputes Grand Total Value = sum of all INCLUDED item Amount labels in gvQuotationItems */
        function recalcGrandTotal() {
            var rows = document.querySelectorAll("#<%= gvQuotationItems.ClientID %> tbody tr");
            var itemsTotal = 0;
            rows.forEach(function (row) {
                var chk = row.querySelector(".chkIncludeItem");
                if (chk && !chk.checked) return; // skip excluded items
                var lbl = row.querySelector(".lblAmount");
                if (lbl) itemsTotal += parseFloat(lbl.textContent) || 0;
            });

            document.getElementById("<%= txtGTotal.ClientID %>").value = itemsTotal.toFixed(2);
        }

        document.addEventListener("DOMContentLoaded", function () {
            restorePanelTabState();
            initSearchSelects(document);
            document.addEventListener("click", function (e) {
                if (!e.target.closest(".search-select")) {
                    document.querySelectorAll(".search-select-dropdown.open").forEach(function (p) {
                        p.classList.remove("open");
                    });
                }
            });
        });
    </script>
</head>
<body>
    <form id="form1" runat="server">
        <asp:HiddenField ID="hdnActivePanel" runat="server" Value="pnlList" />
        <asp:HiddenField ID="hdnActiveTab" runat="server" Value="tabMasterInfo" />
        <div class="container active">
            <div class="header-title">Work Order Receive</div>
            <div class="body-pad">

            <!-- ================= 1. LIST PANEL ================= -->
            <div id="pnlList" class="panel active">
                <div class="list-toolbar">
                    <div class="list-title">Work Order Receive List</div>
                    <button type="button" class="btn btn-new" onclick="showPanel('pnlForm')">+ Add New Work Order</button>
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
                        <asp:BoundField DataField="WORcvNo" HeaderText="WO Rcv No" />
                        <asp:BoundField DataField="WORcvDate" HeaderText="WO Rcv Date" DataFormatString="{0:dd-MM-yyyy}" />
                        <asp:BoundField DataField="DeliveryDate" HeaderText="Delivery Date" DataFormatString="{0:dd-MM-yyyy}" />
                        <asp:BoundField DataField="GrandTotal" HeaderText="Total Value" />
                        <asp:TemplateField HeaderText="Action">
                            <ItemTemplate>
                                <div style="display: flex; gap: 5px; align-items: center;">
                                    <!-- Edit Button -->
                                    <asp:LinkButton ID="lnkEdit" runat="server" Text="Edit" CommandName="EditRow" CommandArgument='<%# Eval("WORcvNo") %>' 
                                        Style="background-color: #e3f2fd; color: #1976d2; padding: 4px 10px; border-radius: 4px; font-size: 12px; font-weight: 600; text-decoration: none; border: 1px solid #90caf9;" />
            
                                    <!-- Delete Button -->
                                    <asp:LinkButton ID="lnkDelete" runat="server" Text="Delete" CommandName="DeleteRow" CommandArgument='<%# Eval("WORcvNo") %>' 
                                        Style="background-color: #ffebee; color: #c62828; padding: 4px 10px; border-radius: 4px; font-size: 12px; font-weight: 600; text-decoration: none; border: 1px solid #ef9a9a;" 
                                        OnClientClick="return confirm('Are you sure you want to delete this item?');" />
            
                                    <!-- Report View Button -->
                                    <asp:LinkButton ID="lnkPrintView" runat="server" Text="Report" CommandName="ReportView" CommandArgument='<%# Eval("WORcvID") %>' 
                                        Style="background-color: #e8f5e9; color: #2e7d32; padding: 4px 10px; border-radius: 4px; font-size: 12px; font-weight: 600; text-decoration: none; border: 1px solid #a5d6a7;" />
                                </div>
                            </ItemTemplate>
                            <ItemStyle Width="180px" />
                        </asp:TemplateField>
                    </Columns>
                </asp:GridView>
            </div>

            <!-- ================= 2. FORM PANEL (3 Tabs) ================= -->
            <div id="pnlForm" class="panel">
                <div class="tab-headers">
                    <button type="button" class="tab-btn active" onclick="openTab(event, 'tabMasterInfo')">1. Master Info</button>
                    <button type="button" class="tab-btn" onclick="openTab(event, 'tabPaymentInfo')">2. Payment Information</button>
                    <button type="button" class="tab-btn" onclick="openTab(event, 'tabOrderInfo')">3. Order Information</button>
                </div>

                <!-- TAB 1: Master Info -->
                <div id="tabMasterInfo" class="tab-content active">

                    <div class="section-label">Work Order Details</div>
                    <div class="form-grid">
                        <div class="field">
                            <label for="<%= ddlReceiveBranch.ClientID %>">Receive Branch</label>
                            <asp:DropDownList ID="ddlReceiveBranch" runat="server" CssClass="form-control">
                                <asp:ListItem Text="--Select--" Value="" />
                            </asp:DropDownList>
                        </div>
                        <div class="field">
                            <label for="<%= txtWORcvNo.ClientID %>">Work Order Receive No</label>
                            <asp:TextBox ID="txtWORcvNo" runat="server" CssClass="form-control" placeholder="Enter Work Order Receive No" />
                        </div>
                        <div class="field">
                            <label for="<%= txtWONo.ClientID %>">Work Order No</label>
                            <asp:TextBox ID="txtWONo" runat="server" CssClass="form-control" ReadOnly="true" placeholder="Auto Generate" />
                        </div>

                        <div class="field">
                            <label for="<%= txtWORcvDT.ClientID %>">WO Rcv DT</label>
                            <asp:TextBox ID="txtWORcvDT" runat="server" CssClass="form-control" TextMode="Date"/>
                        </div>
                        <div class="field">
                            <label for="<%= txtDeliveryDT.ClientID %>">Delivery DT</label>
                            <asp:TextBox ID="txtDeliveryDT" runat="server" CssClass="form-control" TextMode="Date" />
                        </div>
                        <div class="field">
                            <label for="<%= txtApprovedDT.ClientID %>">Approved DT</label>
                            <asp:TextBox ID="txtApprovedDT" runat="server" CssClass="form-control" TextMode="Date" />
                        </div>

                        <div class="field">
                            <label for="<%= ddlWOStatus.ClientID %>">WO Status</label>
                            <asp:DropDownList ID="ddlWOStatus" runat="server" CssClass="form-control">
                                <asp:ListItem Text="--Select--" Value="0" />
                                <asp:ListItem Text="Pending" Value="1" />
                                <asp:ListItem Text="Approved" Value="2" />
                                <asp:ListItem Text="Cancelled" Value="3" />
                            </asp:DropDownList>
                        </div>
                        <div class="field">
                            <label for="<%= ddlShippingMode.ClientID %>">Shipping Mode</label>
                            <asp:DropDownList ID="ddlShippingMode" runat="server" CssClass="form-control">
                                <asp:ListItem Text="--Select--" Value="0" />
                                <asp:ListItem Text="By Air" Value="1" />
                                <asp:ListItem Text="By Sea" Value="2" />
                                <asp:ListItem Text="By Road" Value="3" />
                            </asp:DropDownList>
                        </div>
                        <div class="field"></div>

                        <div class="field">
                            <label for="<%= txtRevision.ClientID %>">Revision</label>
                            <asp:TextBox ID="txtRevision" runat="server" CssClass="form-control" placeholder="Number" />
                        </div>
                        <div class="field">
                            <label for="<%= txtRevisionDate.ClientID %>">Revision Date</label>
                            <asp:TextBox ID="txtRevisionDate" runat="server" CssClass="form-control" TextMode="Date"/>
                        </div>
                        <div class="field">
                            <label for="<%= txtRevisionReason.ClientID %>">Revision Reason</label>
                            <asp:TextBox ID="txtRevisionReason" runat="server" CssClass="form-control" />
                        </div>

                        <div class="field span-3">
                            <label for="<%= txtSubject.ClientID %>">Subject</label>
                            <asp:TextBox ID="txtSubject" runat="server" TextMode="MultiLine" CssClass="form-control" Style="height: 60px;" />
                        </div>
                    </div>

                    <div class="nav-buttons">
                        <div></div>
                        <button type="button" class="btn btn-next" onclick="document.querySelector('.tab-headers button:nth-child(2)').click();">Next &raquo;</button>
                    </div>
                </div>

                <!-- TAB 2: Payment Information -->
                <div id="tabPaymentInfo" class="tab-content">

                    <div class="section-label">Payment Setup</div>
                    <div class="form-grid">
                        <div class="field span-3">
                            <label for="<%= ddlCustomer.ClientID %>">Customer</label>
                            <asp:DropDownList ID="ddlCustomer" runat="server" CssClass="form-control" AutoPostBack="True">
                                <asp:ListItem Text="--Select--" Value="" />
                            </asp:DropDownList>
                        </div>

                        <div class="field span-2">
                            <label for="<%= ddlPaymentTerms.ClientID %>">Payment Terms</label>
                            <asp:DropDownList ID="ddlPaymentTerms" runat="server" CssClass="form-control">
                                <asp:ListItem Text="--Select--" Value="0" />
                                <asp:ListItem Text="TT (Telegraphic Transfer)" Value="1" />
                                <asp:ListItem Text="LC at Sight" Value="2" />
                                <asp:ListItem Text="Deferred LC (30 Days)" Value="3" />
                                <asp:ListItem Text="Deferred LC (60 Days)" Value="4" />
                                <asp:ListItem Text="Deferred LC (90 Days)" Value="5" />
                                <asp:ListItem Text="Cash in Advance (CIA)" Value="6" />
                                <asp:ListItem Text="Cash on Delivery (COD)" Value="7" />
                            </asp:DropDownList>
                        </div>
                        <div class="field">
                            <label for="<%= ddlCurrency.ClientID %>">Currency</label>
                            <asp:DropDownList ID="ddlCurrency" runat="server" CssClass="form-control">
                                <asp:ListItem Text="--Select--" Value="0" />
                                <asp:ListItem Text="BDT" Value="1" />
                                <asp:ListItem Text="USD" Value="2" />
                                <asp:ListItem Text="EUR" Value="3" />
                                <asp:ListItem Text="GBP" Value="4" />
                                <asp:ListItem Text="RMB" Value="5" />
                            </asp:DropDownList>
                        </div>

                        <div class="field span-2">
                            <label for="<%= ddlPaymentMode.ClientID %>">Payment Mode</label>
                            <asp:DropDownList ID="ddlPaymentMode" runat="server" CssClass="form-control">
                                <asp:ListItem Text="--Select--" Value="0" />
                                <asp:ListItem Text="Bank Transfer" Value="1" />
                                <asp:ListItem Text="L/C (Letter of Credit)" Value="2" />
                                <asp:ListItem Text="Cash" Value="3" />
                                <asp:ListItem Text="Cheque / Pay Order" Value="4" />
                                <asp:ListItem Text="TT" Value="5" />
                            </asp:DropDownList>
                        </div>
                        <div class="field">
                            <label for="<%= txtCurrConv.ClientID %>">Curr. Conv.</label>
                            <asp:TextBox ID="txtCurrConv" runat="server" CssClass="form-control" Text="1" />
                        </div>
                    </div>

                    <div class="section-label" style="margin-top:8px;">Terms &amp; Conditions</div>
                    <div class="form-grid cols-2">
                        <div class="field span-2">
                            <asp:TextBox ID="txtTermsConditions" runat="server" TextMode="MultiLine" CssClass="form-control" Style="height: 90px;" placeholder="[Text Here!]" />
                        </div>
                    </div>

                    <div class="nav-buttons">
                        <button type="button" class="btn btn-prev" onclick="document.querySelector('.tab-headers button:nth-child(1)').click();">&laquo; Previous</button>
                        <button type="button" class="btn btn-next" onclick="document.querySelector('.tab-headers button:nth-child(3)').click();">Next &raquo;</button>
                    </div>
                </div>

                <!-- TAB 3: Order Information -->
                <div id="tabOrderInfo" class="tab-content">

                    <!-- Search / Filter Box -->
                    <div class="section-label">Filter Quotation List</div>
                    <div class="filter-panel">
                        <div class="form-grid cols-4">
                            <div class="field">
                                <label for="<%= txtSearchQuotationNo.ClientID %>">Quotation No</label>
                                <asp:TextBox ID="txtSearchQuotationNo" runat="server" CssClass="form-control" placeholder="e.g. QT-0002" />
                            </div>
                            <div class="field">
                                <label for="<%= ddlSearchCustomer.ClientID %>">Customer</label>
                                <asp:DropDownList ID="ddlSearchCustomer" runat="server" CssClass="form-control">
                                    <asp:ListItem Text="--All Customer--" Value="0" />
                                </asp:DropDownList>
                            </div>
                            <div class="field">
                                <label for="<%= txtFromDate.ClientID %>">From Date</label>
                                <asp:TextBox ID="txtFromDate" runat="server" CssClass="form-control" TextMode="Date" />
                            </div>
                            <div class="field">
                                <label for="<%= txtTillDate.ClientID %>">Till Date</label>
                                <asp:TextBox ID="txtTillDate" runat="server" CssClass="form-control" TextMode="Date" />
                            </div>
                            <div class="field">
                                 <asp:Button ID="btnSearch" runat="server" CssClass="btn btn-search" Text="Search" OnClick="btnSearch_Click" />
                            </div>
                        </div>
                    </div>

                    <!-- ================= Quotation Items (one row per finished Item) ================= -->
                    <div class="section-label" style="margin-top:20px;">
                        Quotation Items &mdash; uncheck "Include" to drop an item, enter Order Qty for the rest
                    </div>

                    <div class="list-toolbar">
                        <div></div>
                        <asp:Button ID="btnLoadItems" runat="server" Text="Load Items From Selected Quotation" 
                            CssClass="btn btn-add" OnClick="btnLoadItems_Click" />
                    </div>

                    <asp:GridView ID="gvQuotationItems" runat="server" CssClass="grid" AutoGenerateColumns="False" 
                        EmptyDataText="No items loaded. Set the filter above and click Load Items.">
                        <Columns>
                            <asp:TemplateField HeaderText="Include">
                                <ItemTemplate>
                                    <asp:CheckBox ID="chkIncludeItem" runat="server" Checked="true" AutoPostBack="true" OnCheckedChanged="chkIncludeItem_CheckedChanged" />
                                </ItemTemplate>
                                <ItemStyle Width="55px" HorizontalAlign="Center" />
                                <HeaderStyle HorizontalAlign="Center" />
                            </asp:TemplateField>

                            <asp:TemplateField HeaderText="Sl No">
                                <ItemTemplate>
                                    <%# Container.DataItemIndex + 1 %>
                                </ItemTemplate>
                                <ItemStyle Width="45px" />
                            </asp:TemplateField>
                            <asp:BoundField DataField="FinishedItemID" HeaderText="Item ID" />
                            <asp:BoundField DataField="FinishedItemName" HeaderText="Item Name" />
                            <asp:TemplateField HeaderText="Rate">
                                <ItemTemplate>
                                    <asp:HiddenField ID="hdnRate" runat="server" Value='<%# Eval("Rate") %>' />
                                    <asp:Label ID="lblRate" runat="server" Text='<%# Eval("Rate", "{0:0.00}") %>' />
                                </ItemTemplate>
                                <ItemStyle Width="100px" />
                            </asp:TemplateField>

                            <asp:TemplateField HeaderText="Order Qty">
                                <ItemTemplate>
                                    <asp:TextBox ID="txtOrderQty" runat="server" CssClass="form-control text-end" AutoPostBack="true" OnTextChanged="txtOrderQty_TextChanged" />
                                </ItemTemplate>
                                <ItemStyle Width="110px" />
                            </asp:TemplateField>

                            <asp:TemplateField HeaderText="Amount">
                                <ItemTemplate>
                                    <asp:Label ID="lblAmount" runat="server" CssClass="lblAmount" Text="0.00" />
                                </ItemTemplate>
                                <ItemStyle Width="110px" />
                            </asp:TemplateField>
                        </Columns>
                    </asp:GridView>

                    <div class="clearfix" style="margin-top: 15px;">
                        <table class="form-table totals-section">
                            <tr class="totals-row grand-total" style="font-weight: bold;">
                                <td class="lbl"><label>Grand Total Value</label></td>
                                <td class="val"><asp:TextBox ID="txtGTotal" runat="server" CssClass="form-control" Text="0" Style="text-align: right; font-weight: bold;" ReadOnly="true" /></td>
                            </tr>
                        </table>
                    </div>

                    <div class="nav-buttons">
                        <button type="button" class="btn btn-prev" onclick="document.querySelector('.tab-headers button:nth-child(2)').click();">&laquo; Previous</button>
                        <div></div>
                    </div>
                </div>

                <div class="action-bar">
                    <asp:Button ID="btnSave" runat="server" Text="Save" CssClass="btn btn-save" OnClick="btnSave_Click" />
                    <asp:Button ID="btnCancel" runat="server" Text="Cancel" CssClass="btn btn-cancel" />
                    <asp:Button ID="btnDelete" runat="server" Text="Delete" CssClass="btn btn-delete" />
                    <asp:Button ID="btnBackToList" runat="server" Text="Back To List" CssClass="btn btn-back" OnClientClick="showPanel('pnlList'); return false;" />
                </div>
            </div>
            </div>
        </div>
    </form>
</body>
</html>
