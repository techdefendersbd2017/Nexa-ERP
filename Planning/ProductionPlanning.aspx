<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ProductionPlanning.aspx.cs" Inherits="Nexa_ERP.Planning.ProductionPlanning" %>

<!DOCTYPE html>
<html>
<head runat="server">
    <title>Production Planning</title>
    <!-- Bootstrap 5 CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet" />
    <!-- Select2 CSS -->
    <link href="https://cdn.jsdelivr.net/npm/select2@4.1.0-rc.0/dist/css/select2.min.css" rel="stylesheet" />
    <!-- Select2 Bootstrap 5 Theme -->
    <link href="https://cdn.jsdelivr.net/npm/select2-bootstrap-5-theme@1.3.0/dist/select2-bootstrap-5-theme.min.css" rel="stylesheet" />
    <!-- jQuery (must load before Select2 JS) -->
    <script src="https://cdnjs.cloudflare.com/ajax/libs/jquery/3.6.0/jquery.min.js"></script>
    <!-- Select2 JS -->
    <script src="https://cdn.jsdelivr.net/npm/select2@4.1.0-rc.0/dist/js/select2.min.js"></script>
    <style>
        body {
            background-color: #f4f6f9;
            font-size: 14px;
        }
        /* ================= CARD / HEADER ================= */
        .card-header-custom 
        {
            background: linear-gradient(135deg, #1f4e78 0%, #2c6ca3 100%);
            color: #fff;
            font-weight: bold;
            letter-spacing: 0.3px;
        }
        .card 
        {
            border: none;
            border-radius: 10px;
            overflow: hidden;
        }
        .card-body 
        {
            background-color: #ffffff;
        }
        /* ================= TABLE / GRID ================= */
        .table-dark-custom 
        {
            background-color: #1f4e78;
            color: white;
        }
        .grid 
        {
            width: 100%;
            background: white;
            border: 1px solid #dee2e6;
            border-radius: 6px;
            overflow: hidden;
        }
        .grid th 
        {
            background-color: #1f4e78;
            color: white;
            padding: 10px;
        }
        .grid td 
        {
            padding: 8px;
            border-bottom: 1px solid #eef0f2;
            vertical-align: middle;
        }

        /* ================= PANEL SWITCH ================= */
        .panel { display: none; }
        .panel.active { display: block; }

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
            width: auto;
        }

        .form-label.small.fw-bold {
            font-size: 0.78rem;
            text-transform: uppercase;
            letter-spacing: 0.3px;
            color: #495057;
        }

        /* ================= ENTRY ROW (process / material tables) ================= */
        .entry-row {
            background: linear-gradient(180deg, #f7fafd 0%, #eef3f9 100%);
            border: 1px solid #dbe6f2;
            border-radius: 10px;
            padding: 16px 14px 12px 14px;
            margin-bottom: 14px;
            box-shadow: 0 1px 3px rgba(31, 78, 120, 0.06);
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

        /* Select2 -> rounded modern textbox look */
        .select2-container--bootstrap-5 .select2-selection {
            border-radius: 0.375rem !important;
            min-height: calc(1.5em + 0.5rem + 2px);
            padding: 0.25rem 0.5rem;
            font-size: 0.875rem;
            border: 1px solid #ced4da;
            background-image: none !important;
        }
        .select2-container--bootstrap-5 .select2-dropdown {
            border-radius: 0.5rem !important;
            box-shadow: 0 0.5rem 1rem rgba(0, 0, 0, 0.15);
            border: 1px solid #86b7fe;
            padding: 6px;
        }

        /* ================= ACTION BUTTONS FOOTER ================= */
        .form-footer-actions {
            border-top: 1px solid #e9ecef;
            padding-top: 16px;
            margin-top: 8px;
        }

        /* ================= VALIDATION ================= */
        .field-error {
            border-color: #dc3545 !important;
            background-color: #fff5f5 !important;
        }
        .error-message {
            color: #dc3545;
            font-size: 12px;
            margin-top: 4px;
            display: none;
        }
        .error-message.show { display: block; }

        .required-mark { color: #dc3545; margin-left: 3px; }

        .badge-success { background-color: #16a34a; }
        .badge-warning { background-color: #eab308; color: #000; }

        .empty-state {
            text-align: center;
            padding: 30px;
            color: #6c757d;
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <div class="container my-4">

            <!-- ================= 1. LIST PANEL ================= -->
            <div id="pnlList" class="panel active">
                <div class="list-toolbar">
                    <div class="list-title">Production Order List</div>
                    <div class="d-flex align-items-center gap-2">
                        <label class="form-label mb-0 small fw-bold">Filter Status:</label>
                        <select id="statusFilter" class="form-select form-select-sm" style="width: 160px;" onchange="filterOrders()">
                            <option value="all">All Orders</option>
                            <option value="not-planned">Not Planned</option>
                            <option value="planned">Planned</option>
                        </select>
                        <button type="button" class="btn btn-success btn-sm" onclick="showPanel('pnlForm')">+ Add New Plan</button>
                    </div>
                </div>

                <div id="listAlert" class="alert d-none" role="alert"></div>

                <div class="table-responsive">
                    <table class="grid table table-bordered table-sm mb-0 text-center align-middle">
                        <thead>
                            <tr>
                                <th>Sales Order</th>
                                <th>Buyer</th>
                                <th>Product</th>
                                <th>Delivery Date</th>
                                <th>Plan Status</th>
                                <th>Action</th>
                            </tr>
                        </thead>
                        <tbody id="orderTableBody">
                            <tr class="order-row not-planned">
                                <td>SO-2026-101</td>
                                <td>Fashion Hub</td>
                                <td>Men's T-Shirt</td>
                                <td>10 Sep 2026</td>
                                <td><span class="badge badge-warning">Not Planned</span></td>
                                <td>
                                    <button type="button" class="btn btn-primary btn-sm" onclick="openPlanForm('SO-2026-101', 'Fashion Hub', 'Men\'s T-Shirt')">Add Plan</button>
                                    <button type="button" class="btn btn-danger btn-sm" onclick="removeOrder(this)">Remove</button>
                                </td>
                            </tr>
                            <tr class="order-row not-planned">
                                <td>SO-2026-102</td>
                                <td>Global Apparels</td>
                                <td>Denim Jeans</td>
                                <td>15 Sep 2026</td>
                                <td><span class="badge badge-warning">Not Planned</span></td>
                                <td>
                                    <button type="button" class="btn btn-primary btn-sm" onclick="openPlanForm('SO-2026-102', 'Global Apparels', 'Denim Jeans')">Add Plan</button>
                                    <button type="button" class="btn btn-danger btn-sm" onclick="removeOrder(this)">Remove</button>
                                </td>
                            </tr>
                            <tr class="order-row planned">
                                <td>SO-2026-095</td>
                                <td>NextGen Style</td>
                                <td>Winter Jacket</td>
                                <td>25 Aug 2026</td>
                                <td><span class="badge badge-success">Planned</span></td>
                                <td>
                                    <button type="button" class="btn btn-info btn-sm text-white" onclick="openPlanForm('SO-2026-095', 'NextGen Style', 'Winter Jacket')">View Plan</button>
                                    <button type="button" class="btn btn-danger btn-sm" onclick="removeOrder(this)">Remove</button>
                                </td>
                            </tr>
                        </tbody>
                    </table>
                </div>
            </div>

            <!-- ================= 2. FORM PANEL ================= -->
            <div id="pnlForm" class="panel">
                <div class="card shadow-sm">
                    <div class="card-header card-header-custom text-center py-2 d-flex justify-content-between align-items-center">
                        <span>Production Plan Form</span>
                        <button type="button" class="btn btn-light btn-sm text-dark fw-bold" onclick="showPanel('pnlList')">&larr; Back to List</button>
                    </div>
                    <div class="card-body p-4">

                        <div id="formAlert" class="alert d-none" role="alert"></div>

                        <!-- ============ SECTION 1: HEADER INFO ============ -->
                        <fieldset class="section-box">
                            <legend>Plan Header Info</legend>
                            <div class="row g-3">
                                <div class="col-md-3">
                                    <label class="form-label fw-bold">Plan No.</label>
                                    <input type="text" class="form-control form-control-sm" placeholder="Auto Generated" readonly style="background:#f8fafc;">
                                </div>
                                <div class="col-md-3">
                                    <label class="form-label fw-bold">Plan Date <span class="required-mark">*</span></label>
                                    <input type="date" id="currentDate" class="form-control form-control-sm" data-required="true">
                                    <span class="error-message">Plan Date is required.</span>
                                </div>
                                <div class="col-md-3">
                                    <label class="form-label fw-bold">Sales Order</label>
                                    <input type="text" id="formSO" class="form-control form-control-sm" placeholder="SO Number" readonly style="background:#f8fafc;">
                                </div>
                                <div class="col-md-3">
                                    <label class="form-label fw-bold">Priority</label>
                                    <select id="formPriority" class="form-select form-select-sm searchable-dropdown">
                                        <option value="normal">Normal</option>
                                        <option value="high">High</option>
                                        <option value="urgent">Urgent</option>
                                    </select>
                                </div>

                                <div class="col-md-3">
                                    <label class="form-label fw-bold">Buyer <span class="required-mark">*</span></label>
                                    <input type="text" id="formBuyer" class="form-control form-control-sm" placeholder="Enter Buyer Name" data-required="true">
                                    <span class="error-message">Buyer is required.</span>
                                </div>
                                <div class="col-md-3">
                                    <label class="form-label fw-bold">Product <span class="required-mark">*</span></label>
                                    <input type="text" id="formProduct" class="form-control form-control-sm" placeholder="Product Name/Code" data-required="true">
                                    <span class="error-message">Product is required.</span>
                                </div>
                                <div class="col-md-3">
                                    <label class="form-label fw-bold">Delivery Date <span class="required-mark">*</span></label>
                                    <input type="date" id="formDeliveryDate" class="form-control form-control-sm" data-required="true">
                                    <span class="error-message">Delivery Date is required.</span>
                                </div>
                                <div class="col-md-3">
                                    <label class="form-label fw-bold">Production Line <span class="required-mark">*</span></label>
                                    <input type="text" id="formProductionLine" class="form-control form-control-sm" placeholder="e.g. Line 1" data-required="true">
                                    <span class="error-message">Production Line is required.</span>
                                </div>

                                <div class="col-md-3">
                                    <label class="form-label fw-bold">Order Qty <span class="required-mark">*</span></label>
                                    <input type="number" id="formOrderQty" class="form-control form-control-sm" placeholder="0" min="1" data-required="true">
                                    <span class="error-message">Order Qty must be greater than 0.</span>
                                </div>
                                <div class="col-md-3">
                                    <label class="form-label fw-bold">Planned Qty <span class="required-mark">*</span></label>
                                    <input type="number" id="formPlannedQty" class="form-control form-control-sm" placeholder="0" min="1" data-required="true">
                                    <span class="error-message">Planned Qty must be greater than 0.</span>
                                </div>
                                <div class="col-md-3">
                                    <label class="form-label fw-bold">Start Date <span class="required-mark">*</span></label>
                                    <input type="date" id="formStartDate" class="form-control form-control-sm" data-required="true">
                                    <span class="error-message">Start Date is required.</span>
                                </div>
                                <div class="col-md-3">
                                    <label class="form-label fw-bold">End Date <span class="required-mark">*</span></label>
                                    <input type="date" id="formEndDate" class="form-control form-control-sm" data-required="true">
                                    <span class="error-message">End Date must be after Start Date.</span>
                                </div>
                            </div>
                        </fieldset>

                        <!-- ============ SECTION 2: PRODUCTION PROCESS ============ -->
                        <fieldset class="section-box">
                            <legend>Production Process</legend>
                            <div class="table-responsive">
                                <table class="table table-bordered table-sm text-center align-middle mb-0">
                                    <thead class="table-dark-custom">
                                        <tr><th>Process</th><th>Machine</th><th>Capacity</th><th>Plan Qty</th></tr>
                                    </thead>
                                    <tbody>
                                        <tr>
                                            <td>Printing</td>
                                            <td><input type="text" class="form-control form-control-sm text-center" value="PR-01"></td>
                                            <td><input type="text" class="form-control form-control-sm text-center" value="5,000/hr"></td>
                                            <td><input type="number" class="form-control form-control-sm text-center" value="50000"></td>
                                        </tr>
                                        <tr>
                                            <td>Cutting</td>
                                            <td><input type="text" class="form-control form-control-sm text-center" value="CT-01"></td>
                                            <td><input type="text" class="form-control form-control-sm text-center" value="8,000/hr"></td>
                                            <td><input type="number" class="form-control form-control-sm text-center" value="50000"></td>
                                        </tr>
                                        <tr>
                                            <td>Finishing</td>
                                            <td><input type="text" class="form-control form-control-sm text-center" value="FN-01"></td>
                                            <td><input type="text" class="form-control form-control-sm text-center" value="4,000/hr"></td>
                                            <td><input type="number" class="form-control form-control-sm text-center" value="50000"></td>
                                        </tr>
                                    </tbody>
                                </table>
                            </div>
                        </fieldset>

                        <!-- ============ SECTION 3: MATERIAL STATUS ============ -->
                        <fieldset class="section-box">
                            <legend>Material Status</legend>
                            <div class="table-responsive">
                                <table class="table table-bordered table-sm text-center align-middle mb-0">
                                    <thead class="table-dark-custom">
                                        <tr><th>Required Qty</th><th>Available</th><th>Shortage</th><th>Status</th></tr>
                                    </thead>
                                    <tbody>
                                        <tr>
                                            <td><input type="number" id="matRequired" class="form-control form-control-sm text-center" placeholder="0" oninput="calcShortage()"></td>
                                            <td><input type="number" id="matAvailable" class="form-control form-control-sm text-center" placeholder="0" oninput="calcShortage()"></td>
                                            <td><input type="number" id="matShortage" class="form-control form-control-sm text-center" placeholder="0" readonly style="color:#dc3545;"></td>
                                            <td>
                                                <select id="matStatus" class="form-select form-select-sm">
                                                    <option>Pending</option>
                                                    <option>Partial</option>
                                                    <option>Available</option>
                                                </select>
                                            </td>
                                        </tr>
                                    </tbody>
                                </table>
                            </div>

                            <div class="row justify-content-end mt-3">
                                <div class="col-md-6">
                                    <label class="form-label fw-bold">Remarks</label>
                                    <textarea id="formRemarks" class="form-control form-control-sm" rows="3" placeholder="Enter any additional notes..."></textarea>
                                </div>
                            </div>
                        </fieldset>

                        <!-- Bottom Action Buttons -->
                        <div class="d-flex gap-2 form-footer-actions flex-wrap">
                            <button type="button" class="btn btn-secondary px-4" onclick="handleAction('save')">Save</button>
                            <button type="button" class="btn btn-primary px-4" onclick="handleAction('submit')">Submit</button>
                            <button type="button" class="btn btn-success px-4" onclick="handleAction('approve')">Approve</button>
                            <button type="button" class="btn btn-dark px-4" onclick="handleAction('create')">Create Production</button>
                        </div>

                    </div>
                </div>
            </div>

        </div>
    </form>

    <script type="text/javascript">
// =====================================================================
// PANEL (List / Form) SWITCHING
// =====================================================================
function showPanel(panelId) {
    document.querySelectorAll('.panel').forEach(function(p) {
        p.classList.remove('active');
    });
    var el = document.getElementById(panelId);
    if (el) { el.classList.add('active'); }
    window.scrollTo(0, 0);
}

$(document).ready(function() {
    $('.searchable-dropdown').select2({
        theme: 'bootstrap-5',
        width: '100%'
    });
    document.getElementById('currentDate').valueAsDate = new Date();
});

function openPlanForm(soNumber, buyer, product) {
    showPanel('pnlForm');
    clearAllErrors();
    hideAlert('formAlert');

    document.getElementById('formSO').value = soNumber;
    document.getElementById('formBuyer').value = buyer;
    document.getElementById('formProduct').value = product;
}

// Filter Orders
function filterOrders() {
    var filterValue = document.getElementById('statusFilter').value;
    var rows = document.querySelectorAll('.order-row');

    rows.forEach(function(row) {
        if (filterValue === 'all' || row.classList.contains(filterValue)) {
            row.style.display = 'table-row';
        } else {
            row.style.display = 'none';
        }
    });
}

// Remove Order Row (with confirmation)
function removeOrder(btn) {
    var row = btn.closest('tr');
    var soNumber = row.querySelector('td').innerText;
    if (confirm('Are you sure you want to remove order ' + soNumber + '?')) {
        row.remove();
        showAlert('listAlert', 'Order ' + soNumber + ' removed successfully.', 'success');
        var tbody = document.getElementById('orderTableBody');
        if (tbody.querySelectorAll('.order-row').length === 0) {
            var emptyRow = document.createElement('tr');
            emptyRow.innerHTML = '<td colspan="6" class="empty-state">No orders available.</td>';
            tbody.appendChild(emptyRow);
        }
    }
}

// ---------- Form Validation ----------
function clearAllErrors() {
    document.querySelectorAll('.field-error').forEach(function(el) { el.classList.remove('field-error'); });
    document.querySelectorAll('.error-message').forEach(function(el) { el.classList.remove('show'); });
}

function showFieldError(fieldEl) {
    fieldEl.classList.add('field-error');
    var errMsg = fieldEl.parentElement.querySelector('.error-message');
    if (errMsg) errMsg.classList.add('show');
}

function clearFieldError(fieldEl) {
    fieldEl.classList.remove('field-error');
    var errMsg = fieldEl.parentElement.querySelector('.error-message');
    if (errMsg) errMsg.classList.remove('show');
}

function showAlert(elId, message, type) {
    var el = document.getElementById(elId);
    el.textContent = message;
    el.className = 'alert alert-' + (type === 'success' ? 'success' : 'danger');
    el.scrollIntoView({ behavior: 'smooth', block: 'nearest' });
}

function hideAlert(elId) {
    var el = document.getElementById(elId);
    el.className = 'alert d-none';
    el.textContent = '';
}

function validateForm() {
    clearAllErrors();
    var isValid = true;
    var firstInvalidField = null;

    var requiredFields = document.querySelectorAll('#pnlForm [data-required="true"]');
    requiredFields.forEach(function(field) {
        var value = field.value.trim();
        var invalid = false;

        if (field.type === 'number') {
            if (value === '' || parseFloat(value) <= 0) invalid = true;
        } else {
            if (value === '') invalid = true;
        }

        if (invalid) {
            showFieldError(field);
            isValid = false;
            if (!firstInvalidField) firstInvalidField = field;
        }
    });

    var startDateEl = document.getElementById('formStartDate');
    var endDateEl = document.getElementById('formEndDate');
    if (startDateEl.value && endDateEl.value && new Date(startDateEl.value) > new Date(endDateEl.value)) {
        showFieldError(endDateEl);
        isValid = false;
        if (!firstInvalidField) firstInvalidField = endDateEl;
    }

    var orderQtyEl = document.getElementById('formOrderQty');
    var plannedQtyEl = document.getElementById('formPlannedQty');
    if (orderQtyEl.value && plannedQtyEl.value && parseFloat(plannedQtyEl.value) > parseFloat(orderQtyEl.value)) {
        showFieldError(plannedQtyEl);
        isValid = false;
        if (!firstInvalidField) firstInvalidField = plannedQtyEl;
    }

    if (!isValid) {
        showAlert('formAlert', 'Please correct the highlighted fields before proceeding.', 'danger');
        if (firstInvalidField) firstInvalidField.focus();
    } else {
        hideAlert('formAlert');
    }

    return isValid;
}

$(document).on('input change', '#pnlForm [data-required="true"]', function() {
    clearFieldError(this);
});

function calcShortage() {
    var required = parseFloat(document.getElementById('matRequired').value) || 0;
    var available = parseFloat(document.getElementById('matAvailable').value) || 0;
    var shortage = required - available;
    document.getElementById('matShortage').value = shortage > 0 ? shortage : 0;
}

function handleAction(action) {
    if (!validateForm()) return;

    switch (action) {
        case 'save': showAlert('formAlert', 'Plan saved as draft successfully.', 'success'); break;
        case 'submit': showAlert('formAlert', 'Plan submitted successfully.', 'success'); break;
        case 'approve': showAlert('formAlert', 'Plan approved successfully.', 'success'); break;
        case 'create': showAlert('formAlert', 'Production created successfully.', 'success'); break;
    }
        }
    </script>
</body>
</html>
