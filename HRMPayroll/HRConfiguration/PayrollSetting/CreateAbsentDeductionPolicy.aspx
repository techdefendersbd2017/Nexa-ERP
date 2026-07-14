<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="CreateAbsentDeductionPolicy.aspx.cs" Inherits="Nexa_ERP.HRMPayroll.HRConfiguration.PayrollSetting.CreateAbsentDeductionPolicy" %>

<!DOCTYPE html>
<html>
<head runat="server">
    <title>Absent Deduction Policy - NexaERP</title>
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
<div class="container-fluid main-container">

    <!-- Title Heading with bi-calendar-x icon -->
    <div class="page-heading">
        <i class="bi bi-calendar-x"></i>
        <div>
            <h3>Absent Deduction Policy</h3>
            <small>HRM Configuration &rsaquo; HRM Setting &rsaquo; Absent Deduction Policy</small>
        </div>
    </div>

    <div class="row">

        <!-- Left Side Form -->
        <div class="col-12 col-lg-6 mb-3">
            <div class="card shadow">
                <div class="card-header bg-primary text-white">
                    <i class="bi bi-gear-fill"></i>
                    <h4 class="mb-0">Policy Information</h4>
                </div>

                <div class="card-body left-panel">
                    <asp:HiddenField ID="hfPolicyId" runat="server" />

                        <div class="row g-3">
                            <div class="col-md-6">
                                <label>Policy ID</label>
                                <asp:TextBox ID="txtPolicyId" ReadOnly="true" runat="server" CssClass="form-control" />
                            </div>

                            <div class="col-md-6">
                                <label>Policy Name</label>
                                <asp:TextBox ID="txtPolicyName" runat="server" CssClass="form-control" placeholder="e.g., Standard Absent Rule" />
                            </div>

                            <div class="col-md-6">
                                <label>Deduction Type</label>
                                <!-- এখানে AutoPostBack="true" দেওয়া হয়েছে যাতে টাইপ চেঞ্জ হলে ফর্মুলা ফিল্ড অন/অফ করা যায় -->
                                <asp:DropDownList ID="ddlDeductionType" runat="server" CssClass="form-select" AutoPostBack="true" OnSelectedIndexChanged="ddlDeductionType_SelectedIndexChanged">
                                    <asp:ListItem Text="-- Select --" Value="0" />
                                    <asp:ListItem Text="Fixed Amount per Day" Value="1" />
                                    <asp:ListItem Text="Percentage of Gross" Value="2" />
                                    <asp:ListItem Text="Percentage of Basic" Value="3" />
                                    <asp:ListItem Text="Formula Driven" Value="4" />
                                </asp:DropDownList>
                            </div>

                            <div class="col-md-6">
                                <label>Deduction Rate / Value</label>
                                <asp:TextBox ID="txtDeductionValue" runat="server" CssClass="form-control" type="number" step="0.01" placeholder="0.00" />
                            </div>

                            <!-- Grace Days বাদ দিয়ে এখানে 'Formula Builder' যোগ করা হয়েছে -->
                            <div class="col-md-6" id="divFormula" runat="server" visible="false">
                                <label>Salary Formula</label>
                                <!-- list="formulaSuggestions" দিয়ে নিচের ডাটালিস্টের সাথে লিংক করা হয়েছে -->
                                <asp:TextBox ID="txtFormula" runat="server" CssClass="form-control" placeholder="e.g., [Basic] / 30" list="formulaSuggestions" />    
                                <datalist id="formulaSuggestions">
                                    <option value="[Basic] / 30"></option>
                                    <option value="[Gross] / 26"></option>
                                </datalist>
                                <small class="text-muted">You can use [Basic] or [Gross] tokens.</small>
                            </div>

                            <div class="col-md-6">
                                <div class="form-check mt-4">
                                    <asp:CheckBox ID="chkIsActive" runat="server" CssClass="form-check-input" Checked="true" />
                                    <asp:Label runat="server" AssociatedControlID="chkIsActive" Text="Is Active?" CssClass="form-check-label" />
                                </div>
                            </div>
                        </div>

                    <div class="mt-4 d-flex justify-content-between align-items-center action-bar">
                        <asp:Button ID="btnRefresh" runat="server" Text="Refresh" CssClass="btn btn-secondary" OnClick="btnRefresh_Click" CausesValidation="false" />
                        <asp:Button ID="btnSave" runat="server" Text="Save" CssClass="btn btn-success" OnClick="btnSave_Click" />
                    </div>
                </div>
            </div>
        </div>

        <!-- Right Side Grid -->
        <div class="col-12 col-lg-6 mb-3">
            <div class="card shadow right-panel">
                <div class="card-header bg-success text-white">
                    <i class="bi bi-clock-history"></i>
                    <h4 class="mb-0">Policy List</h4>
                </div>

                <div class="grid-wrapper">
                    <asp:GridView ID="gvPolicies" runat="server" AutoGenerateColumns="False" 
                        CssClass="table table-bordered table-hover" DataKeyNames="Absent_Policy_Code"
                        OnSelectedIndexChanged="gvPolicies_SelectedIndexChanged">
                        <Columns>
        
                            <%-- ১. সিলেক্ট বাটন কলাম (সবার প্রথমে) --%>
                            <asp:TemplateField HeaderText="Action" ItemStyle-Width="80px" ItemStyle-CssClass="text-center">
                                <ItemTemplate>
                                    <asp:LinkButton ID="btnSelect" runat="server" CommandName="Select" 
                                        Text="Select" CssClass="btn btn-sm btn-primary" />
                                </ItemTemplate>
                            </asp:TemplateField>

                            <%-- ২. পলিসি আইডি কলাম --%>
                            <asp:BoundField DataField="Absent_Policy_Code" HeaderText="Policy ID" 
                                ItemStyle-Width="120px" HeaderStyle-CssClass="text-center" ItemStyle-CssClass="text-center" />
        
                            <%-- ৩. পলিসি নাম কলাম --%>
                            <asp:BoundField DataField="Absent_Policy_Name" HeaderText="Policy Name" 
                                HeaderStyle-CssClass="text-left" />

                        </Columns>
                    </asp:GridView>
                </div>
            </div>
        </div>

    </div>
</div>
</form>
<script>
    function insertVariable(variableName) {
        var txtBox = document.getElementById("txtFormula");
        
        // টেক্সটবক্সে কার্সার যেখানে আছে ঠিক সেখানে লেখাটি ঢুকিয়ে দেবে
        var startPos = txtBox.selectionStart;
        var endPos = txtBox.selectionEnd;
        var text = txtBox.value;
        
        txtBox.value = text.substring(0, startPos) + variableName + text.substring(endPos, text.length);
        
        // ফোকাস আবার টেক্সটবক্সে ফিরিয়ে আনা এবং কার্সার পজিশন ঠিক করা
        txtBox.focus();
        txtBox.selectionStart = startPos + variableName.length;
        txtBox.selectionEnd = startPos + variableName.length;
    }
</script>
</body>
</html>
