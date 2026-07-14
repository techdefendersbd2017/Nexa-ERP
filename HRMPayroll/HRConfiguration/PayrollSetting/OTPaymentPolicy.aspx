<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="OTPaymentPolicy.aspx.cs" Inherits="Nexa_ERP.HRMPayroll.HRConfiguration.PayrollSetting.OTPaymentPolicy" %>

<!DOCTYPE html>
<html>
<head runat="server">
    <title>Over Time Payment Policy Setup - NexaERP</title>

    <meta name="viewport" content="width=device-width, initial-scale=1" />

    <!-- Bootstrap -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet" />
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>

    <!-- Bootstrap Icons -->
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css" />

    <!-- Google Font -->
    <link rel="preconnect" href="https://fonts.googleapis.com" />
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet" />

    <!-- math.js: used ONLY client-side to safely preview/test a formula before saving. It never executes arbitrary JS - it only parses math expressions. -->
    <script src="https://cdnjs.cloudflare.com/ajax/libs/mathjs/12.4.2/math.min.js"></script>

<style>
    :root {
        --brand-primary: #0d6efd;
        --brand-primary-dark: #0b5ed7;
        --brand-success: #198754;
        --brand-success-dark: #157347;
        --brand-warning: #fd7e14;
        --brand-warning-dark: #e8590c;
        --surface: #ffffff;
        --page-bg: #f2f4f8;
        --border-soft: #e6e9ef;
        --text-muted: #6b7280;
    }

    * {
        font-family: 'Inter', 'Segoe UI', Roboto, Arial, sans-serif;
    }

    body {
        background: var(--page-bg);
        margin: 0;
        padding: 0;
        color: #1f2937;
    }

    .main-container {
        min-height: 100vh;
        padding: 20px;
    }

    .page-heading {
        display: flex;
        align-items: center;
        gap: 10px;
        margin-bottom: 16px;
    }

    .page-heading i {
        font-size: 1.4rem;
        color: var(--brand-primary);
    }

    .page-heading h3 {
        margin: 0;
        font-weight: 700;
        font-size: 1.35rem;
        color: #111827;
    }

    .page-heading small {
        display: block;
        color: var(--text-muted);
        font-weight: 400;
        font-size: 0.8rem;
    }

    .card {
        border: 1px solid var(--border-soft);
        border-radius: 14px;
        overflow: hidden;
        box-shadow: 0 2px 10px rgba(17, 24, 39, 0.06);
    }

    .card-header {
        border: none;
        padding: 14px 20px;
        display: flex;
        align-items: center;
        gap: 10px;
    }

    .card-header.bg-primary {
        background: linear-gradient(135deg, var(--brand-primary), var(--brand-primary-dark)) !important;
    }

    .card-header.bg-success {
        background: linear-gradient(135deg, var(--brand-success), var(--brand-success-dark)) !important;
    }

    .card-header.bg-warning {
        background: linear-gradient(135deg, var(--brand-warning), var(--brand-warning-dark)) !important;
    }

    .card-header h4 {
        font-size: 1.05rem;
        font-weight: 600;
        letter-spacing: 0.2px;
    }

    .card-header i {
        font-size: 1.1rem;
    }

    label {
        font-weight: 600;
        font-size: 0.85rem;
        color: #374151;
        margin-bottom: 6px;
        display: block;
    }

    .form-control,
    .form-select {
        border-radius: 8px;
        border: 1px solid #d7dce3;
        padding: 9px 12px;
        font-size: 0.92rem;
        transition: border-color 0.15s ease, box-shadow 0.15s ease;
    }

    .form-control:focus,
    .form-select:focus {
        border-color: var(--brand-primary);
        box-shadow: 0 0 0 0.2rem rgba(13, 110, 253, 0.15);
    }

    .form-control[readonly] {
        background-color: #f3f4f6;
        color: #6b7280;
    }

    .btn {
        border-radius: 8px;
        font-weight: 600;
        font-size: 0.9rem;
        padding: 8px 20px;
    }

    .btn-success {
        background: linear-gradient(135deg, var(--brand-success), var(--brand-success-dark));
        border: none;
    }

    .btn-secondary {
        background-color: #eef0f3;
        border: 1px solid #d7dce3;
        color: #374151;
    }

    .btn-secondary:hover {
        background-color: #e2e5ea;
        color: #111827;
    }

    .form-check-input:checked {
        background-color: var(--brand-success);
        border-color: var(--brand-success);
    }

    .left-panel {
        max-height: calc(100vh - 220px);
        overflow-y: auto;
        padding: 22px;
    }

    .right-panel {
        height: 100%;
    }

    .action-bar {
        border-top: 1px solid var(--border-soft);
        margin-top: 20px;
        padding-top: 16px;
    }

    .grid-wrapper {
        max-height: calc(100vh - 220px);
        overflow-y: auto;
        overflow-x: auto;
    }

    .grid-wrapper table {
        margin-bottom: 0;
        white-space: nowrap;
        font-size: 0.88rem;
    }

    .grid-wrapper th {
        position: sticky;
        top: 0;
        background: linear-gradient(135deg, var(--brand-primary), var(--brand-primary-dark)) !important;
        color: #fff !important;
        z-index: 100;
        font-weight: 600;
        font-size: 0.82rem;
        text-transform: uppercase;
        letter-spacing: 0.4px;
        padding: 12px 14px;
        border: none;
    }

    .grid-wrapper td {
        padding: 10px 14px;
        vertical-align: middle;
        color: #374151;
    }

    .grid-wrapper tbody tr:hover {
        background-color: #f0f6ff;
    }

    .grid-wrapper .table-bordered > :not(caption) > * > * {
        border-width: 0 0 1px 0;
        border-color: var(--border-soft);
    }

    /* Table custom command select button styling to match design */
    .grid-wrapper table a {
        text-decoration: none;
        font-weight: 600;
        color: var(--brand-primary);
    }
    .grid-wrapper table a:hover {
        color: var(--brand-primary-dark);
    }

    /* ---- Formula Builder / Tester additions ---- */
    .var-token-btn {
        border: 1px solid #cfe0ff;
        background: #eef4ff;
        color: var(--brand-primary-dark);
        font-weight: 600;
        font-size: 0.8rem;
        border-radius: 20px;
        padding: 5px 12px;
        margin: 3px;
        cursor: pointer;
        transition: all 0.15s ease;
        display: inline-block;
    }

    .var-token-btn:hover {
        background: var(--brand-primary);
        color: #fff;
        border-color: var(--brand-primary);
    }

    .var-token-btn small {
        display: block;
        font-weight: 400;
        font-size: 0.68rem;
        color: #6b7280;
    }

    .var-token-btn:hover small {
        color: #e6efff;
    }

    #txtOTFormulaTester {
        font-family: 'Consolas', 'Courier New', monospace;
    }

    .formula-result-box {
        border-radius: 8px;
        padding: 12px 16px;
        font-weight: 600;
        font-size: 0.95rem;
        border: 1px dashed #cfe0ff;
        background: #f8fafd;
        min-height: 46px;
        display: flex;
        align-items: center;
    }

    .formula-result-box.result-ok {
        border-color: #b7e4c7;
        background: #f0fdf4;
        color: #157347;
    }

    .formula-result-box.result-error {
        border-color: #f5c2c7;
        background: #fdf3f3;
        color: #b02a37;
    }

    .test-var-row {
        display: flex;
        align-items: center;
        gap: 8px;
        margin-bottom: 8px;
    }

    .test-var-row label {
        margin-bottom: 0;
        min-width: 150px;
        font-size: 0.82rem;
    }

    /* Tablet & Mobile */
    @media (max-width: 991.98px) {
        .main-container {
            height: auto;
            padding: 14px;
        }

        .card {
            height: auto !important;
            margin-bottom: 15px;
        }

        .left-panel,
        .grid-wrapper {
            max-height: none;
            overflow: visible;
        }

        .grid-wrapper {
            overflow-x: auto;
        }

        .action-bar .btn {
            width: 100%;
        }
    }

    @media (max-width: 575.98px) {
        .page-heading h3 {
            font-size: 1.1rem;
        }

        .card-header h4 {
            font-size: 0.95rem;
        }

        .left-panel {
            padding: 16px;
        }

        .action-bar {
            display: flex;
            flex-direction: column;
            gap: 8px;
        }

        .test-var-row {
            flex-direction: column;
            align-items: flex-start;
        }

        .test-var-row label {
            min-width: 0;
        }
    }
