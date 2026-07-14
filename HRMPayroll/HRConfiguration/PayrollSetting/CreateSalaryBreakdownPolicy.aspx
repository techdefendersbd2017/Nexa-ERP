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

<style>
    :root {
        --brand-primary: #0d6efd;
        --brand-primary-dark: #0b5ed7;
        --brand-success: #198754;
        --brand-success-dark: #157347;
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

    .grid-wrapper table a {
        text-decoration: none;
        font-weight: 600;
        color: var(--brand-primary);
    }
    
    .grid-wrapper table a:hover {
        text-decoration: underline;
        color: var(--brand-primary-dark);
    }

    /* Suggestions Container & Badges Styling */
    .suggestion-box {
        background-color: #f9fafb;
        border: 1px dashed #d1d5db;
        border-radius: 8px;
        padding: 10px 12px;
        margin-top: 8px;
    }

    .suggestion-title {
        font-size: 0.75rem;
        font-weight: 700;
        color: #4b5563;
        text-transform: uppercase;
        letter-spacing: 0.5px;
        margin-bottom: 6px;
    }

    .formula-badge {
        display: inline-block;
        background-color: #fff;
        border: 1px solid #e5e7eb;
        color: var(--brand-primary);
        font-family: 'Courier New', Courier, monospace;
        font-size: 0.8rem;
        font-weight: 600;
        padding: 4px 8px;
        border-radius: 6px;
        margin-right: 6px;
        margin-bottom: 6px;
        cursor: pointer;
        transition: all 0.15s ease;
        box-shadow: 0 1px 2px rgba(0,0,0,0.05);
    }

    .formula-badge:hover {
        background-color: var(--brand-primary);
        color: #fff;
        border-color: var(--brand-primary);
        transform: translateY(-1px);
    }

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
    }
</style>
</head>
<body>
<form id="form1" runat="server">
<asp:ScriptManager ID="ScriptManager1" runat="server"></asp:ScriptManager>

<div class="container-fluid main-container">

    <!-- Title Heading -->
    <div class="page-heading">
        <i class="bi bi-clock-history"></i>
        <div>
            <h3>Over Time Payment Policy Setup</h3>
            <small>HRM Configuration &rsaquo; HRM Setting &rsaquo; OT Payment Policy</small>
        </div>
    </div>

    <div class="row">

        <!-- Left Side Form Section -->
        <div class="col-12 col-lg-6 mb-3">

            <div class="card shadow">

                <div class="card-header bg-primary text-white">
                    <i class="bi bi-gear-fill"></i>
                    <h4 class="mb-0">Policy Information</h4>
                </div>

                <div class="card-body left-panel">

                    <asp:HiddenField ID="hfOTPolicyId" runat="server" />

                    <div class="row g-3">

                        <div class="col-md-6">
                            <label>OT Policy Name <span class="text-danger">*</span></label>
                            <asp:TextBox ID="txtOTPolicyName" runat="server" CssClass="form-control" placeholder="e.g., General Shift OT" />
                        </div>

                        <div class="col-md-6">
                            <label>OT Payment Type <span class="text-danger">*</span></label>
                            <asp:DropDownList ID="ddlOTPaymentType" runat="server" CssClass="form-select">
                                <asp:ListItem Value="1">Fixed Rate Per Hour</asp:ListItem>
                                <asp:ListItem Value="2">% of Basic Salary</asp:ListItem>
                                <asp:ListItem Value="3">% of Gross Salary</asp:ListItem>
                                <asp:ListItem Value="4">Formula Driven</asp:ListItem>
                            </asp:DropDownList>
                        </div>

                        <div class="col-md-6">
                            <label>Rate / Percentage Value <span class="text-danger">*</span></label>
                            <asp:TextBox ID="txtOTValue" runat="server" CssClass="form-control" type="number" step="0.01" placeholder="0.00" Text="0.00" />
                        </div>

                        <div class="col-md-6">
                            <div class="form-check mt-4">
                                <asp:CheckBox ID="chkOTIsActive" runat="server" CssClass="form-check-input" Checked="true" />
                                <asp:Label runat="server" AssociatedControlID="chkOTIsActive" Text="Is Active Policy" CssClass="form-check-label" />
                            </div>
                        </div>

                        <!-- Formula Field with Interactive Suggestion Tags -->
                        <div class="col-12">
                            <label>OT Calculation Formula</label>
                            <asp:TextBox ID="txtOTFormula" runat="server" CssClass="form-control" TextMode="MultiLine" Rows="2" placeholder="e.g., ((Basic / 208) * 1.5) * OTHours" />
                            
                            <!-- Suggestions Container -->
                            <div class="suggestion-box">
                                <div class="suggestion-title"><i class="bi bi-lightning-charge-fill text-warning me-1"></i> Click tags to insert variables:</div>
                                <span class="formula-badge" onclick="insertVariable('[Basic]')">[Basic]</span>
                                <span class="formula-badge" onclick="insertVariable('[Gross]')">[Gross]</span>
                                <span class="formula-badge" onclick="insertVariable('[OTHours]')">[OTHours]</span>
                                <span class="formula-badge" onclick="insertVariable('[FixedRate]')">[FixedRate]</span>
                                <span class="formula-badge" onclick="insertVariable('208')">208 (Std Hours)</span>
                                <span class="formula-badge" onclick="insertVariable('1.5')">1.5 (Double Rate)</span>
                            </div>
                        </div>

                    </div>

                    <div class="mt-4 d-flex justify-content-between align-items-center action-bar">
                        <asp:Button ID="btnOTClear" runat="server" Text="Refresh" CssClass="btn btn-secondary" OnClick="btnOTClear_Click" />
                        <asp:Button ID="btnOTSave" runat="server" Text="Save" CssClass="btn btn-success" OnClick="btnOTSave_Click" />
                    </div>

                </div>

            </div>

        </div>

        <!-- Right Side Grid View Section -->
        <div class="col-12 col-lg-6 mb-3">

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
                                <ItemStyle Width="80px" />
                            </asp:CommandField>

                            <asp:BoundField DataField="OT_Policy_Code" HeaderText="Policy ID" />
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

</div>

<!-- JavaScript to append variable tags into Formula MultiLine box -->
<script type="text/javascript">
    function insertVariable(val) {
        var txtFormula = document.getElementById('<%= txtOTFormula.ClientID %>');
        if (txtFormula) {
            // Append with space for clean layout
            if (txtFormula.value.length > 0 && !txtFormula.value.endsWith(' ')) {
                txtFormula.value += ' ';
            }
            txtFormula.value += val + ' ';
            txtFormula.focus();
        }
    }
</script>
</form>
</body>
</html>