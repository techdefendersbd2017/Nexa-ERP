<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="SalaryAdvancePolicy.aspx.cs" Inherits="Nexa_ERP.HRMPayroll.HRConfiguration.PayrollSetting.SalaryAdvancePolicy" %>

<!DOCTYPE html>
<html>
<head runat="server">
    <title>Advance Salary Policy - NexaERP</title>
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet" />
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css" />
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet" />
    <style>
        :root { --p:#0d6efd; --pd:#0b5ed7; --s:#198754; --sd:#157347; --bd:#e6e9ef; --mut:#6b7280; }
        * { font-family:'Inter','Segoe UI',Roboto,Arial,sans-serif; }
        body { background:#f2f4f8; margin:0; color:#1f2937; }
        .main-container { min-height:100vh; padding:20px; }
        .page-heading { display:flex; align-items:center; gap:10px; margin-bottom:16px; }
        .page-heading i { font-size:1.4rem; color:var(--p); }
        .page-heading h3 { margin:0; font-weight:700; font-size:1.35rem; }
        .page-heading small { display:block; color:var(--mut); font-size:.8rem; }
        .card { border:1px solid var(--bd); border-radius:14px; overflow:hidden; box-shadow:0 2px 10px rgba(17,24,39,.06); }
        .card-header { border:none; padding:14px 20px; display:flex; align-items:center; gap:10px; }
        .card-header.bg-primary { background:linear-gradient(135deg,var(--p),var(--pd)) !important; }
        .card-header.bg-success { background:linear-gradient(135deg,var(--s),var(--sd)) !important; }
        .card-header h4 { font-size:1.05rem; font-weight:600; margin:0; }
        label { font-weight:600; font-size:.85rem; color:#374151; margin-bottom:6px; display:block; }
        .form-control,.form-select { border-radius:8px; border:1px solid #d7dce3; padding:9px 12px; font-size:.92rem; }
        .form-control:focus,.form-select:focus { border-color:var(--p); box-shadow:0 0 0 .2rem rgba(13,110,253,.15); }
        .form-control[readonly] { background:#f3f4f6; color:#6b7280; }
        .btn { border-radius:8px; font-weight:600; font-size:.9rem; padding:8px 20px; }
        .btn-success { background:linear-gradient(135deg,var(--s),var(--sd)); border:none; }
        .btn-secondary { background:#eef0f3; border:1px solid #d7dce3; color:#374151; }
        .left-panel { max-height:calc(100vh - 220px); overflow-y:auto; padding:22px; }
        .action-bar { border-top:1px solid var(--bd); margin-top:20px; padding-top:16px; }
        .grid-wrapper { max-height:calc(100vh - 220px); overflow:auto; }
        .grid-wrapper table { margin-bottom:0; white-space:nowrap; font-size:.88rem; }
        .grid-wrapper th { position:sticky; top:0; z-index:100; background:linear-gradient(135deg,var(--p),var(--pd)) !important; color:#fff !important; font-weight:600; font-size:.82rem; text-transform:uppercase; padding:12px 14px; border:none; }
        .grid-wrapper td { padding:10px 14px; vertical-align:middle; }
        .grid-wrapper tbody tr:hover { background:#f0f6ff; }
        @media (max-width:991.98px) {
            .left-panel,.grid-wrapper { max-height:none; overflow:visible; }
            .grid-wrapper { overflow-x:auto; }
            .action-bar .btn { width:100%; }
        }
    </style>
</head>
<body>
<form id="form1" runat="server">
<div class="container-fluid main-container">

    <div class="page-heading">
        <i class="bi bi-cash-coin"></i>
        <div>
            <h3>Advance Salary Policy</h3>
            <small>HRM Configuration &rsaquo; Payroll Setting &rsaquo; Advance Salary Policy</small>
        </div>
    </div>

    <div class="row">
        <!-- Left: Form -->
        <div class="col-12 col-xl-7 mb-3">
            <div class="card shadow">
                <div class="card-header bg-primary text-white">
                    <i class="bi bi-gear-fill"></i>
                    <h4>Policy Information</h4>
                </div>
                <div class="card-body left-panel">
                    <div class="row g-3">

                        <div class="col-md-6">
                            <label>Policy Code</label>
                            <asp:TextBox ID="txtPolicyId" runat="server" ReadOnly="true" CssClass="form-control" />
                        </div>
                        <div class="col-md-6">
                            <label>Policy Month</label>
                            <asp:TextBox ID="txtPolicyMonth" runat="server" TextMode="Date" CssClass="form-control" />
                        </div>

                        <div class="col-12">
                            <label>Policy Name</label>
                            <asp:TextBox ID="txtPolicyName" runat="server" CssClass="form-control" placeholder="e.g., Advance Salary - Nov 2026" />
                        </div>

                        <div class="col-md-6">
                            <label>Pay From</label>
                            <asp:TextBox ID="txtPayFrom" runat="server" TextMode="Date" CssClass="form-control" />
                        </div>
                        <div class="col-md-6">
                            <label>Pay Till</label>
                            <asp:TextBox ID="txtPayTill" runat="server" TextMode="Date" CssClass="form-control" />
                        </div>

                        <div class="col-md-6">
                            <label>Employee Category</label>
                            <asp:DropDownList ID="ddlCategory" runat="server" CssClass="form-select" />
                        </div>
                        <div class="col-md-6">
                            <label>Policy Type</label>
                            <div class="d-flex gap-2">
                                <asp:DropDownList ID="ddlPolicyType" runat="server" CssClass="form-select" AutoPostBack="true" OnSelectedIndexChanged="ddlPolicyType_SelectedIndexChanged">
                                    <asp:ListItem Text="Select" Value="Select" />
                                    <asp:ListItem Text="Formula" Value="Formula" />
                                    <asp:ListItem Text="Fixed" Value="Fixed" />
                                    <asp:ListItem Text="Percentage" Value="Percentage" />
                                </asp:DropDownList>
                                <asp:TextBox ID="txtPolicyValue" runat="server" CssClass="form-control" Text="0" style="max-width:110px" ReadOnly="true" />
                            </div>
                        </div>

                        <div class="col-md-6">
                            <label>Payment Type</label>
                            <asp:DropDownList ID="ddlPaymentType" runat="server" CssClass="form-select" />
                        </div>
                        <div class="col-md-6">
                            <label>Absent Deduction</label>
                            <asp:DropDownList ID="ddlAbsentDed" runat="server" CssClass="form-select">
                                <asp:ListItem Text="Select" Value="Select" />
                                <asp:ListItem Text="Yes" Value="Yes" />
                                <asp:ListItem Text="No" Value="No" />
                            </asp:DropDownList>
                        </div>

                        <div class="col-md-6">
                            <label>Payment From</label>
                            <asp:DropDownList ID="ddlPaymentFrom" runat="server" CssClass="form-select">
                                <asp:ListItem Text="Select" Value="Select" />
                                <asp:ListItem Text="Basic" Value="Basic" />
                                <asp:ListItem Text="Gross" Value="Gross" />
                            </asp:DropDownList>
                        </div>
                        <div class="col-md-6">
                            <label>OT Pay</label>
                            <asp:DropDownList ID="ddlOtPay" runat="server" CssClass="form-select">
                                <asp:ListItem Text="Select" Value="Select" />
                                <asp:ListItem Text="Yes" Value="Yes" />
                                <asp:ListItem Text="No" Value="No" />
                            </asp:DropDownList>
                        </div>

                        <div class="col-md-6">
                            <label>Night / Tiffin / Holiday</label>
                            <asp:DropDownList ID="ddlNightTifin" runat="server" CssClass="form-select">
                                <asp:ListItem Text="Select" Value="Select" />
                                <asp:ListItem Text="Yes" Value="Yes" />
                                <asp:ListItem Text="No" Value="No" />
                            </asp:DropDownList>
                        </div>
                        <div class="col-md-6">
                            <label>Attendance Bonus</label>
                            <asp:DropDownList ID="ddlAttBonus" runat="server" CssClass="form-select">
                                <asp:ListItem Text="Select" Value="Select" />
                                <asp:ListItem Text="Yes" Value="Yes" />
                                <asp:ListItem Text="No" Value="No" />
                            </asp:DropDownList>
                        </div>

                        <div class="col-md-6">
                            <label>Rounding Option</label>
                            <asp:DropDownList ID="ddlRounding" runat="server" CssClass="form-select">
                                <asp:ListItem Text="Select" Value="Select" />
                                <asp:ListItem Text="None" Value="None" />
                                <asp:ListItem Text="Round" Value="Round" />
                                <asp:ListItem Text="Round Up" Value="Round Up" />
                                <asp:ListItem Text="Round Down" Value="Round Down" />
                            </asp:DropDownList>
                        </div>
                        <div class="col-md-6">
                            <label>Pay Type</label>
                            <asp:DropDownList ID="ddlPayType" runat="server" CssClass="form-select">
                                <asp:ListItem Text="Select" Value="Select" />
                                <asp:ListItem Text="Cash" Value="Cash" />
                                <asp:ListItem Text="Bank" Value="Bank" />
                            </asp:DropDownList>
                        </div>

                        <div class="col-12">
                            <label>Sheet Header</label>
                            <asp:TextBox ID="txtSheetHeader" runat="server" CssClass="form-control" />
                        </div>
                    </div>

                    <div class="d-flex justify-content-between align-items-center action-bar">
                        <asp:Button ID="btnRefresh" runat="server" Text="Refresh" CssClass="btn btn-secondary" OnClick="btnRefresh_Click" CausesValidation="false" />
                        <div class="d-flex gap-2">
                            <asp:Button ID="btnAdd" runat="server" Text="Add" CssClass="btn btn-success" OnClick="btnAdd_Click" />
                            <asp:Button ID="btnUpdate" runat="server" Text="Update" CssClass="btn btn-primary" OnClick="btnUpdate_Click" />
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- Right: Grid -->
        <div class="col-12 col-xl-5 mb-3">
            <div class="card shadow">
                <div class="card-header bg-success text-white">
                    <i class="bi bi-clock-history"></i>
                    <h4>Policy List</h4>
                </div>
                <div class="grid-wrapper">
                    <asp:GridView ID="gvPolicies" runat="server" AutoGenerateColumns="False"
                        CssClass="table table-bordered table-hover" DataKeyNames="Policy_Code"
                        OnSelectedIndexChanged="gvPolicies_SelectedIndexChanged" EmptyDataText="No policy found.">
                        <Columns>
                            <asp:TemplateField HeaderText="Action" ItemStyle-Width="80px" ItemStyle-CssClass="text-center">
                                <ItemTemplate>
                                    <asp:LinkButton ID="btnSelect" runat="server" CommandName="Select" Text="Select" CssClass="btn btn-sm btn-primary" />
                                </ItemTemplate>
                            </asp:TemplateField>
                            <asp:BoundField DataField="Policy_Code" HeaderText="Policy Code" />
                            <asp:BoundField DataField="Emp_Category" HeaderText="Emp. Category" />
                            <asp:BoundField DataField="Policy_Name" HeaderText="Policy Name" />
                        </Columns>
                    </asp:GridView>
                </div>
            </div>
        </div>
    </div>
</div>
</form>
</body>
</html>