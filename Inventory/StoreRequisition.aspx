<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="StoreRequisition.aspx.cs" Inherits="Nexa_ERP.Inventory.StoreRequisition" MaintainScrollPositionOnPostBack="true" %>

<!DOCTYPE html>
<html lang="en">
<head runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <title>Smart Dynamic Internal Requisition | Garments ERP</title>
    <!-- Bootstrap 5 CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet" />
    <!-- FontAwesome Icons -->
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.2/css/all.min.css" rel="stylesheet" />
    <style>
        :root {
            --bg-body: #f4f6f9;
            --card-bg: #ffffff;
            --text-color: #333333;
            --border-color: #dee2e6;
            --thead-bg: #343a40;
            --muted: #6c757d;
        }
        body.dark-mode {
            --bg-body: #121212;
            --card-bg: #1e1e1e;
            --text-color: #e0e0e0;
            --border-color: #333333;
            --thead-bg: #000000;
            --muted: #9a9a9a;
        }
        body {
            background-color: var(--bg-body);
            color: var(--text-color);
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            font-size: 0.85rem;
            transition: background-color .2s ease, color .2s ease;
        }
        .card {
            background-color: var(--card-bg);
            border-color: var(--border-color);
            box-shadow: 0 0.125rem 0.25rem rgba(0, 0, 0, 0.075);
            margin-bottom: 1rem;
        }
        body.dark-mode .form-control,
        body.dark-mode .form-select {
            background-color: #2a2a2a;
            color: #e0e0e0;
            border-color: var(--border-color);
        }
        body.dark-mode .bg-light { background-color: #1a1a1a !important; }
        body.dark-mode .table-striped > tbody > tr:nth-of-type(odd) > * { color: #e0e0e0; }
        body.dark-mode .text-muted { color: var(--muted) !important; }

        .table-sticky th {
            position: sticky;
            top: 0;
            background-color: var(--thead-bg);
            color: white;
            z-index: 10;
            white-space: nowrap;
        }
        .dashboard-card {
            border-left: 4px solid #0d6efd;
            transition: transform 0.15s ease, box-shadow .15s ease;
            cursor: default;
        }
        .dashboard-card:hover {
            transform: translateY(-2px);
            box-shadow: 0 0.25rem 0.5rem rgba(0,0,0,0.12);
        }
        .hidden-section { display: none !important; }

        .required-mark { color: #dc3545; }

        .grid-input {
            min-width: 90px;
        }
        .qty-negative { color: #dc3545; font-weight: 600; }
        .row-invalid { outline: 1px solid #dc3545; }

        #grandTotalRow td {
            font-weight: 700;
            background-color: rgba(13,110,253,0.06);
            border-top: 2px solid #0d6efd;
        }
        body.dark-mode #grandTotalRow td { background-color: rgba(13,110,253,0.15); }

        .app-loading-overlay {
            position: fixed; inset: 0; background: rgba(0,0,0,.35);
            display: none; align-items: center; justify-content: center; z-index: 2000;
        }
        .app-loading-overlay.show { display: flex; }

        /* Small fade so the UpdatePanel refresh doesn't feel abrupt */
        .update-fade {
            transition: opacity .12s ease-in-out;
        }
        .update-fading {
            opacity: 0.45;
        }

        @media print {
            .no-print { display: none !important; }
            body { background: #fff; color: #000; font-size: 11px; }
            .card { box-shadow: none; border: 1px solid #999; }
            .table-sticky th { background-color: #eee !important; color: #000 !important; }
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <asp:ScriptManager ID="ScriptManager1" runat="server" EnablePartialRendering="true" />

        <!-- Loading overlay -->
        <div class="app-loading-overlay" id="loadingOverlay">
            <div class="spinner-border text-light" role="status" style="width:3rem;height:3rem;">
                <span class="visually-hidden">Processing...</span>
            </div>
        </div>

        <div class="container-fluid py-3">

            <!-- Top Header & Theme Toggle (outside UpdatePanel - never needs to refresh) -->
            <div class="d-flex justify-content-between align-items-center mb-3 no-print">
                <div>
                    <h4 class="fw-bold mb-0"><i class="fa-solid fa-boxes-stacked text-primary"></i> Internal Requisition Management</h4>
                    <small class="text-muted">Inventory &raquo; Store &raquo; Internal Requisition</small>
                </div>
                <div class="d-flex gap-2">
                    <button type="button" class="btn btn-sm btn-outline-secondary" id="btnThemeToggle" onclick="toggleTheme()">
                        <i class="fa-solid fa-moon" id="themeIcon"></i> Theme
                    </button>
                </div>
            </div>

            <%--
                =========================================================================
                Everything below is wrapped in a SINGLE UpdatePanel with UpdateMode="Always".
                Reason: dropdowns cascade across sections (Company -> Branch -> Building ->
                Floor, Issuing/Receiving Store, Customer -> Buyer -> Style -> WO, etc).
                Keeping it as one panel avoids having to wire up a long <Triggers> list on
                every panel and guarantees no full-page (browser-level) postback happens,
                so the page never reloads or jumps back to the top.
                The item grid + JS is still pure client-side (no server postback needed),
                so grid edits are untouched by any of this.

                IMPORTANT: There is intentionally NO asp:FileUpload control anywhere on
                this page (or anywhere else in the <form>). asp:FileUpload forces the
                <form> to render with enctype="multipart/form-data", and the Microsoft
                AJAX UpdatePanel client library CANNOT submit a multipart form
                asynchronously - it silently falls back to a full, synchronous postback
                for EVERY control on the page (including these dropdowns), which is what
                was causing the whole page/iframe to reload and jump to the top. Keep it
                that way - if file attachments are needed later, upload them via a plain
                HTML <input type="file"> + fetch()/XHR to a separate .ashx handler, never
                via asp:FileUpload inside this form.
                =========================================================================
            --%>
            <asp:UpdatePanel ID="upMain" runat="server" UpdateMode="Always" ChildrenAsTriggers="true">
                <ContentTemplate>

                    <!-- Validation Summary -->
                    <asp:ValidationSummary ID="ValidationSummary1" runat="server" CssClass="alert alert-danger py-2" DisplayMode="BulletList" HeaderText="Please correct the following before submitting:" />

                    <!-- Dashboard Summary Cards -->
                    <div class="row g-2 mb-3 no-print">
                        <div class="col"><div class="card dashboard-card p-2 text-center"><h6 class="mb-1">Draft</h6><h5 class="text-secondary mb-0"><asp:Literal ID="litDraftCount" runat="server" Text="04" /></h5></div></div>
                        <div class="col"><div class="card dashboard-card p-2 text-center"><h6 class="mb-1">Pending</h6><h5 class="text-warning mb-0"><asp:Literal ID="litPendingCount" runat="server" Text="12" /></h5></div></div>
                        <div class="col"><div class="card dashboard-card p-2 text-center"><h6 class="mb-1">Approved</h6><h5 class="text-info mb-0"><asp:Literal ID="litApprovedCount" runat="server" Text="08" /></h5></div></div>
                        <div class="col"><div class="card dashboard-card p-2 text-center"><h6 class="mb-1">Ready Issue</h6><h5 class="text-primary mb-0"><asp:Literal ID="litReadyCount" runat="server" Text="05" /></h5></div></div>
                        <div class="col"><div class="card dashboard-card p-2 text-center"><h6 class="mb-1">Issued</h6><h5 class="text-success mb-0"><asp:Literal ID="litIssuedCount" runat="server" Text="19" /></h5></div></div>
                        <div class="col"><div class="card dashboard-card p-2 text-center"><h6 class="mb-1">Completed</h6><h5 class="text-dark mb-0"><asp:Literal ID="litCompletedCount" runat="server" Text="142" /></h5></div></div>
                        <div class="col"><div class="card dashboard-card p-2 text-center border-success"><h6 class="mb-1">Total Value</h6><h5 class="text-success mb-0"><asp:Literal ID="litTotalValue" runat="server" Text="৳45.2L" /></h5></div></div>
                    </div>

                    <!-- Requisition Category Switcher -->
                    <div class="card p-3 bg-light no-print">
                        <div class="row g-2 align-items-end">
                            <div class="col-md-4">
                                <label for="ddlReqCategory" class="form-label fw-bold mb-2">Requisition Category:</label>
                                <select id="ddlReqCategory" class="form-select form-select-sm" onchange="handleCategoryChange()">
                                    <option value="GIR" selected>🏢 General Internal Requisition</option>
                                    <option value="PMR">👕 Production Material Requisition</option>
                                </select>
                            </div>
                        </div>
                        <asp:HiddenField ID="hdnReqCategory" runat="server" Value="GIR" />
                    </div>

                    <!-- Master Information Section -->
                    <div class="card">
                        <div class="card-header bg-primary text-white fw-bold"><i class="fa-solid fa-info-circle"></i> Master Information</div>
                        <div class="card-body">
                            <div class="row g-2">
                                <div class="col-md-2">
                                    <label class="form-label">Company <span class="required-mark">*</span></label>
                                    <asp:DropDownList ID="ddlCompany" runat="server" CssClass="form-select form-select-sm" AutoPostBack="true" OnSelectedIndexChanged="ddlCompany_SelectedIndexChanged"></asp:DropDownList>
                                    <asp:RequiredFieldValidator ID="rfvCompany" runat="server" ControlToValidate="ddlCompany" InitialValue="" ErrorMessage="Company is required." Display="Dynamic" CssClass="text-danger small" ValidationGroup="Submit" />
                                </div>
                                <div class="col-md-2">
                                    <label class="form-label">Branch</label>
                                    <asp:DropDownList ID="ddlBranch" runat="server" AutoPostBack="true" CssClass="form-select form-select-sm" OnSelectedIndexChanged="ddlBranch_SelectedIndexChanged">
                                        <asp:ListItem Text="--Select Branch-" Value="0"></asp:ListItem>
                                    </asp:DropDownList>
                                </div>
                                <div class="col-md-2">
                                    <label class="form-label">Building</label>
                                    <asp:DropDownList ID="ddlBuilding" runat="server" AutoPostBack="true" CssClass="form-select form-select-sm" OnSelectedIndexChanged="ddlBuilding_SelectedIndexChanged">
                                        <asp:ListItem Text="--Select Building-" Value="0"></asp:ListItem>
                                    </asp:DropDownList>
                                </div>
                                <div class="col-md-2">
                                    <label class="form-label">Floor</label>
                                    <asp:DropDownList ID="ddlFloor" runat="server" CssClass="form-select form-select-sm">
                                        <asp:ListItem Text="--Select Floor-" Value="0"></asp:ListItem>
                                    </asp:DropDownList>
                                </div>
                                <div class="col-md-2">
                                    <label class="form-label">Cost Center <span class="required-mark">*</span></label>
                                    <asp:DropDownList ID="ddlCostCenter" runat="server" CssClass="form-select form-select-sm">
                                        <asp:ListItem Text="--Select Cost Center--" Value="0"></asp:ListItem>
                                    </asp:DropDownList>
                                </div>
                                <div class="col-md-2">
                                    <label class="form-label">Issuing Store <span class="required-mark">*</span></label>
                                    <asp:DropDownList ID="ddlIssuingStore" runat="server" AutoPostBack="true" CssClass="form-select form-select-sm" OnSelectedIndexChanged="ddlIssuingStore_SelectedIndexChanged">
                                        <asp:ListItem Text="--Select Issuing Store--" Value="0"></asp:ListItem>
                                    </asp:DropDownList>
                                </div>
                                <div class="col-md-2">
                                    <label class="form-label">Receiving Store <span class="required-mark">*</span></label>
                                    <asp:DropDownList ID="ddlReceivingStore" runat="server" AutoPostBack="true" CssClass="form-select form-select-sm" OnSelectedIndexChanged="ddlReceivingStore_SelectedIndexChanged">
                                        <asp:ListItem Text="--Select Receiving Store--" Value="0"></asp:ListItem>
                                    </asp:DropDownList>
                                </div>
                                <div class="col-md-2">
                                    <label class="form-label">Internal Requisition No.</label>
                                    <asp:TextBox ID="txtReqNo" runat="server" CssClass="form-control form-control-sm" ReadOnly="true" Text="REQ-2026-0806-0012"></asp:TextBox>
                                </div>
                                <div class="col-md-2">
                                    <label class="form-label">Required Date <span class="required-mark">*</span></label>
                                    <asp:TextBox ID="txtRequiredDate" runat="server" CssClass="form-control form-control-sm" TextMode="Date"></asp:TextBox>
                                    <asp:RequiredFieldValidator ID="rfvRequiredDate" runat="server" ControlToValidate="txtRequiredDate" ErrorMessage="Required date is required." Display="Dynamic" CssClass="text-danger small" ValidationGroup="Submit" />
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- Garments Production & Style Reference (Dynamic Section for PMR) -->
                    <div id="productionSection" class="card hidden-section border-success">
                        <div class="card-header bg-success text-white fw-bold"><i class="fa-solid fa-shirt"></i> Garments Production & Style Reference</div>
                        <div class="card-body">
                            <div class="row g-2">
                                <div class="col-md-3">
                                    <label class="form-label">Customer <span class="required-mark">*</span></label>
                                    <asp:DropDownList ID="ddlCustomer" runat="server" CssClass="form-select form-select-sm" AutoPostBack="true" OnSelectedIndexChanged="ddlCustomer_SelectedIndexChanged"></asp:DropDownList>
                                </div>
                                <div class="col-md-3">
                                    <label class="form-label">Buyer</label>
                                    <asp:DropDownList ID="ddlBuyer" runat="server" CssClass="form-select form-select-sm" AutoPostBack="true"></asp:DropDownList>
                                </div>
                                <div class="col-md-3">
                                    <label class="form-label">Style No.</label>
                                    <asp:DropDownList ID="ddlStyleNo" runat="server" CssClass="form-select form-select-sm" AutoPostBack="true"></asp:DropDownList>
                                </div>
                                <div class="col-md-3">
                                    <label class="form-label">Style No. <span class="required-mark">*</span></label>
                                    <asp:DropDownList ID="ddl" runat="server" CssClass="form-select form-select-sm" AutoPostBack="true"></asp:DropDownList>
                                </div>
                                <div class="col-md-3">
                                    <label class="form-label">WO Receive Ref No. <span class="required-mark">*</span></label>
                                    <asp:DropDownList ID="ddlWOReceiveRef" runat="server" CssClass="form-select form-select-sm" AutoPostBack="true" OnSelectedIndexChanged="ddlWOReceiveRef_SelectedIndexChanged"></asp:DropDownList>
                                </div>
                                <div class="col-md-3">
                                    <label class="form-label">Work Order No. <span class="required-mark">*</span></label>
                                    <asp:DropDownList ID="ddlWorkOrder" runat="server" CssClass="form-select form-select-sm"></asp:DropDownList>
                                </div>
                                <div class="col-md-3">
                                    <label class="form-label">Order Quantity</label>
                                    <asp:TextBox ID="txtOrderQty" runat="server" CssClass="form-control form-control-sm" ReadOnly="true"></asp:TextBox>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- Smart Item Entry Grid Section (pure client-side, no server postback) -->
                    <div class="card">
                        <div class="card-header bg-dark text-white d-flex justify-content-between align-items-center">
                            <span class="fw-bold"><i class="fa-solid fa-list-check"></i> Requisition Item Grid</span>
                            <div class="no-print">
                                <button type="button" class="btn btn-sm btn-light" onclick="addRow()"><i class="fa-solid fa-plus"></i> Add Row</button>
                                <button type="button" class="btn btn-sm btn-light" onclick="alert('Bulk paste: copy rows from Excel and press this button after selecting the target cell (feature hook).')"><i class="fa-solid fa-file-excel"></i> Bulk Paste</button>
                            </div>
                        </div>
                        <div class="card-body p-0">
                            <div class="table-responsive" style="max-height: 380px;">
                                <table class="table table-bordered table-striped table-hover mb-0 table-sticky" id="itemGrid">
                                    <thead>
                                        <tr>
                                            <th style="width:36px;">#</th>
                                            <th>Item Code</th>
                                            <th>Item Name</th>
                                            <th>Color / Size</th>
                                            <th>UOM</th>
                                            <th class="text-end">Required Qty</th>
                                            <th class="text-end">Available Stk</th>
                                            <th class="text-end">Req. Qty <span class="required-mark">*</span></th>
                                            <th class="text-end">Prev. Req</th>
                                            <th class="text-end">Balance</th>
                                            <th class="text-end">Unit Rate</th>
                                            <th class="text-end">Total Value</th>
                                            <th class="no-print" style="width:48px;">Action</th>
                                        </tr>
                                    </thead>
                                    <tbody id="itemGridBody">
                                        <tr data-rate="450.00" data-available="950.00" data-prev-req="300.00">
                                            <td class="row-no">1</td>
                                            <td><input type="text" class="form-control form-control-sm grid-input" value="FAB-001" placeholder="Item code" /></td>
                                            <td><input type="text" class="form-control form-control-sm grid-input" value="Cotton Single Jersey" placeholder="Item name" /></td>
                                            <td><input type="text" class="form-control form-control-sm grid-input" value="Navy / M" placeholder="Color / Size" /></td>
                                            <td><input type="text" class="form-control form-control-sm grid-input" value="KG" style="max-width:70px;" /></td>
                                            <td class="text-end">500.00</td>
                                            <td class="text-end avail-qty">950.00</td>
                                            <td>
                                                <input type="number" min="0" step="0.01" class="form-control form-control-sm text-end req-qty" value="200" oninput="calculateRow(this)" />
                                            </td>
                                            <td class="text-end">300.00</td>
                                            <td class="text-end bal-qty">200.00</td>
                                            <td class="text-end">450.00</td>
                                            <td class="text-end total-val">90,000.00</td>
                                            <td class="no-print text-center"><button type="button" class="btn btn-sm btn-danger" onclick="removeRow(this)" title="Remove row"><i class="fa-solid fa-trash"></i></button></td>
                                        </tr>
                                    </tbody>
                                    <tfoot>
                                        <tr id="grandTotalRow">
                                            <td colspan="11" class="text-end">Grand Total</td>
                                            <td class="text-end" id="grandTotalCell">90,000.00</td>
                                            <td class="no-print"></td>
                                        </tr>
                                    </tfoot>
                                </table>
                            </div>
                        </div>
                    </div>

                    <!-- Hidden field carrying serialized grid data to the server on submit -->
                    <asp:HiddenField ID="hdnGridData" runat="server" />

                    <!-- Remarks (Attachments feature removed - see comment above UpdatePanel) -->
                    <div class="row g-2">
                        <div class="col-md-8">
                            <div class="card h-100">
                                <div class="card-body">
                                    <div class="mb-2">
                                        <label class="form-label">General Remarks / Reason for Requisition</label>
                                        <asp:TextBox ID="txtRemarks" runat="server" CssClass="form-control form-control-sm" TextMode="MultiLine" Rows="3" placeholder="Explain why this requisition is being raised..."></asp:TextBox>
                                    </div>
                                </div>
                            </div>
                        </div>
                        <div class="col-md-4">
                            <div class="card h-100">
                                <div class="card-body">
                                    <h6 class="fw-bold">Audit Information</h6>
                                    <hr class="my-1" />
                                    <small class="text-muted d-block">Created By: <asp:Literal ID="litCreatedBy" runat="server" Text="Md. Tanvir (EMP-1092)" /></small>
                                    <small class="text-muted d-block">Created Date: <asp:Literal ID="litCreatedDate" runat="server" Text="08/06/2026 09:15 AM" /></small>
                                    <small class="text-muted d-block">
                                        Status:
                                        <asp:Label ID="lblStatus" runat="server" CssClass="badge bg-warning text-dark" Text="Draft" />
                                    </small>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- Action Footer Buttons -->
                    <div class="card mt-2 p-2 bg-light no-print">
                        <div class="d-flex justify-content-end gap-2">
                            <asp:Button ID="btnSaveDraft" runat="server" CssClass="btn btn-sm btn-secondary" Text="Save Draft" OnClientClick="return prepareSubmit();" OnClick="btnSaveDraft_Click" CausesValidation="false" />
                            <asp:Button ID="btnConfirm" runat="server" CssClass="btn btn-sm btn-primary" Text="Confirm & Submit" ValidationGroup="Submit" OnClientClick="return prepareSubmit() && confirmSubmit();" OnClick="btnConfirm_Click" />
                            <asp:Button ID="btnPrint" runat="server" CssClass="btn btn-sm btn-info text-white" Text="Print" OnClientClick="window.print(); return false;" CausesValidation="false" />
                            <asp:Button ID="btnCancel" runat="server" CssClass="btn btn-sm btn-danger" Text="Cancel" OnClientClick="return confirmCancel();" OnClick="btnCancel_Click" CausesValidation="false" />
                        </div>
                    </div>

                </ContentTemplate>
            </asp:UpdatePanel>

        </div>
    </form>

    <!-- Bootstrap JS Bundle -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        // ---------- Category (GIR / PMR) toggle ----------
        // ddlReqCategory is a PLAIN html <select> (not a server control), so its
        // selection lives only in the browser DOM. hdnReqCategory IS a real
        // asp:HiddenField, so its Value correctly survives every postback
        // (sync or async) via normal ASP.NET postback/ViewState handling.
        //
        // The bug: every UpdatePanel async postback (e.g. changing Company)
        // re-renders the WHOLE ContentTemplate from server markup, and that
        // markup always hard-codes <option value="GIR" selected>. So after
        // any dropdown-triggered postback, the <select> silently snapped back
        // to GIR and the Production section hid itself - even though the user
        // had picked PMR and the hidden field still correctly said "PMR".
        //
        // Fix: after any DOM refresh, first push the hidden field's
        // (correctly persisted) value back INTO the select, THEN evaluate/
        // toggle the section - instead of always trusting the freshly
        // re-rendered select's default value.
        function syncCategoryFromHidden() {
            var select = document.getElementById('ddlReqCategory');
            var hdn = document.getElementById('<%= hdnReqCategory.ClientID %>');
            if (select && hdn && hdn.value) {
                select.value = hdn.value;
            }
            handleCategoryChange();
        }

        function handleCategoryChange() {
            var select = document.getElementById('ddlReqCategory');
            var isPMR = select && select.value === 'PMR';
            var productionSection = document.getElementById('productionSection');
            var hdn = document.getElementById('<%= hdnReqCategory.ClientID %>');
            if (isPMR) {
                productionSection.classList.remove('hidden-section');
            } else {
                productionSection.classList.add('hidden-section');
            }
            if (hdn) hdn.value = isPMR ? 'PMR' : 'GIR';
        }

        // ---------- Theme (persisted) ----------
        function applyStoredTheme() {
            var saved = localStorage.getItem('nexa_erp_theme');
            var icon = document.getElementById('themeIcon');
            if (saved === 'dark') {
                document.body.classList.add('dark-mode');
                if (icon) { icon.classList.remove('fa-moon'); icon.classList.add('fa-sun'); }
            }
        }
        function toggleTheme() {
            var isDark = document.body.classList.toggle('dark-mode');
            var icon = document.getElementById('themeIcon');
            if (icon) {
                icon.classList.toggle('fa-moon', !isDark);
                icon.classList.toggle('fa-sun', isDark);
            }
            localStorage.setItem('nexa_erp_theme', isDark ? 'dark' : 'light');
        }

        // ---------- Number formatting ----------
        function fmt(n) {
            return (Math.round(n * 100) / 100).toLocaleString('en-US', { minimumFractionDigits: 2, maximumFractionDigits: 2 });
        }

        // ---------- Grid row calculations ----------
        function calculateRow(input) {
            var row = input.closest('tr');
            var reqQty = parseFloat(input.value) || 0;
            var rate = parseFloat(row.getAttribute('data-rate')) || 0;
            var available = parseFloat(row.getAttribute('data-available')) || 0;
            var prevReq = parseFloat(row.getAttribute('data-prev-req')) || 0;

            var balance = available - reqQty;
            var balCell = row.querySelector('.bal-qty');
            if (balCell) {
                balCell.innerText = fmt(balance);
                balCell.classList.toggle('qty-negative', balance < 0);
            }

            var totalVal = reqQty * rate;
            var totalCell = row.querySelector('.total-val');
            if (totalCell) totalCell.innerText = fmt(totalVal);

            input.classList.toggle('row-invalid', reqQty <= 0);

            updateGrandTotal();
        }

        function updateGrandTotal() {
            var rows = document.querySelectorAll('#itemGridBody tr');
            var grand = 0;
            rows.forEach(function (row) {
                var cell = row.querySelector('.total-val');
                if (cell) grand += parseFloat(cell.innerText.replace(/,/g, '')) || 0;
            });
            var cell = document.getElementById('grandTotalCell');
            if (cell) cell.innerText = fmt(grand);
        }

        function renumberRows() {
            var rows = document.querySelectorAll('#itemGridBody tr');
            rows.forEach(function (row, idx) {
                var noCell = row.querySelector('.row-no');
                if (noCell) noCell.innerText = idx + 1;
            });
        }

        function addRow() {
            var tbody = document.getElementById('itemGridBody');
            var newRow = document.createElement('tr');
            newRow.setAttribute('data-rate', '0');
            newRow.setAttribute('data-available', '0');
            newRow.setAttribute('data-prev-req', '0');
            newRow.innerHTML =
                '<td class="row-no"></td>' +
                '<td><input type="text" class="form-control form-control-sm grid-input" placeholder="Item code" /></td>' +
                '<td><input type="text" class="form-control form-control-sm grid-input" placeholder="Item name" /></td>' +
                '<td><input type="text" class="form-control form-control-sm grid-input" placeholder="Color / Size" /></td>' +
                '<td><input type="text" class="form-control form-control-sm grid-input" style="max-width:70px;" placeholder="UOM" /></td>' +
                '<td class="text-end">0.00</td>' +
                '<td class="text-end avail-qty">0.00</td>' +
                '<td><input type="number" min="0" step="0.01" class="form-control form-control-sm text-end req-qty" value="0" oninput="calculateRow(this)" /></td>' +
                '<td class="text-end">0.00</td>' +
                '<td class="text-end bal-qty">0.00</td>' +
                '<td class="text-end">0.00</td>' +
                '<td class="text-end total-val">0.00</td>' +
                '<td class="no-print text-center"><button type="button" class="btn btn-sm btn-danger" onclick="removeRow(this)" title="Remove row"><i class="fa-solid fa-trash"></i></button></td>';
            tbody.appendChild(newRow);
            renumberRows();
            newRow.querySelector('.grid-input').focus();
        }

        function removeRow(btn) {
            var tbody = document.getElementById('itemGridBody');
            if (tbody.rows.length > 1) {
                btn.closest('tr').remove();
                renumberRows();
                updateGrandTotal();
            } else {
                alert('At least one item row is required.');
            }
        }

        // ---------- Submit helpers ----------
        function prepareSubmit() {
            // Serialize the grid so the code-behind can read it via the hidden field.
            var rows = document.querySelectorAll('#itemGridBody tr');
            var data = [];
            var hasInvalid = false;
            rows.forEach(function (row) {
                var inputs = row.querySelectorAll('input[type="text"]');
                var reqQtyInput = row.querySelector('.req-qty');
                var reqQty = parseFloat(reqQtyInput ? reqQtyInput.value : 0) || 0;
                if (reqQty <= 0) hasInvalid = true;
                data.push({
                    itemCode: inputs[0] ? inputs[0].value : '',
                    itemName: inputs[1] ? inputs[1].value : '',
                    colorSize: inputs[2] ? inputs[2].value : '',
                    uom: inputs[3] ? inputs[3].value : '',
                    reqQty: reqQty,
                    rate: parseFloat(row.getAttribute('data-rate')) || 0
                });
            });
            var hdn = document.getElementById('<%= hdnGridData.ClientID %>');
            if (hdn) hdn.value = JSON.stringify(data);

            if (hasInvalid) {
                alert('Every item row must have a Requisition Quantity greater than zero.');
                return false;
            }
            if (data.length === 0) {
                alert('Please add at least one item to the requisition.');
                return false;
            }
            return true;
        }

        function confirmSubmit() {
            var ok = confirm('Are you sure you want to confirm and submit this requisition for approval?');
            if (ok) showLoading();
            return ok;
        }

        function confirmCancel() {
            return confirm('This will discard unsaved changes. Continue?');
        }

        function showLoading() {
            var overlay = document.getElementById('loadingOverlay');
            if (overlay) overlay.classList.add('show');
        }

        // ---------- Init (runs on first full load, and again after every async postback) ----------
        function initPage() {
            applyStoredTheme();
            syncCategoryFromHidden();
            renumberRows();
            updateGrandTotal();
        }

        document.addEventListener('DOMContentLoaded', function () {
            initPage();
        });

        // =====================================================================
        // SCROLL-POSITION FIX
        //
        // There are two completely different situations that can lose scroll
        // position, and they need two different fixes:
        //
        //  A) A genuine FULL page reload (e.g. Sync postback, first load,
        //     someone hits F5). Here the browser really unloads/reloads the
        //     document, so we persist scrollY in sessionStorage and restore
        //     it once the new document has loaded.
        //
        //  B) A normal ASYNC UpdatePanel postback (this is what happens on
        //     every dropdown change on this page). The browser/document is
        //     NEVER unloaded here - 'beforeunload'/'DOMContentLoaded' do NOT
        //     fire at all for this case. Instead, MS AJAX replaces the
        //     UpdatePanel's innerHTML and then tries to restore focus to the
        //     control that triggered the postback. That focus-restore step
        //     is what visually resets the scroll position - NOT a real
        //     navigation. This must be fixed by hooking directly into
        //     Sys.WebForms.PageRequestManager's begin/end events and
        //     re-applying the scroll position AFTER the DOM update settles.
        // =====================================================================

        var __lastScrollY = 0;

        function saveScrollNow() {
            __lastScrollY = window.scrollY || window.pageYOffset || document.documentElement.scrollTop || 0;
            sessionStorage.setItem('nexa_scrollpos_' + window.location.pathname, String(__lastScrollY));
        }

        function restoreScrollNow(y) {
            // Re-apply a few times across animation frames, because the
            // UpdatePanel's DOM (grid rows, validation summary height, etc.)
            // can still be settling/reflowing for a frame or two after
            // endRequest fires, which would otherwise silently undo a single
            // scrollTo call.
            var target = (typeof y === 'number') ? y : __lastScrollY;
            var attempts = 0;
            function apply() {
                window.scrollTo(0, target);
                attempts++;
                if (attempts < 6) {
                    requestAnimationFrame(apply);
                }
            }
            requestAnimationFrame(apply);
        }

        // ---- Case A: genuine full page reload ----
        document.addEventListener('DOMContentLoaded', function () {
            var saved = sessionStorage.getItem('nexa_scrollpos_' + window.location.pathname);
            if (saved !== null) restoreScrollNow(parseInt(saved, 10) || 0);
        });
        window.addEventListener('load', function () {
            var saved = sessionStorage.getItem('nexa_scrollpos_' + window.location.pathname);
            if (saved !== null) restoreScrollNow(parseInt(saved, 10) || 0);
        });
        window.addEventListener('beforeunload', saveScrollNow);
        window.addEventListener('pagehide', saveScrollNow);

        var scrollSaveTimer = null;
        window.addEventListener('scroll', function () {
            clearTimeout(scrollSaveTimer);
            scrollSaveTimer = setTimeout(saveScrollNow, 150);
        });

        // ---- Case B: async UpdatePanel postback (the actual dropdown case) ----
        if (window.Sys && Sys.WebForms && Sys.WebForms.PageRequestManager) {
            var prm = Sys.WebForms.PageRequestManager.getInstance();

            prm.add_beginRequest(function () {
                // Capture scroll position the instant the postback starts,
                // BEFORE MS AJAX touches the DOM/focus at all.
                saveScrollNow();

                var panel = document.getElementById('<%= upMain.ClientID %>');
                if (panel) panel.classList.add('update-fading');
            });

            prm.add_endRequest(function () {
                var overlay = document.getElementById('loadingOverlay');
                if (overlay) overlay.classList.remove('show');

                var panel = document.getElementById('<%= upMain.ClientID %>');
                if (panel) {
                    panel.classList.add('update-fade');
                    panel.classList.remove('update-fading');
                }

                initPage();

                // Re-apply the pre-postback scroll position AFTER the DOM
                // swap and MS AJAX's own focus-restore have both happened,
                // so our value wins instead of being overwritten by it.
                restoreScrollNow(__lastScrollY);
            });
        }
    </script>
</body>
</html>
