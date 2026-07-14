<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="FloorInformation.aspx.cs" Inherits="Nexa_ERP.ERPConfiguration.CompanyInformation.FloorInformation" %>

<!DOCTYPE html>
<html>
<head runat="server">
    <title>Floor Information - NexaERP</title>

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

    <!-- Page Heading -->
    <div class="page-heading">
        <i class="bi bi-building-fill"></i>
        <div>
            <h3>Floor Information</h3>
            <small>ERP Configuration &rsaquo; Company Information &rsaquo; Floor Information</small>
            <asp:Label ID="Label1" runat="server" Text="" Visible="false"></asp:Label>
        </div>
    </div>

    <div class="row">

        <!-- Left Side Form -->
        <div class="col-12 col-lg-6 mb-3">
            <div class="card shadow">
                <div class="card-header bg-primary text-white">
                    <i class="bi bi-layer-forward"></i>
                    <h4 class="mb-0">Floor Details</h4>
                </div>

                <div class="card-body left-panel">
                    <asp:HiddenField ID="hfUserId" runat="server" />

                    <div class="row g-3">
                        <div class="col-md-6">
                            <label>Floor ID</label>
                            <asp:TextBox ID="txtFloorID" runat="server" CssClass="form-control" ReadOnly="True" />
                        </div>

                        <div class="col-md-6">
                            <label>Building Name</label>
                            <asp:DropDownList ID="ddlBuilding" runat="server" CssClass="form-select"></asp:DropDownList>
                        </div>

                        <div class="col-md-6">
                            <label>Floor Name</label>
                            <asp:TextBox ID="txtFloor" runat="server" CssClass="form-control" />
                        </div>

                        <div class="col-md-6">
                            <div class="form-check mt-4">
                                <asp:CheckBox ID="chkIsActive" runat="server" CssClass="form-check-input" />
                                <asp:Label runat="server" AssociatedControlID="chkIsActive" Text="Is Active?" CssClass="form-check-label" />
                            </div>
                        </div>
                    </div>

                    <!-- Actions Row -->
                    <div class="mt-4 d-flex justify-content-between align-items-center action-bar flex-wrap gap-2">
                        <div class="d-flex align-items-center">
                            <label class="me-2 mb-0">Action</label>
                            <asp:DropDownList ID="ddlAction" runat="server" CssClass="form-select" style="width:120px;">
                                <asp:ListItem Text="Insert" Value="Save"></asp:ListItem>
                                <asp:ListItem Text="Update" Value="UPDATE"></asp:ListItem>
                                <asp:ListItem Text="Delete" Value="DELETE"></asp:ListItem>
                            </asp:DropDownList>
                        </div>

                        <div class="d-flex gap-2">
                            <asp:Button ID="btnClear" runat="server" Text="Clear" CssClass="btn btn-secondary" />
                            <asp:Button ID="btnSave" runat="server" Text="Save" CssClass="btn btn-success" OnClick="btnSave_Click" />
                        </div>
                    </div>

                </div>
            </div>
        </div>

        <!-- Right Side Grid -->
        <div class="col-12 col-lg-6 mb-3">
            <div class="card shadow right-panel">
                <div class="card-header bg-success text-white">
                    <i class="bi bi-list-stars"></i>
                    <h4 class="mb-0">Floor List</h4>
                </div>

                <div class="grid-wrapper">
                    <asp:GridView ID="gvBuilding" runat="server" CssClass="table table-bordered table-hover"
                        AutoGenerateColumns="False" DataKeyNames="Floor_ID" OnSelectedIndexChanged="gvBuilding_SelectedIndexChanged" Width="100%">

                        <Columns>
                            <asp:CommandField ShowSelectButton="True" SelectText="Select">
                                <ItemStyle Width="80px" />
                            </asp:CommandField>

                            <asp:BoundField DataField="Floor_ID" HeaderText="ID" />
                            <asp:BoundField DataField="Floor_Name" HeaderText="Building Name" />
                            <asp:CheckBoxField DataField="is_active" HeaderText="Status" />
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