</style>
</head>
<body>
<form id="form1" runat="server">
<asp:ScriptManager ID="ScriptManager1" runat="server"></asp:ScriptManager>

<div class="container-fluid main-container">

    <!-- Title Heading with bi-clock-history icon -->
    <div class="page-heading">
        <i class="bi bi-clock-history"></i>
        <div>
            <h3>Over Time Payment Policy Setup</h3>
            <small>HRM Configuration &rsaquo; HRM Setting &rsaquo; OT Payment Policy</small>
        </div>
    </div>

    <div class="row">

        <!-- Left Side Form Section -->
        <div class="col-12 col-lg-5 mb-3">

            <div class="card shadow">

                <div class="card-header bg-primary text-white">
                    <i class="bi bi-gear-fill"></i>
                    <h4 class="mb-0">Policy Information</h4>
                </div>

                <div class="card-body left-panel">

                    <asp:HiddenField ID="hfOTPolicyId" runat="server" />

                    <div class="row g-3">

                        <div class="col-12">
                            <label>OT Policy Name <span class="text-danger">*</span></label>
                            <asp:TextBox ID="txtOTPolicyName" runat="server" CssClass="form-control" placeholder="e.g., General Shift OT, Double OT" />
                        </div>

                        <div class="col-12">
                            <label>OT Payment Type <span class="text-danger">*</span></label>
                            <asp:DropDownList ID="ddlOTPaymentType" runat="server" CssClass="form-select">
                                <asp:ListItem Value="1">Fixed Rate Per Hour</asp:ListItem>
                                <asp:ListItem Value="2">% of Basic Salary</asp:ListItem>
                                <asp:ListItem Value="3">% of Gross Salary</asp:ListItem>
                                <asp:ListItem Value="4">Formula Driven</asp:ListItem>
                            </asp:DropDownList>
                        </div>

                        <div class="col-12">
                            <label>Rate / Percentage Value <span class="text-danger">*</span></label>
                            <asp:TextBox ID="txtOTValue" runat="server" CssClass="form-control" type="number" step="0.01" placeholder="0.00" Text="0.00" />
                        </div>

                        <div class="col-12">
                            <label>OT Calculation Formula</label>
                            <asp:TextBox ID="txtOTFormula" runat="server" CssClass="form-control" TextMode="MultiLine" Rows="2" placeholder="e.g., (({Basic} / 208) * 2) * {OTHours}" Text="(({Basic} / 208) * 2) * {OTHours}" />
                            <small class="text-muted">Prefilled with Bangladesh Labour Law's standard OT formula. Click a variable badge below (in the Formula Builder card) to insert more variables at your cursor position.</small>
                        </div>

                        <div class="col-12">
                            <div class="form-check mt-2">
                                <asp:CheckBox ID="chkOTIsActive" runat="server" CssClass="form-check-input" Checked="true" />
                                <asp:Label runat="server" AssociatedControlID="chkOTIsActive" Text="Is Active Policy" CssClass="form-check-label" />
                            </div>
                        </div>

                    </div>

                    <div class="mt-4 d-flex justify-content-between align-items-center action-bar">
                        <asp:Button ID="btnOTClear" runat="server" Text="Refresh" CssClass="btn btn-success" OnClick="btnOTClear_Click" />
                        <asp:Button ID="btnOTSave" runat="server" Text="Save Policy" CssClass="btn btn-success" OnClick="btnOTSave_Click" />
                    </div>

                </div>

            </div>

        </div>

        <!-- Right Side Grid View Section -->
        <div class="col-12 col-lg-7 mb-3">

            <div class="card shadow right-panel">

                <div class="card-header bg-success text-white">
                    <i class="bi bi-clock-history"></i>
                    <h4 class="mb-0">Existing Over Time Policies</h4>
                </div>

                <div class="grid-wrapper">
                    <asp:GridView ID="gvOTPolicies" 
                        runat="server" 
                        AutoGenerateColumns="False" 
                        CssClass="table table-bordered table-hover" 
                        DataKeyNames="OT_Policy_Code"
                        Width="100%"
                        OnSelectedIndexChanged="gvOTPolicies_SelectedIndexChanged">
                        
                        <Columns>
                            <asp:CommandField ShowSelectButton="True" SelectText="Select">
                                <ItemStyle Width="80px" HorizontalAlign="Center" />
                            </asp:CommandField>

                            <asp:BoundField DataField="OT_Policy_Code" HeaderText="Policy ID">
                                <ItemStyle Width="110px" HorizontalAlign="Center" />
                                <HeaderStyle HorizontalAlign="Center" />
                            </asp:BoundField>
                            
                            <asp:BoundField DataField="OT_Policy_Name" HeaderText="OT Policy Name" />
                        </Columns>

                        <EmptyDataTemplate>
                            <div class="p-4 text-center text-muted">
                                <i class="bi bi-exclamation-circle me-1"></i> No Over Time policies found.
                            </div>
                        </EmptyDataTemplate>

                    </asp:GridView>
                </div>

            </div>

        </div>

    </div>

    <!-- Dynamic Formula Builder & Live Tester -->
    <div class="row">
        <div class="col-12 col-lg-5 mb-3">
            <div class="card shadow">
                <div class="card-header bg-warning text-white">
                    <i class="bi bi-magic"></i>
                    <h4 class="mb-0">Formula Builder - Available Variables</h4>
                </div>
                <div class="card-body">
                    <p class="text-muted mb-2" style="font-size:0.85rem;">
                        Click any variable to insert it into the <strong>OT Calculation Formula</strong> box on the left, at your current cursor position.
                    </p>
                    <div id="variablePalette">
                        <span class="var-token-btn" data-token="{Basic}">Basic<small>Basic Salary</small></span>
                        <span class="var-token-btn" data-token="{Gross}">Gross<small>Gross Salary</small></span>
                        <span class="var-token-btn" data-token="{HourlyRate}">HourlyRate<small>Basic / (WorkingDays*WorkingHours)</small></span>
                        <span class="var-token-btn" data-token="{OTHours}">OTHours<small>Total OT hours worked</small></span>
                        <span class="var-token-btn" data-token="{WorkingDays}">WorkingDays<small>Working days in month</small></span>
                        <span class="var-token-btn" data-token="{WorkingHours}">WorkingHours<small>Working hours per day</small></span>
                        <span class="var-token-btn" data-token="{OTRate}">OTRate<small>Rate/% value from the form</small></span>
                    </div>
                    <hr />
                    <p class="text-muted mb-1" style="font-size:0.8rem;">
                        <i class="bi bi-info-circle"></i>
                        You may combine variables with <code>+ - * / ( )</code> and numbers, e.g. (Bangladesh Labour Law standard OT rate):
                    </p>
                    <code style="font-size:0.8rem;">(({Basic} / 208) * 2) * {OTHours}</code>
                    <p class="text-muted mt-2 mb-0" style="font-size:0.75rem;">
                        <strong>208</strong> = standard monthly working hours (26 working days &times; 8 hours/day), and OT is paid at <strong>double</strong> the per-hour basic rate.
                    </p>
                </div>
            </div>
        </div>

        <div class="col-12 col-lg-7 mb-3">
            <div class="card shadow">
                <div class="card-header bg-primary text-white">
                    <i class="bi bi-calculator"></i>
                    <h4 class="mb-0">Test Your Formula</h4>
                </div>
                <div class="card-body">
                    <p class="text-muted mb-2" style="font-size:0.85rem;">
                        Enter sample values below and test the formula currently typed in the form on the left - before saving it.
                    </p>

                    <div class="test-var-row">
                        <label>Basic Salary</label>
                        <input type="number" class="form-control form-control-sm test-var-input" id="tv_Basic" value="20000" />
                    </div>
                    <div class="test-var-row">
                        <label>Gross Salary</label>
                        <input type="number" class="form-control form-control-sm test-var-input" id="tv_Gross" value="30000" />
                    </div>
                    <div class="test-var-row">
                        <label>OT Hours</label>
                        <input type="number" class="form-control form-control-sm test-var-input" id="tv_OTHours" value="10" />
                    </div>
                    <div class="test-var-row">
                        <label>Working Days (Month)</label>
                        <input type="number" class="form-control form-control-sm test-var-input" id="tv_WorkingDays" value="26" />
                    </div>
                    <div class="test-var-row">
                        <label>Working Hours (Per Day)</label>
                        <input type="number" class="form-control form-control-sm test-var-input" id="tv_WorkingHours" value="8" />
                    </div>
                    <div class="test-var-row">
                        <label>OT Rate / Percentage</label>
                        <input type="number" class="form-control form-control-sm test-var-input" id="tv_OTRate" value="2" />
                    </div>

                    <button type="button" id="btnTestFormula" class="btn btn-success btn-sm mt-2 mb-3">
                        <i class="bi bi-play-fill"></i> Test Formula
                    </button>

                    <label>Result</label>
                    <div id="formulaResultBox" class="formula-result-box">
                        Result will appear here after you click "Test Formula".
                    </div>
                </div>
            </div>
        </div>
    </div>

