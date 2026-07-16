<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="CuttingTable.aspx.cs" Inherits="Nexa_ERP.Production.Cutting.CuttingTable" %>

<!DOCTYPE html>
<html>
<head runat="server">
    <title>Cutting Table - NexaERP</title>
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
            --brand-danger: #dc3545;
            --brand-danger-dark: #bb2d3b;
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

        .card { border: 1px solid var(--border-soft); border-radius: 14px; overflow: hidden; box-shadow: 0 2px 10px rgba(17, 24, 39, 0.06); }
        .card-header { border: none; padding: 14px 20px; display: flex; align-items: center; gap: 10px; }
        .card-header.bg-primary { background: linear-gradient(135deg, var(--brand-primary), var(--brand-primary-dark)) !important; color: #fff; }
        .card-header.bg-success { background: linear-gradient(135deg, var(--brand-success), var(--brand-success-dark)) !important; color: #fff; }
        .card-header h4 { font-size: 1.05rem; font-weight: 600; letter-spacing: 0.2px; margin: 0; }

        label { font-weight: 600; font-size: 0.85rem; color: #374151; margin-bottom: 6px; display: block; }

        .form-control, .form-select { border-radius: 8px; border: 1px solid #d7dce3; padding: 9px 12px; font-size: 0.92rem; transition: border-color 0.15s ease, box-shadow 0.15s ease; }
        .form-control:focus, .form-select:focus { border-color: var(--brand-primary); box-shadow: 0 0 0 0.2rem rgba(13, 110, 253, 0.15); }

        .btn { border-radius: 8px; font-weight: 600; font-size: 0.9rem; padding: 8px 20px; }
        .btn-success { background: linear-gradient(135deg, var(--brand-success), var(--brand-success-dark)); border: none; color: #fff; }
        .btn-danger { background: var(--brand-danger); border: none; color: #fff; }
        .btn-secondary { background-color: #eef0f3; border: 1px solid #d7dce3; color: #374151; }

        .left-panel { padding: 22px; }
        .action-bar { border-top: 1px solid var(--border-soft); margin-top: 20px; padding-top: 16px; display: flex; flex-wrap: wrap; gap: 10px; }

        .grid-wrapper { max-height: calc(100vh - 250px); overflow-y: auto; overflow-x: auto; }
        .grid-wrapper table { margin-bottom: 0; white-space: nowrap; font-size: 0.88rem; }
        .grid-wrapper th { position: sticky; top: 0; background: #f8f9fa; z-index: 100; font-weight: 600; font-size: 0.82rem; text-transform: uppercase; padding: 12px 14px; border: none; }

        @media (max-width: 991.98px) { .main-container { padding: 14px; } }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <div class="container-fluid main-container">
            
            <div class="page-heading">
                <i class="bi bi-scissors"></i>
                <div>
                    <h3>Cutting Table</h3>
                    <small>Production &rsaquo; Cutting &rsaquo; Cutting Table</small>
                </div>
            </div>

            <div class="row">
                <!-- Left Side Form -->
                <div class="col-12 col-lg-5 mb-3">
                    <div class="card shadow">
                        <div class="card-header bg-primary text-white">
                            <i class="bi bi-pencil-square"></i>
                            <h4>Table Information</h4>
                        </div>
                        <div class="card-body left-panel">
                            <asp:HiddenField ID="hfUserId" runat="server" />
                            
                            <div class="row g-3">
                                <div class="col-12">
                                    <label>Cutting Table ID</label>
                                    <asp:TextBox ID="txtCuttingTableId" runat="server" ReadOnly="true" CssClass="form-control" />
                                </div>
                                <div class="col-12">
                                    <label>Floor</label>
                                    <asp:DropDownList ID="ddlFloor" runat="server" CssClass="form-select"></asp:DropDownList>
                                </div>
                                <div class="col-12">
                                    <label>Name</label>
                                    <asp:TextBox ID="txtName" runat="server" CssClass="form-control" />
                                </div>
                                <div class="col-12">
                                    <label>Remarks</label>
                                    <asp:TextBox ID="txtRemarks" runat="server" TextMode="MultiLine" Rows="3" CssClass="form-control" />
                                </div>
                                <div class="col-12">
                                    <div class="form-check mt-2">
                                        <asp:CheckBox ID="chkIsActive" runat="server" CssClass="form-check-input" />
                                        <asp:Label AssociatedControlID="chkIsActive" runat="server" Text="Is Active?" CssClass="form-check-label fw-bold"></asp:Label>
                                    </div>
                                </div>
                            </div>

                            <div class="action-bar">
                                <asp:Button ID="btnRefresh" runat="server" Text="Refresh" CssClass="btn btn-secondary" />
                                <asp:Button ID="btnSave" runat="server" Text="Save" CssClass="btn btn-success" />
                                <asp:Button ID="btnDelete" runat="server" Text="Delete" CssClass="btn btn-danger" />
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Right Side Grid -->
                <div class="col-12 col-lg-7 mb-3">
                    <div class="card shadow">
                        <div class="card-header bg-success text-white">
                            <i class="bi bi-list-check"></i>
                            <h4>Cutting Table List</h4>
                        </div>
                        <div class="p-3 bg-light border-bottom">
                            <small class="text-muted">Note: To Edit - Please select a row by clicking on the row head.</small>
                        </div>
                        <div class="grid-wrapper">
                             <!-- GridView or ListView -->
                            <asp:GridView ID="gvCuttingTable" runat="server" CssClass="table table-bordered table-hover" AutoGenerateColumns="false" Width="100%">
                            </asp:GridView>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </form>
</body>
</html>