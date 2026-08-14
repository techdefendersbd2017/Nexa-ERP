<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="RoleToModulePermission.aspx.cs" Inherits="Nexa_ERP.ERPConfiguration.UserAuthorization.RoleToModulePermission" %>
<!DOCTYPE html>
<html>
<head runat="server">
    <title>Role To Module Permission - NexaERP</title>

    <!-- Bootstrap -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet" />
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>

    <style>
        body { background: #f4f6f9; }
        .card { border-radius: 12px; }
        .form-control, .form-select { border-radius: 8px; }
        .btn { border-radius: 8px; }
        .table-responsive { border-radius: 8px; overflow: hidden; }
    </style>

    <script type="text/javascript">
        // সব রো-এর নির্দিষ্ট কোনো কলামের চেকবাক্স একসাথে চেক বা আনচেক করার জন্য
        function toggleColumn(headerChk, itemChkId) {
            var grid = document.getElementById('<%= gvModulePermission.ClientID %>');
            var inputs = grid.getElementsByTagName("input");

            for (var i = 0; i < inputs.length; i++) {
                if (inputs[i].id.indexOf(itemChkId) !== -1) {
                    inputs[i].checked = headerChk.checked;
                }
            }
        }
    </script>
</head>
<body>
<form id="form1" runat="server">
<div class="container mt-4">

    <!-- Top Card: Role Selection -->
    <div class="card shadow">
        <div class="card-header bg-primary text-white">
            <h4 class="mb-0">Role To Module Permission</h4>
        </div>

        <div class="card-body">
            <asp:HiddenField ID="hfRoleId" runat="server" />

            <div class="row g-3 align-items-end">
                <div class="col-md-4">
                    <label class="form-label fw-bold">Select Role Name</label>
                    <asp:DropDownList ID="ddlRole" AutoPostBack="true" runat="server" CssClass="form-select" OnSelectedIndexChanged="ddlRole_SelectedIndexChanged"></asp:DropDownList>
                </div>
                <div class="col-md-8 text-end">
                    <asp:Button ID="btnSave" runat="server" Text="Save Permissions" CssClass="btn btn-success px-4" OnClick="btnSave_Click"/>
                </div>
            </div>
        </div>
    </div>

    <!-- Bottom Card: Module Permission Matrix Grid -->
    <div class="card shadow mt-4">
        <div class="card-header bg-secondary text-white">
            <h5 class="mb-0">Module Access Control List</h5>
        </div>
        <div class="card-body">
            <div class="table-responsive">
                <asp:GridView ID="gvModulePermission" runat="server" CssClass="table table-bordered table-hover align-middle mb-0" AutoGenerateColumns="False" DataKeyNames="module_id" OnRowDataBound="gvModulePermission_RowDataBound" OnSelectedIndexChanged="gvModulePermission_SelectedIndexChanged">
                    <Columns>
                        <asp:BoundField DataField="module_id" HeaderText="Module ID" Visible="false" />
                        <asp:BoundField DataField="module_name" HeaderText="Module Name" />
                        <asp:TemplateField HeaderText="View">
                            <HeaderTemplate>
                                <asp:CheckBox ID="chkHeaderView" runat="server" Text=" View" onclick="toggleColumn(this, 'chkItemView');" />
                            </HeaderTemplate>
                            <ItemTemplate>
                                <asp:CheckBox ID="chkItemView" runat="server" CssClass="chkItemView" />
                            </ItemTemplate>
                        </asp:TemplateField>

                    </Columns>
                </asp:GridView>
            </div>
        </div>
    </div>

</div>
</form>
</body>
</html>