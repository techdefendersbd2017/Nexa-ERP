<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="StyleWiseBundlePartsMapping.aspx.cs" Inherits="Nexa_ERP.Production.Cutting.StyleWiseBundlePartsMapping" %>

<!DOCTYPE html>
<html>
<head runat="server">
    <title>Style Wise Bundle Parts Mapping - NexaERP</title>
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
        .req { color: var(--brand-danger); }

        .form-control, .form-select { border-radius: 8px; border: 1px solid #d7dce3; padding: 9px 12px; font-size: 0.92rem; transition: border-color 0.15s ease, box-shadow 0.15s ease; }
        .form-control:focus, .form-select:focus { border-color: var(--brand-primary); box-shadow: 0 0 0 0.2rem rgba(13, 110, 253, 0.15); }
        .form-select:disabled { background-color: #eef0f3; }

        .btn { border-radius: 8px; font-weight: 600; font-size: 0.9rem; padding: 8px 20px; }
        .btn-primary { background: linear-gradient(135deg, var(--brand-primary), var(--brand-primary-dark)); border: none; color: #fff; }
        .btn-success { background: linear-gradient(135deg, var(--brand-success), var(--brand-success-dark)); border: none; color: #fff; }
        .btn-danger { background: var(--brand-danger); border: none; color: #fff; }
        .btn-secondary { background-color: #eef0f3; border: 1px solid #d7dce3; color: #374151; }
        .btn:disabled, .btn[disabled] { opacity: 0.5; cursor: not-allowed; }

        .left-panel { padding: 22px; }
        .action-bar { border-top: 1px solid var(--border-soft); margin-top: 20px; padding-top: 16px; display: flex; flex-wrap: wrap; gap: 10px; }

        /* Embellishment checkbox list */
        .emb-box { border: 1px solid #d7dce3; border-radius: 8px; padding: 9px 12px; background: #fff; }
        .emb-box label { display: inline-block; margin: 0 22px 0 6px; font-weight: 600; cursor: pointer; }
        .emb-box input[type=checkbox] { cursor: pointer; accent-color: var(--brand-primary); }

        .grid-wrapper { max-height: 320px; overflow-y: auto; overflow-x: auto; }
        .grid-wrapper table { margin-bottom: 0; white-space: nowrap; font-size: 0.88rem; }
        .grid-wrapper th { position: sticky; top: 0; background: #f8f9fa; z-index: 100; font-weight: 600; font-size: 0.82rem; text-transform: uppercase; padding: 12px 14px; border: none; }
        .grid-wrapper td { vertical-align: middle; }
        .grid-wrapper a.select-link { text-decoration: none; font-weight: 600; color: var(--brand-primary); }
        .grid-wrapper a.select-link:hover { text-decoration: underline; }
        .grid-wrapper a.remove-link { text-decoration: none; font-weight: 600; color: var(--brand-danger); }
        .grid-wrapper a.remove-link:hover { text-decoration: underline; }

        @media (max-width: 991.98px) { .main-container { padding: 14px; } }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <div class="container-fluid main-container">

            <div class="page-heading">
                <i class="bi bi-diagram-3"></i>
                <div>
                    <h3>Style Wise Bundle Parts Mapping</h3>
                    <small>Production &rsaquo; Cutting &rsaquo; Style Wise Bundle Parts Mapping</small>
                </div>
            </div>

            <!-- Success / Error Message -->
            <asp:Panel ID="pnlMessage" runat="server" Visible="false" CssClass="alert alert-success" role="alert">
                <i class="bi bi-info-circle-fill"></i>
                <asp:Label ID="lblMessage" runat="server"></asp:Label>
            </asp:Panel>

            <div class="row">
                <!-- Left Side Form -->
                <div class="col-12 col-lg-5 mb-3">
                    <div class="card shadow">
                        <div class="card-header bg-primary text-white">
                            <i class="bi bi-pencil-square"></i>
                            <h4>Style Mapping Information</h4>
                        </div>
                        <div class="card-body left-panel">
                            <asp:HiddenField ID="hfUserId" runat="server" />

                            <div class="row g-3">
                                <div class="col-12">
                                    <label>Style Mapping ID</label>
                                    <asp:TextBox ID="txtStylePartsMappingId" runat="server" ReadOnly="true" CssClass="form-control" placeholder="Auto generated" />
                                </div>

                                <div class="col-12">
                                    <label>Buyer Name <span class="req">*</span></label>
                                    <asp:DropDownList ID="ddlBuyer" runat="server" AutoPostBack="true"
                                        OnSelectedIndexChanged="ddlBuyer_SelectedIndexChanged" CssClass="form-select"></asp:DropDownList>
                                </div>

                                <div class="col-12">
                                    <label>Style Name <span class="req">*</span></label>
                                    <asp:DropDownList ID="ddlStyle" runat="server" AutoPostBack="true"
                                        OnSelectedIndexChanged="ddlStyle_SelectedIndexChanged" CssClass="form-select"></asp:DropDownList>
                                </div>

                                <div class="col-12">
                                    <label>PO No <span class="req">*</span></label>
                                    <asp:DropDownList ID="ddlPO" runat="server" CssClass="form-select"></asp:DropDownList>
                                </div>

                                <div class="col-12">
                                    <label>Body Part <span class="req">*</span></label>
                                    <asp:DropDownList ID="ddlBodyPart" runat="server" CssClass="form-select"></asp:DropDownList>
                                </div>

                                <div class="col-12">
                                    <label>Embellishment Type <span class="text-muted fw-normal">(optional)</span></label>
                                    <asp:DropDownList ID="ddlEmbellishment" runat="server" CssClass="form-select">
                                        <asp:ListItem Text="-- None --" Value="" />
                                        <asp:ListItem Text="Print" Value="Print" />
                                        <asp:ListItem Text="Embroidery" Value="Embroidery" />
                                        <asp:ListItem Text="Smoke" Value="Smoke" />
                                    </asp:DropDownList>
                                </div>

                                <div class="col-12">
                                    <asp:Button ID="btnAdd" runat="server" Text="Add" CssClass="btn btn-primary"
                                        CausesValidation="false" OnClick="btnAdd_Click" />
                                </div>

                                <div class="col-12">
                                    <div class="form-check mt-1">
                                        <asp:CheckBox ID="chkIsActive" runat="server" Checked="true" CssClass="form-check-input" />
                                        <asp:Label AssociatedControlID="chkIsActive" runat="server" Text="Is Active?" CssClass="form-check-label fw-bold"></asp:Label>
                                    </div>
                                </div>
                            </div>

                            <div class="action-bar">
                                <asp:Button ID="btnRefresh" runat="server" Text="Refresh" CssClass="btn btn-secondary"
                                    CausesValidation="false" OnClick="btnRefresh_Click" />
                                <asp:Button ID="btnSave" runat="server" Text="Save" CssClass="btn btn-success"
                                    CausesValidation="false" OnClick="btnSave_Click" />
                                <asp:Button ID="btnDelete" runat="server" Text="Delete" CssClass="btn btn-danger"
                                    CausesValidation="false" Enabled="false" OnClick="btnDelete_Click"
                                    OnClientClick="return confirm('Are you sure you want to delete this mapping?');" />
                                <asp:Button ID="btnClear" runat="server" Text="Clear" CssClass="btn btn-secondary"
                                    CausesValidation="false" OnClick="btnClear_Click" />
                                <asp:Button ID="btnClose" runat="server" Text="Close" CssClass="btn btn-secondary"
                                    CausesValidation="false" OnClientClick="window.close(); return false;" />
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Right Side -->
                <div class="col-12 col-lg-7">

                    <!-- Added items -->
                    <div class="card shadow mb-3">
                        <div class="card-header bg-success text-white">
                            <i class="bi bi-list-check"></i>
                            <h4>Added Body Parts</h4>
                        </div>
                        <div class="grid-wrapper">
                            <asp:GridView ID="gvMap" runat="server" CssClass="table table-bordered table-hover"
                                AutoGenerateColumns="false" Width="100%"
                                OnRowCommand="gvMap_RowCommand"
                                EmptyDataText="No item added yet. Select values and click Add.">
                                <EmptyDataRowStyle CssClass="text-center text-muted p-4" />
                                <Columns>
                                    <asp:TemplateField HeaderText="SL" ItemStyle-Width="50px">
                                        <ItemTemplate><%# Container.DataItemIndex + 1 %></ItemTemplate>
                                    </asp:TemplateField>
                                    <asp:BoundField DataField="Buyer" HeaderText="Buyer" />
                                    <asp:BoundField DataField="Style" HeaderText="Style" />
                                    <asp:BoundField DataField="PO" HeaderText="PO No" />
                                    <asp:BoundField DataField="BodyPart" HeaderText="Body Part" />
                                    <asp:BoundField DataField="Embellishment" HeaderText="Embellishment Type" NullDisplayText="-" />
                                    <asp:TemplateField HeaderText="Action" ItemStyle-Width="90px">
                                        <ItemTemplate>
                                            <asp:LinkButton ID="lnkRemove" runat="server" CommandName="RemoveItem"
                                                CommandArgument='<%# Container.DataItemIndex %>'
                                                CssClass="remove-link">Remove</asp:LinkButton>
                                        </ItemTemplate>
                                    </asp:TemplateField>
                                </Columns>
                            </asp:GridView>
                        </div>
                    </div>

                    <!-- Saved mappings -->
                    <div class="card shadow mb-3">
                        <div class="card-header bg-primary text-white">
                            <i class="bi bi-database-check"></i>
                            <h4>Saved Mappings</h4>
                        </div>
                        <div class="p-3 bg-light border-bottom">
                            <small class="text-muted">Note: To Edit - Please select a row by clicking on the row head.</small>
                        </div>
                        <div class="grid-wrapper">
                            <asp:GridView ID="gvSaved" runat="server" CssClass="table table-bordered table-hover"
                                AutoGenerateColumns="false" Width="100%" DataKeyNames="MappingId"
                                OnSelectedIndexChanged="gvSaved_SelectedIndexChanged"
                                EmptyDataText="No mapping saved yet.">
                                <SelectedRowStyle CssClass="table-primary" />
                                <EmptyDataRowStyle CssClass="text-center text-muted p-4" />
                                <Columns>
                                    <asp:CommandField ShowSelectButton="true" SelectText="Select" HeaderText="Action"
                                        ControlStyle-CssClass="select-link" />
                                    <asp:BoundField DataField="MappingId" HeaderText="ID" />
                                    <asp:BoundField DataField="BuyerName" HeaderText="Buyer" />
                                    <asp:BoundField DataField="StyleText" HeaderText="Style" />
                                    <asp:BoundField DataField="PONo" HeaderText="PO No" />
                                    <asp:BoundField DataField="ItemCount" HeaderText="Parts" />
                                    <asp:TemplateField HeaderText="Status">
                                        <ItemTemplate>
                                            <%# Convert.ToBoolean(Eval("IsActive"))
                                                ? "<span class='badge bg-success'>Active</span>"
                                                : "<span class='badge bg-secondary'>Inactive</span>" %>
                                        </ItemTemplate>
                                    </asp:TemplateField>
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
