<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="BuyingHouseAgent.aspx.cs" Inherits="Nexa_ERP.MerchandisingMarketing.MerchandisingConfiguration.BuyingHouseAgent" %>

<!DOCTYPE html>
<html>
<head runat="server">
    <title>Buying House/Agent Information - NexaERP</title>

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
        margin: 0;
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
    }
</style>
</head>
<body>
<form id="form1" runat="server">
<div class="container-fluid main-container">

    <div class="page-heading">
        <i class="bi bi-briefcase-fill"></i>
        <div>
            <h3>Buying House/Agent Information</h3>
            <small>Merchandising &amp; Marketing &rsaquo; Merchandising Configuration &rsaquo; Buying House/Agent</small>
        </div>
    </div>

    <div class="row">

        <!-- Left Side Form -->
        <div class="col-12 col-lg-6 mb-3">

            <div class="card shadow">

                <div class="card-header bg-primary text-white">
                    <i class="bi bi-building"></i>
                    <h4 class="mb-0">Buying House/Agent Information</h4>
                    <asp:Label ID="Label1" runat="server" Text=""></asp:Label>
                </div>

                <div class="card-body left-panel">

                    <asp:Panel ID="PanelEntry" runat="server">
                        <div class="row g-3">

                            <div class="col-md-6">
                                <label>Buying House/Agent ID</label>
                                <asp:TextBox ID="txtHouseID" runat="server" ReadOnly="True" CssClass="form-control" />
                            </div>

                            <div class="col-md-6">
                                <label>Buying House/Agent Name</label>
                                <asp:TextBox ID="txtHouseName" runat="server" CssClass="form-control" />
                            </div>

                            <div class="col-md-6">
                                <label>Prefix</label>
                                <asp:TextBox ID="txtPrefix" runat="server" CssClass="form-control" />
                            </div>

                            <div class="col-md-6">
                                <label>Buying House/Agent Type</label>
                                <asp:DropDownList ID="ddlHouseType" runat="server" AutoPostBack="true" CssClass="form-select"></asp:DropDownList>
                            </div>

                            <div class="col-md-6">
                                <label>Buying House/Agent Country</label>
                                <asp:DropDownList ID="ddlCountryName" runat="server" CssClass="form-select"></asp:DropDownList>
                            </div>

                            <div class="col-md-6">
                                <label>Contact Person</label>
                                <asp:TextBox ID="txtContractPerson" runat="server" CssClass="form-control" />
                            </div>

                            <div class="col-md-6">
                                <label>Contact No</label>
                                <asp:TextBox ID="txtPhone" runat="server" CssClass="form-control" />
                            </div>

                            <div class="col-md-6">
                                <label>E-mail</label>
                                <asp:TextBox ID="txtEmail" runat="server" CssClass="form-control" />
                            </div>

                            <div class="col-md-6">
                                <label>Address</label>
                                <asp:TextBox ID="txtAddress" runat="server" CssClass="form-control" />
                            </div>

                            <div class="col-md-6">
                                <div class="form-check mb-2">
                                    <asp:CheckBox ID="CheckBox1" runat="server" AutoPostBack="true" CssClass="form-check-input" OnCheckedChanged="CheckBox1_CheckedChanged" />
                                    <asp:Label runat="server" AssociatedControlID="CheckBox1"
                                        Text="If Address &amp; Local Address Same" CssClass="form-check-label" />
                                </div>
                                <label>Local Address</label>
                                <asp:TextBox ID="txtAddressLocal" runat="server" CssClass="form-control" />
                            </div>

                            <div class="col-md-6">
                                <div class="form-check mt-4">
                                    <asp:CheckBox ID="chkIsActive" runat="server" CssClass="form-check-input" />
                                    <asp:Label runat="server" AssociatedControlID="chkIsActive"
                                        Text="Is Active?" CssClass="form-check-label" />
                                </div>
                            </div>

                        </div>

                        <div class="mt-4 d-flex justify-content-between align-items-center action-bar">
                            <asp:Button ID="btnClear" runat="server" Text="Clear" CssClass="btn btn-secondary" OnClick="btnClear_Click" />

                            <asp:LinkButton ID="btnSave" runat="server" CssClass="btn btn-success d-inline-flex align-items-center" OnClick="btnSave_Click">
                                <i class="bi bi-save me-1"></i>Save
                            </asp:LinkButton>
                        </div>

                    </asp:Panel>

                </div>

            </div>

        </div>

        <!-- Right Side Grid -->
        <div class="col-12 col-lg-6 mb-3">

            <asp:Panel ID="PanelBuyingAgent" runat="server">
                <div class="card shadow right-panel">

                    <div class="card-header bg-success text-white">
                        <i class="bi bi-list-check"></i>
                        <h4 class="mb-0">Buying House/Agent List</h4>
                    </div>

                    <div class="grid-wrapper">
                        <asp:GridView ID="gvBuyingAgent"
                            runat="server"
                            CssClass="table table-bordered table-hover"
                            AutoGenerateColumns="False"
                            DataKeyNames="AgentID"
                            Width="100%" OnSelectedIndexChanged="gvBuyingAgent_SelectedIndexChanged">

                            <Columns>
                                <asp:CommandField ShowSelectButton="True"
                                    SelectText="Select">
                                    <ItemStyle Width="80px" />
                                </asp:CommandField>

                                <asp:BoundField DataField="AgentID"
                                    HeaderText="ID" />

                                <asp:BoundField DataField="HouseName"
                                    HeaderText="Branch Name" />

                                <asp:BoundField DataField="Prefix"
                                    HeaderText="Prifix" />

                                <asp:CheckBoxField DataField="IsActive"
                                    HeaderText="Status" />

                            </Columns>

                        </asp:GridView>
                    </div>

                </div>
            </asp:Panel>

        </div>

    </div>

</div>
</form>
</body>
</html>