</div>

<script>
    // Inserts a variable token into the formula textbox at the current cursor position.
    (function () {
        var paletteButtons = document.querySelectorAll('#variablePalette .var-token-btn');
        var lastCaretPos = null;

        function getFormulaTextArea() {
            // ASP.NET renders server IDs with a ContentPlaceHolder/naming-container prefix,
            // so we find the control by the part of its ID that always stays the same.
            var all = document.querySelectorAll('textarea');
            for (var i = 0; i < all.length; i++) {
                if (all[i].id.indexOf('txtOTFormula') !== -1) {
                    return all[i];
                }
            }
            return null;
        }

        var formulaBox = getFormulaTextArea();

        if (formulaBox) {
            formulaBox.addEventListener('keyup', function () { lastCaretPos = formulaBox.selectionStart; });
            formulaBox.addEventListener('click', function () { lastCaretPos = formulaBox.selectionStart; });
            formulaBox.addEventListener('blur', function () { lastCaretPos = formulaBox.selectionStart; });
        }

        paletteButtons.forEach(function (btn) {
            btn.addEventListener('click', function () {
                if (!formulaBox) { return; }
                var token = btn.getAttribute('data-token');
                var pos = (lastCaretPos !== null) ? lastCaretPos : formulaBox.value.length;
                var current = formulaBox.value;
                formulaBox.value = current.slice(0, pos) + token + current.slice(pos);
                var newPos = pos + token.length;
                formulaBox.focus();
                formulaBox.setSelectionRange(newPos, newPos);
                lastCaretPos = newPos;
            });
        });

        // ---- Live formula tester ----
        var testBtn = document.getElementById('btnTestFormula');
        var resultBox = document.getElementById('formulaResultBox');

        testBtn.addEventListener('click', function () {
            if (!formulaBox) {
                showResult('Formula box not found on page.', false);
                return;
            }

            var rawFormula = formulaBox.value || '';

            if (rawFormula.trim() === '') {
                showResult('Please type a formula first.', false);
                return;
            }

            var values = {
                '{Basic}': document.getElementById('tv_Basic').value,
                '{Gross}': document.getElementById('tv_Gross').value,
                '{OTHours}': document.getElementById('tv_OTHours').value,
                '{WorkingDays}': document.getElementById('tv_WorkingDays').value,
                '{WorkingHours}': document.getElementById('tv_WorkingHours').value,
                '{OTRate}': document.getElementById('tv_OTRate').value
            };
            // HourlyRate is a derived convenience variable, computed from the others.
            var workingDaysNum = parseFloat(values['{WorkingDays}']) || 0;
            var workingHoursNum = parseFloat(values['{WorkingHours}']) || 0;
            var basicNum = parseFloat(values['{Basic}']) || 0;
            var hourlyRate = (workingDaysNum * workingHoursNum) > 0
                ? (basicNum / (workingDaysNum * workingHoursNum))
                : 0;
            values['{HourlyRate}'] = hourlyRate;

            var expression = rawFormula;
            Object.keys(values).forEach(function (token) {
                var safeVal = values[token];
                if (safeVal === '' || safeVal === null || isNaN(parseFloat(safeVal))) {
                    safeVal = 0;
                }
                // split/join avoids regex special-character issues with the {} token characters.
                expression = expression.split(token).join('(' + safeVal + ')');
            });

            // Safety check: after substitution, only numbers/operators/parentheses/spaces/decimal points
            // should remain. If any other characters are left, either the formula used an
            // unrecognized {Variable} or contains characters we won't evaluate.
            var leftoverTokenMatch = expression.match(/\{[^}]*\}/);
            if (leftoverTokenMatch) {
                showResult('Unknown variable used: ' + leftoverTokenMatch[0], false);
                return;
            }

            if (!/^[0-9+\-*/().\s]+$/.test(expression)) {
                showResult('Formula contains characters that are not allowed. Only variables, numbers and + - * / ( ) are supported.', false);
                return;
            }

            try {
                var result = math.evaluate(expression);
                if (typeof result !== 'number' || !isFinite(result)) {
                    showResult('Formula did not produce a valid number.', false);
                    return;
                }
                showResult('OT Payment Amount = ' + result.toFixed(2), true);
            } catch (ex) {
                showResult('Could not evaluate formula: ' + ex.message, false);
            }
        });

        function showResult(message, isOk) {
            resultBox.textContent = message;
            resultBox.classList.remove('result-ok', 'result-error');
            resultBox.classList.add(isOk ? 'result-ok' : 'result-error');
        }
    })();
</script>

</form>
</body>
</html>
