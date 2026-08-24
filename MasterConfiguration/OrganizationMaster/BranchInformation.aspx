<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="BranchInformation.aspx.cs" Inherits="Nexa_ERP.ERPConfiguration.CompanyInformation.BranchInformation" %>

<!DOCTYPE html>
<html>
<head runat="server">
    <title>Branch Information - NexaERP</title>
    <meta name="viewport" content="width=device-width, initial-scale=1" />

    <script src="https://ajax.aspnetcdn.com/ajax/jquery/jquery-3.7.1.min.js"></script>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet" />
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css" />
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

    * { font-family: 'Inter', 'Segoe UI', Roboto, Arial, sans-serif; }
    body { background: var(--page-bg); margin: 0; padding: 0; color: #1f2937; }
    .main-container { min-height: 100vh; padding: 20px; }
    .page-heading { display: flex; align-items: center; gap: 10px; margin-bottom: 16px; }
    .page-heading i { font-size: 1.4rem; color: var(--brand-primary); }
    .page-heading h3 { margin: 0; font-weight: 700; font-size: 1.35rem; color: #111827; }
    .page-heading small { display: block; color: var(--text-muted); font-weight: 400; font-size: 0.8rem; }
    .welcome-badge { margin-left: auto; font-size: 0.8rem; color: var(--text-muted); }
    .card { border: 1px solid var(--border-soft); border-radius: 14px; overflow: hidden; box-shadow: 0 2px 10px rgba(17, 24, 39, 0.06); }
    .card-header { border: none; padding: 14px 20px; display: flex; align-items: center; gap: 10px; }
    .card-header.bg-primary { background: linear-gradient(135deg, var(--brand-primary), var(--brand-primary-dark)) !important; }
    .card-header.bg-success { background: linear-gradient(135deg, var(--brand-success), var(--brand-success-dark)) !important; }
    .card-header h4 { font-size: 1.05rem; font-weight: 600; letter-spacing: 0.2px; margin: 0; color: #fff; }
    .card-header i { font-size: 1.1rem; color: #fff; }
    label { font-weight: 600; font-size: 0.85rem; color: #374151; margin-bottom: 6px; display: block; }
    .required-mark { color: #dc3545; margin-left: 2px; }
    .form-control, .form-select { border-radius: 8px; border: 1px solid #d7dce3; padding: 9px 12px; font-size: 0.92rem; }
    .form-control:focus, .form-select:focus { border-color: var(--brand-primary); box-shadow: 0 0 0 0.2rem rgba(13, 110, 253, 0.15); }
    .form-control[readonly] { background-color: #f3f4f6; color: #6b7280; }
    .btn { border-radius: 8px; font-weight: 600; font-size: 0.9rem; padding: 8px 20px; }
    .btn-success { background: linear-gradient(135deg, var(--brand-success), var(--brand-success-dark)); border: none; }
    .btn-secondary { background-color: #eef0f3; border: 1px solid #d7dce3; color: #374151; }
    .logo-preview { width: 70px; height: 70px; object-fit: cover; border-radius: 6px; border: 1px solid #ced4da; }
    .left-panel { max-height: calc(100vh - 220px); overflow-y: auto; padding: 22px; }
    .grid-wrapper { max-height: calc(100vh - 220px); overflow-y: auto; overflow-x: auto; }
    .grid-wrapper table { margin-bottom: 0; font-size: 0.88rem; }
    .grid-wrapper th { position: sticky; top: 0; background: linear-gradient(135deg, var(--brand-primary), var(--brand-primary-dark)) !important; color: #fff !important; z-index: 100; font-weight: 600; font-size: 0.82rem; text-transform: uppercase; padding: 12px 14px; border: none; white-space: nowrap; }
    .grid-wrapper td { padding: 10px 14px; vertical-align: middle; color: #374151; white-space: nowrap; }
    .grid-wrapper td.wrap-cell { white-space: normal; min-width: 180px; }
    .grid-wrapper tbody tr:hover { background-color: #f0f6ff; }
</style>
</head>
<body>
<form id="form1" runat="server">
<asp:ScriptManager ID="ScriptManager1" runat="server" />
<asp:HiddenField ID="hfUserId" runat="server" />
<div class="container-fluid main-container">

    <div class="page-heading">
        <i class="bi bi-diagram-3-fill"></i>
        <div>
            <h3>Branch Information</h3>
            <small>ERP Configuration &rsaquo; Company Information &rsaquo; Branch</small>
        </div>
        <span class="welcome-badge">
            <asp:Label ID="Label1" runat="server" Text=""></asp:Label>
        </span>
    </div>

    <div class="row">
        <!-- Left Side Form -->
        <div class="col-12 col-lg-6 mb-3">
            <div class="card shadow">
                <div class="card-header bg-primary text-white">
                    <i class="bi bi-building"></i>
                    <h4>Branch Details</h4>
                </div>

                <div class="card-body left-panel">
                    <div class="row g-3">
                        <div class="col-md-6">
                            <asp:Label runat="server" AssociatedControlID="txtBranchID" Text="Branch ID" />
                            <asp:TextBox ID="txtBranchID" runat="server" CssClass="form-control" Text="0" ReadOnly="True" />
                        </div>

                        <div class="col-md-6">
                            <asp:Label runat="server" AssociatedControlID="ddlGroup">Group<span class="required-mark">*</span></asp:Label>
                            <asp:DropDownList ID="ddlGroup" runat="server" CssClass="form-select"></asp:DropDownList>
                            <asp:RequiredFieldValidator ID="rfvGroup" runat="server"
                                ControlToValidate="ddlGroup" Display="Dynamic" CssClass="text-danger small"
                                ErrorMessage="Please select a Group." InitialValue="0"
                                ValidationGroup="BranchInfo" />
                        </div>

                        <div class="col-md-6">
                            <asp:Label runat="server" AssociatedControlID="txtBranch">Branch Name<span class="required-mark">*</span></asp:Label>
                            <asp:TextBox ID="txtBranch" runat="server" CssClass="form-control" MaxLength="100" />
                            <asp:RequiredFieldValidator ID="rfvBranch" runat="server"
                                ControlToValidate="txtBranch" Display="Dynamic" CssClass="text-danger small"
                                ErrorMessage="Branch Name is required." ValidationGroup="BranchInfo" />
                        </div>

                        <div class="col-md-6">
                            <asp:Label runat="server" AssociatedControlID="txtPrefix" Text="Prefix" />
                            <asp:TextBox ID="txtPrefix" runat="server" CssClass="form-control" MaxLength="20" />
                        </div>

                        <!-- Branch Logo Upload & Preview -->
                        <div class="col-md-12">
                            <asp:Label runat="server" AssociatedControlID="fuBranchLogo" Text="Branch Logo (Binary)" />
                            <div class="d-flex align-items-center gap-3">
                                <asp:FileUpload ID="fuBranchLogo" runat="server" CssClass="form-control" />
                                <asp:Image ID="imgLogoPreview" runat="server" CssClass="logo-preview" ImageUrl="~/Images/no-image.png" />
                            </div>
                        </div>

                        <div class="col-md-6">
                            <asp:Label runat="server" AssociatedControlID="txtEmail" Text="E-Mail" />
                            <asp:TextBox ID="txtEmail" runat="server" CssClass="form-control" MaxLength="100" TextMode="Email" />
                        </div>

                        <div class="col-md-6">
                            <asp:Label runat="server" AssociatedControlID="txtPhone" Text="Phone No" />
                            <asp:TextBox ID="txtPhone" runat="server" CssClass="form-control" MaxLength="20" />
                        </div>

                        <div class="col-md-6">
                            <asp:Label runat="server" AssociatedControlID="txtWeb" Text="Web" />
                            <asp:TextBox ID="txtWeb" runat="server" CssClass="form-control" MaxLength="100" placeholder="https://example.com" />
                        </div>

                        <div class="col-md-6">
                            <div class="form-check mt-4">
                                <asp:CheckBox ID="chkIsActive" runat="server" CssClass="form-check-input" Checked="True" />
                                <asp:Label runat="server" AssociatedControlID="chkIsActive" Text="Is Active?" CssClass="form-check-label" />
                            </div>
                        </div>

                        <div class="col-md-12">
                            <asp:Label runat="server" AssociatedControlID="txtAddress" Text="Address" />
                            <asp:TextBox ID="txtAddress" runat="server" CssClass="form-control" TextMode="MultiLine" Rows="3" MaxLength="250" />
                        </div>
                    </div>

                    <div class="mt-4 d-flex justify-content-between align-items-center action-bar border-top pt-3">
                        <asp:Button ID="btnClear" runat="server" Text="Clear" CssClass="btn btn-secondary" OnClick="btnClear_Click" CausesValidation="false" />
                        <asp:Button ID="btnSave" runat="server" Text="Save" CssClass="btn btn-success" OnClick="btnSave_Click" ValidationGroup="BranchInfo" />
                    </div>
                </div>
            </div>
        </div>

        <!-- Right Side Grid -->
        <div class="col-12 col-lg-6 mb-3">
            <div class="card shadow right-panel">
                <div class="card-header bg-success text-white">
                    <i class="bi bi-list-check"></i>
                    <h4>Branch List</h4>
                </div>

                <div class="grid-wrapper">
                    <asp:GridView ID="gvBranch"
                        runat="server"
                        CssClass="table table-bordered table-hover align-middle"
                        AutoGenerateColumns="False"
                        DataKeyNames="Branch_ID"
                        Width="100%" 
                        OnSelectedIndexChanged="gvBranch_SelectedIndexChanged">

                        <Columns>
                            <asp:CommandField ShowSelectButton="True" SelectText="Select">
                                <ItemStyle Width="80px" />
                            </asp:CommandField>

                            <asp:BoundField DataField="Branch_ID" HeaderText="ID" />
                            <asp:TemplateField HeaderText="Logo">
                                <ItemTemplate>
                                    <asp:Image ID="imgGridLogo" runat="server" 
                                        ImageUrl='<%# Eval("Branch_Logo") != DBNull.Value ? "data:image/png;base64," + Convert.ToBase64String((byte[])Eval("Branch_Logo")) : "~/Images/no-image.png" %>' 
                                        Width="35" Height="35" CssClass="rounded object-fit-cover border" />
                                </ItemTemplate>
                            </asp:TemplateField>

                            <asp:BoundField DataField="Branch_Name" HeaderText="Branch Name" />
                            <asp:BoundField DataField="Prifix" HeaderText="Prefix" />
                            <asp:BoundField DataField="E_Mail" HeaderText="E-Mail" />
                            <asp:BoundField DataField="Phone_No" HeaderText="Phone" />
                            <asp:BoundField DataField="Address" HeaderText="Address" ItemStyle-CssClass="wrap-cell" />
                            <asp:CheckBoxField DataField="Is_Active" HeaderText="Status" />
                        </Columns>
                    </asp:GridView>
                </div>
            </div>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</form>
</body>
</html>