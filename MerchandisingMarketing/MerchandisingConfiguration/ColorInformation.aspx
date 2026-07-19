<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ColorInformation.aspx.cs" Inherits="Nexa_ERP.MerchandisingMarketing.MerchandisingConfiguration.ColorInformation" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Color Master - NexaERP</title>

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

    .form-control[readonly],
    .form-control[disabled] {
        background-color: #f3f4f6;
        color: #6b7280;
    }

    .btn {
        border-radius: 8px;
        font-weight: 600;
        font-size: 0.9rem;
        padding: 8px 20px;
    }

    .btn-save {
        background: linear-gradient(135deg, var(--brand-success), var(--brand-success-dark));
        border: none;
        color: #fff;
    }

    .btn-reset {
        background-color: #eef0f3;
        border: 1px solid #d7dce3;
        color: #374151;
        border-radius: 8px;
        font-weight: 600;
        font-size: 0.9rem;
        padding: 8px 20px;
    }

    .btn-reset:hover {
        background-color: #e2e5ea;
        color: #111827;
    }

    .btn-edit {
        background: var(--brand-success);
        color: #fff;
        border: none;
        padding: 4px 10px;
        border-radius: 6px;
        font-size: 0.78rem;
        font-weight: 600;
        margin-right: 4px;
    }

    .btn-del {
        background: #dc3545;
        color: #fff;
        border: none;
        padding: 4px 8px;
        border-radius: 6px;
        font-size: 0.78rem;
        font-weight: 600;
    }

    .form-check-input:checked {
        background-color: var(--brand-success);
        border-color: var(--brand-success);
    }

    .form-check {
        display: flex;
        align-items: center;
        gap: 8px;
        min-height: auto;
        padding-left: 0;
    }

    .form-check .form-check-input {
        margin: 0;
        flex-shrink: 0;
    }

    .form-check label {
        display: inline;
        margin-bottom: 0;
        font-weight: 500;
        white-space: nowrap;
        vertical-align: middle;
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

    .msg-label {
        margin-top: 10px;
        font-weight: 600;
        font-size: 0.85rem;
        color: var(--brand-success);
    }

    .grid-wrapper {
        max-height: calc(100vh - 300px);
        overflow-y: auto;
        overflow-x: auto;
    }

    .grid-wrapper table {
        margin-bottom: 0;
        white-space: nowrap;
        font-size: 0.88rem;
        width: 100%;
        border-collapse: collapse;
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
        text-align: left;
    }

    .grid-wrapper td {
        padding: 10px 14px;
        vertical-align: middle;
        color: #374151;
        border-bottom: 1px solid var(--border-soft);
    }

    .grid-wrapper tbody tr:hover {
        background-color: #f0f6ff;
    }

    .pager-bar {
        display: flex;
        align-items: center;
        justify-content: space-between;
        flex-wrap: wrap;
        gap: 8px;
        padding: 14px 22px;
        border-top: 1px solid var(--border-soft);
        font-size: 0.82rem;
        color: var(--text-muted);
    }

    .pager-bar .pager-controls {
        display: flex;
        align-items: center;
        gap: 4px;
    }

    .pager-bar a,
    .pager-bar .current {
        padding: 4px 10px;
        border: 1px solid var(--border-soft);
        border-radius: 6px;
        text-decoration: none;
        color: #374151;
        font-weight: 500;
    }

    .pager-bar .current {
        background: var(--brand-primary);
        color: #fff;
        border-color: var(--brand-primary);
    }

    .pager-bar .form-select {
        width: auto;
        display: inline-block;
        padding: 4px 10px;
        height: auto;
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

        .pager-bar {
            flex-direction: column;
            align-items: flex-start;
        }
    }
</style>
</head>
<body>
<form id="form1" runat="server">
<asp:ScriptManager ID="ScriptManager1" runat="server" />

<div class="container-fluid main-container">

    <div class="page-heading">
        <i class="bi bi-palette-fill"></i>
        <div>
            <h3>Color Master</h3>
            <small>Merchandising &amp; Marketing &rsaquo; Merchandising Configuration &rsaquo; Color Information</small>
        </div>
    </div>

    <div class="row">

        <!-- Left Side Form -->
        <div class="col-12 col-lg-6 mb-3">

            <asp:UpdatePanel ID="upForm" runat="server">
            <ContentTemplate>
            <div class="card shadow">

                <div class="card-header bg-primary text-white">
                    <i class="bi bi-droplet-fill"></i>
                    <h4 class="mb-0">Master Data</h4>
                </div>

                <div class="card-body left-panel">

                    <div class="row g-3">

                        <div class="col-md-6">
                            <label>Color Code</label>
                            <asp:TextBox ID="txtColorCode" runat="server" CssClass="form-control" ReadOnly="true" placeholder="[Auto Generated]" />
                        </div>

                        <div class="col-md-6">
                            <label>Color Type</label>
                            <asp:DropDownList ID="ddlColorType" runat="server" CssClass="form-select">
                                <asp:ListItem Value="">--Select Type--</asp:ListItem>
                            </asp:DropDownList>
                        </div>

                        <div class="col-md-6">
                            <label>Color Name</label>
                            <asp:TextBox ID="txtColorName" runat="server" CssClass="form-control" placeholder="Color Name" MaxLength="100" />
                        </div>

                        <div class="col-md-6">
                            <label>Panton Name</label>
                            <asp:TextBox ID="txtPantenName" runat="server" CssClass="form-control" placeholder="Color Name" MaxLength="100" />
                        </div>

                        <div class="col-md-6">
                            <div class="form-check mt-4">
                                <asp:CheckBox ID="chkIsActive" runat="server" Checked="true" Text="Is Active?"/>
                            </div>
                        </div>

                    </div>

                    <div class="mt-4 d-flex justify-content-between align-items-center action-bar">
                        <asp:Button ID="btnReset" runat="server" Text="Reset" CssClass="btn btn-reset" OnClick="btnReset_Click" />
                        <asp:Button ID="btnSave" runat="server" Text="Save" CssClass="btn btn-save" OnClick="btnSave_Click" />
                    </div>

                    <div class="msg-label">
                        <asp:Label ID="lblMessage" runat="server" />
                    </div>

                    <asp:HiddenField ID="hfColorID" runat="server" Value="0" />

                </div>

            </div>
            </ContentTemplate>
            </asp:UpdatePanel>

        </div>

        <!-- Right Side Grid -->
        <div class="col-12 col-lg-6 mb-3">

            <asp:UpdatePanel ID="upGrid" runat="server">
            <ContentTemplate>
            <div class="card shadow right-panel">

                <div class="card-header bg-success text-white">
                    <i class="bi bi-list-check"></i>
                    <h4 class="mb-0">Color List</h4>
                </div>

                <div class="grid-wrapper">
                    <asp:GridView ID="gvColorList" runat="server" CssClass="table table-bordered table-hover" AutoGenerateColumns="false"
                        DataKeyNames="ColorID" Width="100%" OnRowCommand="gvColorList_RowCommand">
                        <Columns>
                            <asp:BoundField DataField="ColorCode" HeaderText="Color Code" />
                            <asp:BoundField DataField="ColorType" HeaderText="Color Type" />
                            <asp:BoundField DataField="ColorName" HeaderText="Color Name" />
                            <asp:BoundField DataField="IsActive" HeaderText="Is Active?" />
                            <asp:TemplateField HeaderText="Action">
                                <ItemTemplate>
                                    <asp:Button runat="server" Text="Edit" CssClass="btn-edit"
                                        CommandName="EditRow" CommandArgument='<%# Eval("ColorID") %>' />
                                    <asp:Button runat="server" Text="X" CssClass="btn-del"
                                        CommandName="DeleteRow" CommandArgument='<%# Eval("ColorID") %>'
                                        OnClientClick="return confirm('Are you sure you want to delete this record?');" />
                                </ItemTemplate>
                            </asp:TemplateField>
                        </Columns>
                        <EmptyDataTemplate><p style="color:#888;">No records found.</p></EmptyDataTemplate>
                    </asp:GridView>
                </div>

                <!-- Pager -->
                <div class="pager-bar">
                    <div class="pager-controls">
                        <asp:LinkButton ID="lbFirst" runat="server" OnClick="lbFirst_Click">1st page</asp:LinkButton>
                        <asp:LinkButton ID="lbPrev" runat="server" OnClick="lbPrev_Click">&lsaquo;</asp:LinkButton>
                        <asp:Label ID="lblCurrentPage" runat="server" CssClass="current" />
                        <asp:LinkButton ID="lbNext" runat="server" OnClick="lbNext_Click">&rsaquo;</asp:LinkButton>
                        <asp:LinkButton ID="lbLast" runat="server" OnClick="lbLast_Click">&raquo;</asp:LinkButton>
                        &nbsp;
                        <asp:DropDownList ID="ddlPageSize" runat="server" CssClass="form-select" AutoPostBack="true" OnSelectedIndexChanged="ddlPageSize_Changed">
                            <asp:ListItem Value="10">10</asp:ListItem>
                            <asp:ListItem Value="25">25</asp:ListItem>
                            <asp:ListItem Value="50">50</asp:ListItem>
                        </asp:DropDownList>
                        items per page
                    </div>
                    <asp:Label ID="lblRecordInfo" runat="server" />
                </div>

            </div>
            </ContentTemplate>
            </asp:UpdatePanel>

        </div>

    </div>

</div>
</form>
</body>
</html>
